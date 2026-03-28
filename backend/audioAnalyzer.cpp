#include "AudioAnalyzer.h"
#include <fstream>
#include <cmath>
#include <vector>
#include <QUrl>
#include <QDebug>
#include <QVariantMap>

// Структура для промежуточного анализа кадров
struct FrameInfo {
    double startTime;
    int type; // 1-тишина, 2-речь, 3-громко
};

QVariantList AudioAnalyzer::analyzeFile(const QString &filePath)
{
    QVariantList mergedResult;
    QString localPath = filePath;
    if (localPath.startsWith("file://"))
        localPath = QUrl(localPath).toLocalFile();

    std::ifstream file(localPath.toStdString(), std::ios::binary);
    if (!file) return mergedResult;

    WAVHeader header;
    file.read(reinterpret_cast<char*>(&header), sizeof(WAVHeader));

    if (std::string(header.riff, 4) != "RIFF" || header.audioFormat != 1 || header.bitsPerSample != 16)
        return mergedResult;

    const uint32_t sampleRate = header.sampleRate;
    const uint16_t channels = header.numChannels;
    const int frameSamples = sampleRate / 50; // 20мс
    const double frameDurationMs = 20.0;

    auto computeRMS = [](const std::vector<int16_t>& data) -> double {
        if (data.empty()) return 0.0;
        double sum = 0.0;
        for (int16_t s : data) sum += static_cast<double>(s) * s;
        return std::sqrt(sum / data.size());
    };

    // --- ШАГ 1: Читаем весь файл ОДИН раз и сохраняем RMS каждого кадра ---
    std::vector<double> allRmsValues;
    std::vector<int16_t> buffer(frameSamples * channels);

    while (file.read(reinterpret_cast<char*>(buffer.data()), buffer.size() * sizeof(int16_t))) {
        std::vector<int16_t> mono(frameSamples);
        for (int j = 0; j < frameSamples; j++) {
            int32_t avg = 0;
            for (int ch = 0; ch < channels; ch++) avg += buffer[j * channels + ch];
            mono[j] = static_cast<int16_t>(avg / channels);
        }
        allRmsValues.push_back(computeRMS(mono));
    }

    if (allRmsValues.empty()) return mergedResult;

    const double silenceLimit = 500.0;
    const double speechThreshold  = 2500.0;
    const double loudThreshold    = 8000.0;

    std::vector<FrameInfo> frameLabels;
    double currentTime = 0.0;
    for (double rms : allRmsValues) {
        int type = 3; // Тишина
        if (rms > loudThreshold) type = 2;
        else if (rms > speechThreshold) type = 1;

        frameLabels.push_back({currentTime, type});
        currentTime += frameDurationMs;
    }

    // --- ШАГ 4: Формируем первичные сегменты с Padding ---
    QVariantList rawSegments;
    const int windowSize = 5;
    const double paddingMs = 200.0;
    int currentType = frameLabels[0].type;
    double segmentStart = 0.0;

    for (size_t i = 0; i < frameLabels.size(); ++i) {
        if (i + windowSize < frameLabels.size()) {
            int counts[4] = {0, 0, 0, 0};
            for (int k = 0; k < windowSize; ++k) counts[frameLabels[i + k].type]++;

            int maxType = currentType;
            if (counts[2] > windowSize / 3) maxType = 2;
            else if (counts[1] > windowSize / 2) maxType = 1;
            else if (counts[3] > (windowSize * 0.8)) maxType = 3;

            if (maxType != currentType) {
                double t1 = segmentStart;
                double t2 = frameLabels[i].startTime;
                if (currentType != 3) {
                    t1 = std::max(0.0, t1 - paddingMs);
                    t2 = std::min(frameLabels[i].startTime, t2 + paddingMs);
                }
                if ((t2 - t1) > 300.0 || currentType == 3) {
                    QVariantMap seg;
                    seg["t1"] = t1; seg["t2"] = t2; seg["type"] = currentType;
                    rawSegments.append(seg);
                }
                segmentStart = frameLabels[i].startTime;
                currentType = maxType;
            }
        }
    }
    // Хвост файла
    QVariantMap last;
    last["t1"] = segmentStart; last["t2"] = currentTime; last["type"] = currentType;
    rawSegments.append(last);

    // --- ШАГ 5: Агрессивное слияние (Merging) ---
    if (rawSegments.isEmpty()) return mergedResult;

    const double maxSilenceToIgnore = 500.0;

    QVariantMap current = rawSegments[0].toMap();

    // веса типов (накопление длительности)
    double typeWeights[4] = {0.0, 0.0, 0.0, 0.0};

    // инициализация первым сегментом
    {
        int t = current["type"].toInt();
        double d = current["t2"].toDouble() - current["t1"].toDouble();
        typeWeights[t] += d;
    }

    for (int i = 1; i < rawSegments.size(); ++i) {
        QVariantMap next = rawSegments[i].toMap();

        bool bothActive = (current["type"].toInt() != 3 && next["type"].toInt() != 3);
        double gap = next["t1"].toDouble() - current["t2"].toDouble();

        if (bothActive && gap < maxSilenceToIgnore) {
            // добавляем длительность следующего сегмента в веса
            int nextType = next["type"].toInt();
            double duration = next["t2"].toDouble() - next["t1"].toDouble();
            typeWeights[nextType] += duration;

            // расширяем текущий сегмент
            current["t2"] = next["t2"];
        } else {
            // выбираем доминирующий тип перед сохранением
            int bestType = 1;
            double bestWeight = 0.0;

            for (int t = 1; t <= 3; ++t) {
                if (typeWeights[t] > bestWeight) {
                    bestWeight = typeWeights[t];
                    bestType = t;
                }
            }

            current["type"] = bestType;
            mergedResult.append(current);

            // начинаем новый сегмент
            current = next;

            // сбрасываем веса
            memset(typeWeights, 0, sizeof(typeWeights));

            int t = current["type"].toInt();
            double d = current["t2"].toDouble() - current["t1"].toDouble();
            typeWeights[t] += d;
        }
    }
    int bestType = 1;
    double bestWeight = 0.0;

    for (int t = 1; t <= 3; ++t) {
        if (typeWeights[t] > bestWeight) {
            bestWeight = typeWeights[t];
            bestType = t;
        }
    }

    current["type"] = bestType;
    mergedResult.append(current);

    return mergedResult;
}
