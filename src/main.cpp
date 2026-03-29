#include <QtQuick>
#include <auroraapp.h>

#include "./backend/audioAnalyzer.h"
#include "audioplayercontrollerPlayer.h"
#include "audiorecordercontroller.h"

int main(int argc, char *argv[])
{
    // 1. Сначала создаем объект приложения через Aurora SDK
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.auroraos"));
    application->setApplicationName(QStringLiteral("SmartVoiceRecorder"));

    // 2. Регистрируем типы (достаточно одного раза!)
    qmlRegisterType<AudioPlayerController>("ru.auroraos.AudioRecorder",
                                           1,
                                           0,
                                           "AudioPlayerController");
    qmlRegisterType<AudioAnalyzer>("ru.auroraos.AudioAnalyzer", 1, 0, "AudioAnalyzer");
    qmlRegisterType<AudioRecorderController>("ru.auroraos.AudioRecorder",
                                             1,
                                             0,
                                             "AudioRecorderController");

    // 3. Создаем объект бэкенда
    AudioRecorder recorder;

    // 4. Создаем View через Aurora SDK
    QScopedPointer<QQuickView> view(Aurora::Application::createView());

    // 5. Прокидываем объект в контекст ИМЕННО этого view
    view->rootContext()->setContextProperty("sessionManager", &recorder);

    // 6. Устанавливаем путь к QML и запускаем
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/SmartVoiceRecorder.qml")));
    view->show();

    return application->exec();
}
