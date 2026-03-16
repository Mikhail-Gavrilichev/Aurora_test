#include <QtQuick>
#include <auroraapp.h>
//#include "./backend/sessionmanager.h"
int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.template"));
    application->setApplicationName(QStringLiteral("smart"));

    //qmlRegisterType<SessionManager>("com.example.sessions", 1, 0, "SessionManager");

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/smart.qml")));
    view->show();

    return application->exec();
}
