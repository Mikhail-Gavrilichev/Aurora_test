#include <auroraapp.h>
#include <QtQuick>

#include "audiorecordercontroller.h"
#include "audioplayercontroller.h"
#include "audioamplitudemodel.h"
#include "timelinemodel.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.auroraos"));
    application->setApplicationName(QStringLiteral("Dictaphone"));

    qmlRegisterType<AudioRecorderController>("ru.auroraos.AudioRecorder", 1, 0,
                                             "AudioRecorderController");
    qmlRegisterType<AudioPlayerController>("ru.auroraos.AudioRecorder", 1, 0,
                                           "AudioPlayerController");

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/Dictaphone.qml")));
    view->show();
    return application->exec();
}
