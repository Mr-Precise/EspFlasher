#include "EspProcess.h"
#include <QFile>
#include <QMetaEnum>
#include <QRegularExpressionMatch>
#include <QVariant>
#include <QtDebug>

EspProcess::EspProcess(QObject* parent)
    : QObject(parent)
    , mProcess(new QProcess(this))
{
    connect(mProcess, SIGNAL(error(QProcess::ProcessError)), this,
        SLOT(onError(QProcess::ProcessError)));
    connect(mProcess, SIGNAL(finished(int, QProcess::ExitStatus)), this,
        SLOT(onFinished(int, QProcess::ExitStatus)));
    connect(mProcess, SIGNAL(readyReadStandardError()), this, SLOT(onReadyReadStandardError()));
    connect(mProcess, SIGNAL(readyReadStandardOutput()), this, SLOT(onReadyReadStandardOutput()));
    connect(mProcess, SIGNAL(started()), this, SIGNAL(espStarted()));
}

QStringList EspProcess::getSerialPorts()
{
    QStringList portList;
    mAwailablePorts = QSerialPortInfo::availablePorts();
    foreach (QSerialPortInfo portInfo, mAwailablePorts) {
        portList.append(portInfo.portName());
    }
    return portList;
}

QString EspProcess::getSerialPortDescription(const QString& portName)
{
    foreach (QSerialPortInfo portInfo, mAwailablePorts) {
        if (portInfo.portName() == portName) {
            return portInfo.manufacturer();
        }
    }
    return "";
}

bool EspProcess::downloadImages(const QVariantMap& binFiles, const QString& portName, int baud,
    const QString& flashSize, const QString& spiSpeed, const QString& spiMode)
{
    // 正在执行命令，稍候再来
    if (mProcess->state() != QProcess::NotRunning) {
        return false;
    }

    QStringList                 fileArgs;
    QVariantMap::const_iterator i = binFiles.constBegin();
    while (i != binFiles.end()) {
        bool ok = false;
        i.key().toUInt(&ok, 16);
        if (i.key().startsWith("0x", Qt::CaseInsensitive) && ok
            && QFile::exists(i.value().toString())) {
            fileArgs << i.key() << i.value().toString();
        }
        i++;
    }
    if (fileArgs.isEmpty()) {
        emit espError("BIN file does not exist or the address is wrong");
        return false;
    }

    QStringList args;
    args << "-p" << converToFullPortPath(portName) << "-b" << QString::number(baud) << "--chip"
         << "esp8266"
         << "write_flash"
         << "--flash_mode" << spiMode.toLower() << "--flash_size" << flashSize << "--flash_freq"
         << spiSpeed.toLower();
    args.append(fileArgs);

    mBuffer.clear();
    mProcess->start(mEspToolPath, args);
    emit outputsProbed(QString("\n$ %1 %2\n\n").arg(mEspToolPath).arg(args.join(' ')));
    return true;
}

void EspProcess::onError(QProcess::ProcessError code)
{
    emit espError(QString(QMetaEnum::fromType<QProcess::ProcessError>().valueToKey(code)) + ":"
        + mProcess->errorString());
}

void EspProcess::onFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitStatus == QProcess::CrashExit) {
        emit espError("task termination");
    } else if (exitCode == 0) {
        emit espFinished();
    } else {
        qWarning() << "Task return code: " << exitCode << __FILE__ << __LINE__;
    }
}

void EspProcess::onReadyReadStandardError()
{
    mProcess->setReadChannel(QProcess::StandardError);
    while (mProcess->canReadLine()) {
        QString line = QString::fromUtf8(mProcess->readLine());
        emit    outputsProbed(line);
        if (line.contains("Errno 2")) {
            emit espError("Device does not exist and cannot be opened");
        } else if (line.contains("Errno 13")) {
            emit espError("Insufficient permissions to open serial device");
        } else if (line.contains("ValueError: Not a valid baudrate")) {
            emit espError("Please choose the baud rate");
        }
    }
}

void EspProcess::onReadyReadStandardOutput()
{
    QRegularExpressionMatch match;

    QByteArray data = mProcess->readAllStandardOutput();
    mBuffer.append(QString::fromUtf8(data));
    emit outputsProbed(QString::fromUtf8(data));

    mBuffer.replace("\r\n", "\n");
    mBuffer.replace(QChar('\r'), QChar('\n'));
    QStringList lines = mBuffer.split('\n', QString::SkipEmptyParts);
    for (QStringList::const_iterator i = lines.begin(); i != lines.end(); i++) {
        bool isHandled = true;
        if (i->contains("Connecting...")) {
            emit espStarted();
        } else if (i->contains("A fatal error occurred: Failed to connect to")) {
            emit espError("Failed to connect to device");
        } else if (i->contains(QRegularExpression("Chip is (ESP8266|ESP32|ESP8285)"), &match)) {
            emit metaDataProbed(QString("chip: ") + match.captured(1));
        } else if (i->contains(QRegularExpression("Writing at 0x[0-9a-fA-F]{8}\\.\\.\\. "
                                                  "\\((100|[0-9]{1}|[1-9][0-9]) %\\)"),
                       &match)) {
            emit dowmloadProgressChanged(match.captured(1).toInt());
        } else {
            isHandled = false;
        }

        if (isHandled || i < lines.end() - 1) {
            mBuffer.remove(0, mBuffer.indexOf(*i) + i->length());
        }
    }
}

QString EspProcess::converToFullPortPath(const QString& portName)
{
#ifdef Q_OS_LINUX
    return QString("/dev/") + portName;
#endif
}
