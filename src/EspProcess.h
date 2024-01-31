#ifndef ESPPROCESS_H
#define ESPPROCESS_H

#include <QBuffer>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QSerialPortInfo>

class EspProcess : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString espToolPath MEMBER mEspToolPath)
    Q_PROPERTY(QStringList serialPorts READ getSerialPorts NOTIFY serialPortsChanged)

public:
    EspProcess(QObject* parent = 0);

    /**
     * @brief registerTypes
     */
    static void registerTypes()
    {
        qmlRegisterType<EspProcess>("EspFlasher", 1, 0, "EspFlasher");
        qRegisterMetaType<QProcess::ProcessError>("QProcess::ProcessError");
        qRegisterMetaType<QProcess::ExitStatus>("QProcess::ExitStatus");
    }

    /**
     * @brief stop
     */
    Q_INVOKABLE void stop()
    {
        mProcess->terminate();
    }

    /**
     * @brief getSerialPorts
     * @return
     */
    Q_INVOKABLE QStringList getSerialPorts();

    /**
     * @brief getSerialPortDescription
     * @param portName
     * @return
     */
    Q_INVOKABLE QString getSerialPortDescription(const QString& portName);

    /**
     * @brief downloadImages
     * @param binFiles
     * @param port
     * @param baud
     * @param flashSize
     * @param spiSpeed
     * @param spiMode
     * @return
     */
    Q_INVOKABLE bool downloadImages(const QVariantMap& binFiles,
        const QString& portName = "/dev/ttyUSB0", int baud = 115200,
        const QString& flashSize = "4MB", const QString& spiSpeed = "40m",
        const QString& spiMode = "qio");

signals:
    void espStarted();
    void dowmloadProgressChanged(int percent);
    void espFinished();
    void espError(const QString& errorString);
    void serialPortsChanged(const QStringList& ports);
    void outputsProbed(const QString& data);
    void metaDataProbed(const QString& data);
    void isRunningChanged(bool isRunning);

private slots:
    void onError(QProcess::ProcessError code);
    void onFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onReadyReadStandardError();
    void onReadyReadStandardOutput();

private:
    QProcess*              mProcess;
    QString                mEspToolPath;
    QList<QSerialPortInfo> mAwailablePorts;
    QString                mBuffer;

    QString converToFullPortPath(const QString& portName);
};

#endif // ESPPROCESS_H
