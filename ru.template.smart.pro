TARGET = ru.template.smart

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    backend/audioAnalyzer.cpp \
    backend/audioamplitudePlayer.cpp \
    backend/audioamplitudemodelPlayer.cpp \
    backend/audiobufferextension.cpp \
    backend/audioplayercontrollerPlayer.cpp \
    backend/audiorecorder.cpp \
    backend/audiorecordercontroller.cpp \
    backend/sessionmanag.cpp \
    backend/smartDenoiseWavSoft.cpp \
    backend/timelineblockPlayer.cpp \
    backend/timelinemodelPlayer.cpp \
    src/main.cpp \

HEADERS += \
    backend/audioAnalyzer.h \
    backend/audioamplitudePlayer.h \
    backend/audioamplitudemodelPlayer.h \
    backend/audiobufferextension.h \
    backend/audioplayercontrollerPlayer.h \
    backend/audiorecorder.h \
    backend/audiorecordercontroller.h \
    backend/sessionmanag.h \
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
