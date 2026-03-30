TARGET = ru.template.smart

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
<<<<<<< Updated upstream
=======
    backend/amplitudemodelfillerPlayer.cpp \
>>>>>>> Stashed changes
    backend/audioAnalyzer.cpp \
    backend/audioamplitudePlayer.cpp \
    backend/audioamplitudemodelPlayer.cpp \
    backend/audiobufferextension.cpp \
    backend/audioplayercontrollerPlayer.cpp \
    backend/audiorecorder.cpp \
    backend/audiorecordercontroller.cpp \
    backend/sessionmanag.cpp \
<<<<<<< Updated upstream
=======
    backend/silenceremover.cpp \
    backend/silenceremover_qt.cpp \
    backend/silenceservice.cpp \
>>>>>>> Stashed changes
    backend/smartDenoiseWavSoft.cpp \
    backend/timelineblockPlayer.cpp \
    backend/timelinemodelPlayer.cpp \
    src/main.cpp \

HEADERS += \
<<<<<<< Updated upstream
=======
    backend/amplitudemodelfillerPlayer.h \
>>>>>>> Stashed changes
    backend/audioAnalyzer.h \
    backend/audioamplitudePlayer.h \
    backend/audioamplitudemodelPlayer.h \
    backend/audiobufferextension.h \
    backend/audioplayercontrollerPlayer.h \
    backend/audiorecorder.h \
    backend/audiorecordercontroller.h \
    backend/sessionmanag.h \
<<<<<<< Updated upstream
=======
    backend/silenceremover.h \
    backend/silenceremover_qt.h \
    backend/silenceservice.h \
>>>>>>> Stashed changes
    backend/smartDenoiseWavSoft.h \
    backend/timelineblockPlayer.h \
    backend/timelinemodelPlayer.h

DISTFILES += \
    qml/pages/DictaphonePage.qml \
    qml/pages/RecordTrack.qml \
    qml/pages/RecordingPage.qml \
    qml/pages/RedactingPage.qml \
    rpm/ru.template.smart.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

QT += multimedia
INCLUDEPATH += backend
TRANSLATIONS += \
    translations/ru.template.smart.ts \
    translations/ru.template.smart-ru.ts \
