import QtQuick 2.0
import Sailfish.Silica 1.0
import ru.auroraos.AudioRecorder 1.0
import Aurora.Controls 1.0
import Sailfish.Pickers 1.0
<<<<<<< Updated upstream
=======
import ru.auroraos.AudioRecorder 1.0
>>>>>>> Stashed changes
import ru.auroraos.AudioAnalyzer 1.0
import "../components"

Page {
    id: page
    objectName: "redactingPage"

    property string filePath: ""
    property alias fileName: header.headerText

    // аннотации теперь заполняются из C++
    property var fileAnnotations: []

<<<<<<< Updated upstream
    // должно совпадать с C++ и формулами
    readonly property int measurementsPerSec: 10
    readonly property int barWidthPx: 6

    AudioAnalyzer {
        id: analyzer
=======
    property var fileAnnotations: []

    property var voiceLabels: []
    property var annotationsWithIds: []

    property string lastError: ""

    SilenceService { id: silenceService }

    AudioAnalyzer {
        id: audioAnalyzer
    }

    function rebuildVoiceIdsAndTitles() {
        var voiceCounter = 0
        var result = []
        for (var i = 0; i < fileAnnotations.length; i++) {
            var a = fileAnnotations[i]
            var obj = { "t1": a.t1, "t2": a.t2, "type": a.type }
            if (a.type === 1) {
                voiceCounter++
                obj.voiceId = voiceCounter
            }
            result.push(obj)
        }
        annotationsWithIds = result

        var newLabels = []
        for (var id = 1; id <= voiceCounter; id++) {
            var found = null
            for (var j = 0; j < voiceLabels.length; j++) {
                if (voiceLabels[j].voiceId === id) { found = voiceLabels[j]; break }
            }
            if (found) newLabels.push(found)
            else newLabels.push({ "voiceId": id, "title": "человеческая речь " + id })
        }
        voiceLabels = newLabels
    }

    function titleForVoiceId(voiceId) {
        for (var i = 0; i < voiceLabels.length; i++) {
            if (voiceLabels[i].voiceId === voiceId) return voiceLabels[i].title
        }
        return "человеческая речь " + voiceId
    }

    function setTitleForVoiceId(voiceId, newTitle) {
        var t = (newTitle || "").trim()
        if (t.length === 0) t = "человеческая речь " + voiceId
        for (var i = 0; i < voiceLabels.length; i++) {
            if (voiceLabels[i].voiceId === voiceId) {
                voiceLabels[i].title = t
                voiceLabels = voiceLabels
                return
            }
        }
    }

    function removeSilenceNow() {
        if (!filePath || filePath === "") return
        lastError = ""
        playerControllerRedact.pause()

        var r = silenceService.removeSilence(filePath, fileAnnotations, silence_type)
        processCutResult(r)
    }

    function deleteSegmentUnderCursor() {
        if (!filePath || filePath === "") return

        var pos = currentPosMs
        var targetIndex = -1

        for (var i = 0; i < fileAnnotations.length; i++) {
            if (pos >= fileAnnotations[i].t1 && pos < fileAnnotations[i].t2) {
                targetIndex = i
                break
            }
        }

        if (targetIndex === -1 && fileAnnotations.length > 0) {
            var last = fileAnnotations[fileAnnotations.length - 1]
            if (pos === last.t2) targetIndex = fileAnnotations.length - 1
        }

        if (targetIndex === -1) {
            lastError = "Нет сегмента под курсором (поз: " + Math.round(pos) + "мс)"
            return
        }

        lastError = ""
        playerControllerRedact.pause()

        var fakeAnnotations = JSON.parse(JSON.stringify(fileAnnotations))
        fakeAnnotations[targetIndex].type = 999

        var r = silenceService.removeSilence(filePath, fakeAnnotations, 999)
        processCutResult(r)
    }

    function processCutResult(r) {
        if (!r || r.error) {
            lastError = r ? r.error : "Ошибка: пустой ответ"
            return
        }

        var raw = r.annotations
        var clean = []

        for (var i = 0; i < raw.length; i++) {
            var cur = raw[i]
            if (cur.t1 >= cur.t2) continue
            clean.push({ "t1": cur.t1, "t2": cur.t2, "type": cur.type })
        }

        filePath = r.outputPath
        header.headerText = filePath ? filePath.split('/').pop() : ""

        fileAnnotations = clean
        rebuildVoiceIdsAndTitles()

        playerControllerRedact.setSource(filePath)
        playerControllerRedact.audioAmplitudeModel.applyAnnotations(fileAnnotations, measurementsPerSec)
    }

    function seekToNextSegment() {
        var currentPos = currentPosMs
        var nextPos = -1
        for (var i = 0; i < fileAnnotations.length; i++) {
            if (fileAnnotations[i].t1 > currentPos + 50) {
                if (nextPos === -1 || fileAnnotations[i].t1 < nextPos) {
                    nextPos = fileAnnotations[i].t1
                }
            }
        }
        if (nextPos !== -1) pageRoot.seekToMs(nextPos)
    }

    function seekToPrevSegment() {
        var currentPos = currentPosMs
        var prevPos = -1
        for (var i = 0; i < fileAnnotations.length; i++) {
            if (fileAnnotations[i].t1 < currentPos - 50) {
                if (prevPos === -1 || fileAnnotations[i].t1 > prevPos) {
                    prevPos = fileAnnotations[i].t1
                }
            }
        }
        if (prevPos !== -1) pageRoot.seekToMs(prevPos)
        else pageRoot.seekToMs(0)
>>>>>>> Stashed changes
    }

    Component.onCompleted: {
        playerController.isPlayerPage = true
    }

    // обновление аннотаций при выборе файла
    function updateAnnotations() {
        if (filePath !== "") {
            fileAnnotations = analyzer.analyzeFile(filePath)
            console.log("annotations count:", fileAnnotations.length)

            playerController.audioAmplitudeModel.applyAnnotations(fileAnnotations, measurementsPerSec)
        }
    }

    onFilePathChanged: {
        updateAnnotations()
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating)
            playerController.stop()
    }

    Connections {
        target: playerController
        onDecodingCompleted: {
            if (fileAnnotations && fileAnnotations.length > 0) {
                playerController.audioAmplitudeModel.applyAnnotations(fileAnnotations, measurementsPerSec)
            }
        }
    }

    AppBar {
        id: header
        headerText: filePath ? filePath.split('/').pop() : "Выберите аудиофайл"

        IconButton {
            icon.source: "image://theme/icon-m-folder"
            onClicked: openFilePicker()
        }
    }

    Item {
        id: pageRoot
        anchors {
            left: parent.left; right: parent.right
            top: header.bottom; bottom: parent.bottom
        }

        function seekToMs(ms) {
            if (ms < 0) ms = 0
            var wasPlaying = playerController.isPlaying
            playerController.play(ms)
            if (!wasPlaying)
                playerController.stop()
        }

        Item {
            id: waveformContainer
            anchors {
                left: parent.left; right: parent.right
                top: parent.top; bottom: timePassed.top
                margins: Theme.paddingLarge
            }
            visible: filePath !== "" && !playerController.isDecoding
            clip: true

            // фоновые линии заметок
            Item {
                width: waveformList.contentWidth
                height: parent.height
                x: -waveformList.contentX

                Repeater {
                    model: page.fileAnnotations
                    Item {
                        x: (modelData.t1 / 1000.0) * measurementsPerSec * barWidthPx
                        width: ((modelData.t2 - modelData.t1) / 1000.0) * measurementsPerSec * barWidthPx
                        height: parent.height

                        Rectangle {
                            anchors.left: parent.left
                            width: 2
                            height: parent.height
                            color: getColorForType(modelData.type)
                            opacity: 0.8
                        }
                        Rectangle {
                            anchors.right: parent.right
                            width: 2
                            height: parent.height
                            color: getColorForType(modelData.type)
                            opacity: 0.8
                        }
                    }
                }
            }

            ListView {
                id: waveformList
                anchors.fill: parent
                orientation: ListView.Horizontal
                model: playerController.audioAmplitudeModel
                boundsBehavior: Flickable.StopAtBounds

                Connections {
                    target: playerController
                    onPositionChanged: {
                        if (playerController.isPlaying) {
                            var currentItemIndex = Math.floor((playerController.position / 1000) * measurementsPerSec)
                            waveformList.positionViewAtIndex(currentItemIndex, ListView.Contain)
                        }
                    }
                }

                delegate: Item {
                    width: barWidthPx
                    height: waveformList.height

                    Rectangle {
                        id: bar
                        anchors.centerIn: parent
                        width: 4
                        height: Math.max(4, model.value * parent.height)
                        radius: 2
                        color: getColorForType(model.annotationType)
                    }

                    // ТАП ПО БАРУ -> SEEK
                    // Скролл не ломаем, потому что MouseArea только на баре,
                    // и Flickable всё равно умеет перехватывать drag.
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // index = номер бара
                            var ms = (index / measurementsPerSec) * 1000.0
                            pageRoot.seekToMs(ms)
                        }
                    }
                }
            }

            // плейхед
            Rectangle {
                width: 2
                height: parent.height
                color: "red"
                x: ((playerController.position / 1000.0) * measurementsPerSec * barWidthPx) - waveformList.contentX
                visible: x > 0 && x < parent.width
            }
        }

        BusyIndicator {
            anchors.centerIn: waveformContainer
            size: BusyIndicatorSize.Large
            running: playerController.isDecoding
            visible: playerController.isDecoding
        }

        Label {
            id: timePassed
            anchors {
                bottom: playButton.top
                horizontalCenter: parent.horizontalCenter
                margins: Theme.horizontalPageMargin
            }
            text: playerController.pointerPositionToString(playerController.position)
            font.pixelSize: Theme.fontSizeMedium * 2
            visible: filePath !== "" && !playerController.isDecoding
        }

        IconButton {
            id: playButton
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: Theme.horizontalPageMargin
            }
            icon {
                source: playerController.isPlaying ? "image://theme/icon-m-pause"
                                                   : "image://theme/icon-m-simple-play"
                width: Theme.iconSizeLarge
                height: Theme.iconSizeLarge
            }
            height: icon.height
            width: icon.width
            enabled: playerController.isPlaybackAvailable && filePath !== "" && !playerController.isDecoding
            visible: filePath !== ""

            onClicked: {
                if (playerController.isPlaying) {
                    playerController.stop()
                } else {
                    var startPosMs = (waveformList.contentX / barWidthPx / measurementsPerSec) * 1000
                    startPosMs = Math.max(0, startPosMs)
                    playerController.play(startPosMs)
                }
            }
        }

        Label {
            anchors.centerIn: parent
            text: "Выберите аудиофайл\nнажмите на иконку папки вверху"
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryColor
            visible: filePath === ""
            font.pixelSize: Theme.fontSizeMedium
        }
    }

    function openFilePicker() {
        var dialog = pageStack.push("Sailfish.Pickers.FilePickerPage", {
            nameFilters: ["*.wav", "*.mp3", "*.ogg", "*.flac"],
            title: "Выберите аудиофайл"
        })

        dialog.selectedContentPropertiesChanged.connect(function() {
            if (dialog.selectedContentProperties && dialog.selectedContentProperties.filePath) {
                var selectedPath = dialog.selectedContentProperties.filePath
                filePath = selectedPath
                updateAnnotations()
                header.headerText = dialog.selectedContentProperties.fileName || selectedPath.split('/').pop()
<<<<<<< Updated upstream
                playerController.setSource(selectedPath)
=======
                lastError = ""
                voiceLabels = []
                rebuildVoiceIdsAndTitles()
                playerControllerRedact.setSource(selectedPath)
                fileAnnotations = audioAnalyzer.analyzeFile(selectedPath)
>>>>>>> Stashed changes
                pageStack.pop()
            }
        })
    }

    function getColorForType(typeCode) {
        switch (typeCode) {
            case 1: return "#00FF00"             // Speech - Зеленый
            case 2: return "#FF0000"             // Loud - Красный
            case 3: return Qt.rgba(1, 1, 1, 0.1) // Silence - Почти прозрачный
            default: return Theme.secondaryColor
        }
    }
}
