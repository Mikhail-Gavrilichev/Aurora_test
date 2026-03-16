TARGET = ru.template.smart

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    backend/sessionmanag.cpp \
    src/main.cpp \

HEADERS += \
    backend/sessionmanag.h

DISTFILES += \
    qml/pages/RecordingPage.qml \
    qml/pages/RedactingPage.qml \
    rpm/ru.template.smart.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.smart.ts \
    translations/ru.template.smart-ru.ts \
