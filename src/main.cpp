#include "EspProcess.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    app.setOrganizationName("mengfm");
    app.setOrganizationDomain("mengfm.com");
    app.setApplicationName("Esp Flasher");

    QQmlApplicationEngine engine;

    EspProcess::registerTypes();

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
