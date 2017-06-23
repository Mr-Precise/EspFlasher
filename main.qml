import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import EspFlasher 1.0

ApplicationWindow {
    id: applicationWindow
    visible: true
    x: (Screen.desktopAvailableWidth - width) / 2
    y: (Screen.desktopAvailableHeight - height) / 2
    width: 640
    height: mPane.height + footer.height
    minimumWidth: 600
    minimumHeight: 400
    title: qsTr("ESP Flasher")

    property real itemHeight: 28
    property real padding: 10
    property int binFileCnt: 6

    Window {
        id: mCmdOutputsWindow
        x: applicationWindow.x + applicationWindow.width
        y: applicationWindow.y
        title: "esptool输出"
        width: 500
        height: applicationWindow.height
        onClosing: mOutPutsShowBtn.checked = false

        Page {
            anchors.fill: parent
            padding: applicationWindow.padding
            header: ToolBar {
                height: itemHeight
                RowLayout {
                    width: parent.width - 2 * applicationWindow.padding
                    height: parent.height
                    anchors.centerIn: parent
                    ToolButton {
                        Layout.fillHeight: true
                        text: "清屏"
                        onClicked: mCmdOutputs.clear()
                    }
                }
            }

            contentItem: Flickable {
                flickableDirection: Flickable.VerticalFlick
                TextArea.flickable: TextArea {
                    id: mCmdOutputs
                    anchors.fill: parent
                    readOnly: true
                    selectByKeyboard: true
                    selectByMouse: true
                    wrapMode: TextEdit.Wrap
                    placeholderText: "当前没有控制台输出"
                    cursorVisible: true
                }
                ScrollBar.vertical: ScrollBar {
                }
            }
        }
    }

    EspFlasher {
        id: mEspFlasher
        espToolPath: mSettings.espToolPath
        onEspError: {
            mStatusText.text = errorString
            mStatusText.color = "red"
            mDownloadButton.state = "download"
        }
        onOutputsProbed: mCmdOutputs.insert(mCmdOutputs.length, data)
        onEspStarted: {
            mStatusText.text = "正在连接设备..."
            mStatusText.color = "black"
            mDownloadButton.state = "stop"
        }
        onDowmloadProgressChanged: {
            mStatusText.text = "正在下载，当前进度 " + percent + "%"
            mStatusText.color = "black"
        }
        onEspFinished: {
            mStatusText.text = "操作成功..."
            mStatusText.color = "green"
            mDownloadButton.state = "download"
        }
        onMetaDataProbed: {
            mChipInfoText.append(data)
        }
    }

    Settings {
        id: mSettings
        property alias espToolPath: mEspToolPath.text
        property string chip: "esp8266"
        property alias spiSpeed: mSpiSpeed.spiSpeed
        property alias spiMode: mSpiMode.spiMode
        property alias flashSize: mFlashSize.flashSize
        property string port: "ttyUSB0"
        property int baud: 115200
        property alias lastFileDialogPath: mFileDialog.folder
        property string binFiles: "{\"binFiles\":[{\"isChecked\":false,\"file\":\"\",\"addr\":\"\"},{\"isChecked\":false,\"file\":\"\",\"addr\":\"\"},{\"isChecked\":false,\"file\":\"\",\"addr\":\"\"},{\"isChecked\":false,\"file\":\"\",\"addr\":\"\"},{\"isChecked\":false,\"file\":\"\",\"addr\":\"\"},{\"isChecked\":false,\"file\":\"\",\"addr\":\"\"}]}"
    }

    FileDialog {
        id: mFileDialog
        property var acceptCallback: null
        onAccepted: {
            if (acceptCallback) {
                acceptCallback(fileUrl.toString().slice(7))
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mPane.height
        clip: true
        ScrollIndicator.vertical: ScrollIndicator {
        }
        Pane {
            id: mPane
            width: parent.width
            padding: applicationWindow.padding
            Column {
                id: mContentLay
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    id: rowLayout2
                    width: parent.width
                    height: itemHeight
                    spacing: 5

                    Label {
                        id: mEspToolPathLabel
                        text: qsTr("esptool路径")
                        verticalAlignment: Text.AlignVCenter
                        Layout.fillHeight: true
                    }

                    TextField {
                        id: mEspToolPath
                        padding: 0
                        clip: true
                        font.capitalization: Font.MixedCase
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: TextInput.AlignVCenter
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.pixelSize: 12
                        selectByMouse: true
                        placeholderText: "选择esptool路径"
                    }

                    Button {
                        id: mEspToolSelButton
                        text: "···"
                        Layout.preferredWidth: height
                        Layout.fillHeight: true
                        onClicked: {
                            mFileDialog.nameFilters = ["esptool.py"]
                            mFileDialog.open()
                            mFileDialog.acceptCallback = function (filePath) {
                                mEspToolPath.text = filePath
                            }
                        }
                    }
                }

                GroupBox {
                    id: mBinFiles
                    width: parent.width
                    title: qsTr("BIN文件")
                    property var binFiles: JSON.parse(mSettings.binFiles)

                    Component.onDestruction: mSettings.binFiles = JSON.stringify(
                                                 binFiles)

                    Column {
                        id: mBinFilesColumn
                        width: parent.width
                        spacing: 5

                        Repeater {
                            model: 6

                            RowLayout {
                                width: parent.width
                                height: itemHeight
                                CheckBox {
                                    id: mBinFileCheck
                                    Layout.preferredWidth: height
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    indicator.width: parent.height * 0.618
                                    indicator.height: indicator.width
                                    enabled: mBinFilePath.text != ""
                                    checked: mBinFiles.binFiles.binFiles[index].isChecked
                                             && mBinFilePath.text != ""
                                    onCheckedChanged: mBinFiles.binFiles.binFiles[index].isChecked
                                                      = checked
                                }

                                TextField {
                                    id: mBinFilePath
                                    padding: 0
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    placeholderText: "选择BIN文件或者输入BIN文件路径"
                                    selectByMouse: true
                                    text: mBinFiles.binFiles.binFiles[index].file
                                    onTextChanged: {
                                        mBinFiles.binFiles.binFiles[index].file = text
                                        if (text == "") {
                                            mBinFileCheck.checked = false
                                        }
                                    }
                                }

                                Button {
                                    Layout.preferredWidth: height
                                    Layout.fillHeight: true
                                    text: "···"
                                    padding: 0
                                    onClicked: {
                                        mFileDialog.nameFilters = ["*.bin"]
                                        mFileDialog.open()
                                        mFileDialog.acceptCallback = function (filePath) {
                                            mBinFilePath.text = filePath
                                            mBinFileCheck.checked = true
                                        }
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignCenter
                                    text: "@"
                                    font.family: "Tahoma"
                                }

                                TextField {
                                    padding: 0
                                    Layout.preferredWidth: 3 * itemHeight
                                    Layout.fillHeight: true
                                    placeholderText: "下载地址"
                                    selectByMouse: true
                                    text: mBinFiles.binFiles.binFiles[index].addr
                                    onTextChanged: mBinFiles.binFiles.binFiles[index].addr = text
                                }
                            }
                        }
                    }
                }

                GroupBox {
                    id: mSpiConfig
                    width: parent.width
                    title: qsTr("SPI设置")

                    RowLayout {
                        id: rowLayout
                        width: parent.width

                        GroupBox {
                            id: mSpiSpeed
                            Layout.minimumWidth: 150
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            title: qsTr("SPI Speed")
                            property string spiSpeed: "40M"

                            Column {
                                width: parent.width
                                Repeater {
                                    model: ["40M", "26M", "20M", "80M"]
                                    CRadioDelegate {
                                        width: contentItem.implicitWidth
                                               + leftPadding + rightPadding
                                        height: itemHeight
                                        text: modelData
                                        checked: modelData == mSpiSpeed.spiSpeed
                                        onCheckedChanged: {
                                            if (checked) {
                                                mSpiSpeed.spiSpeed = modelData
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        GroupBox {
                            id: mSpiMode
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            Layout.minimumWidth: 150
                            title: qsTr("SPI Mode")
                            property string spiMode: "QIO"

                            Column {
                                width: parent.width
                                Repeater {
                                    model: ["QIO", "QOUT", "DIO", "DOUT"]
                                    delegate: CRadioDelegate {
                                        width: contentItem.implicitWidth
                                               + leftPadding + rightPadding
                                        height: itemHeight
                                        text: modelData
                                        checked: modelData == mSpiMode.spiMode
                                        onCheckedChanged: {
                                            if (checked) {
                                                mSpiMode.spiMode = modelData
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        GroupBox {
                            id: mFlashSize
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                            title: qsTr("Flash Size")
                            property string flashSize: "4MB"

                            Grid {
                                id: mFlashSizeLay
                                width: parent.width
                                rows: 5
                                flow: Grid.TopToBottom
                                Repeater {
                                    model: ["256KB", "512KB", "1MB", "2MB", "4MB", "2MB-c1", "4MB-c1", "4MB-c2", "8MB", "16MB"]
                                    delegate: CRadioDelegate {
                                        width: 120
                                        height: itemHeight
                                        text: modelData
                                        checked: modelData == mFlashSize.flashSize
                                        onCheckedChanged: {
                                            if (checked) {
                                                mFlashSize.flashSize = modelData
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                GroupBox {
                    id: mDownLoadPanel
                    width: parent.width
                    title: qsTr("控制面板")

                    Column {
                        width: parent.width
                        spacing: 5

                        TextArea {
                            id: mChipInfoText
                            width: parent.width
                            height: 100
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignLeft
                            Layout.preferredHeight: 54
                            Layout.preferredWidth: 436
                            font.pixelSize: 12
                            placeholderText: "当前没有设备信息"
                            readOnly: true
                            selectByKeyboard: true
                            selectByMouse: true
                            wrapMode: TextEdit.WordWrap

                            background: Rectangle {
                                border.width: 1
                                border.color: "lightgray"
                            }
                        }

                        RowLayout {
                            width: parent.width
                            spacing: 15

                            GridLayout {
                                flow: GridLayout.TopToBottom
                                rows: 2
                                columns: 3
                                Label {
                                    id: mPortLabel
                                    text: qsTr("端口")
                                }

                                Label {
                                    id: mBaudLabel
                                    text: qsTr("波特率")
                                }

                                ComboBox {
                                    id: mPortComb
                                    Layout.preferredHeight: itemHeight
                                    Layout.fillWidth: true
                                    model: mEspFlasher.serialPorts
                                    displayText: currentText + " - "
                                                 + mEspFlasher.getSerialPortDescription(
                                                     currentText)
                                    background: Rectangle {
                                        border.width: 1
                                        border.color: "lightgray"
                                    }
                                    delegate: ItemDelegate {
                                        id: mPortItemRoot
                                        width: mPortComb.width
                                        height: itemHeight
                                        text: modelData
                                        background: null
                                        contentItem: RowLayout {
                                            Text {
                                                Layout.alignment: Qt.AlignCenter
                                                text: mPortItemRoot.text
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignCenter
                                                text: " - " + mEspFlasher.getSerialPortDescription(
                                                          modelData)
                                            }
                                        }
                                    }
                                    currentIndex: find(mSettings.port)
                                    onCurrentTextChanged: mSettings.port = currentText
                                }

                                ComboBox {
                                    id: mBaudComb
                                    Layout.preferredHeight: itemHeight
                                    Layout.fillWidth: true
                                    model: [115200, 230400, 460800, 921600, 1152000, 1500000]
                                    background: Rectangle {
                                        border.width: 1
                                        border.color: "lightgray"
                                    }
                                    delegate: ItemDelegate {
                                        width: mBaudComb.width
                                        height: itemHeight
                                        text: modelData
                                        background: null
                                    }
                                    currentIndex: find(
                                                      mSettings.baud.toString())
                                    onCurrentTextChanged: mSettings.baud = Number(
                                                              currentText)
                                }

                                Button {
                                    id: mDownloadButton
                                    Layout.preferredHeight: itemHeight
                                    text: qsTr("下载")
                                    onClicked: {
                                        if (state == "download") {
                                            var binFiles = new Object
                                            for (var i = 0; i < binFileCnt; i++) {
                                                if (mBinFiles.binFiles.binFiles[i].isChecked
                                                        && mBinFiles.binFiles.binFiles[i].addr
                                                        != "") {
                                                    binFiles[mBinFiles.binFiles.binFiles[i].addr]
                                                            = mBinFiles.binFiles.binFiles[i].file
                                                }
                                            }

                                            mEspFlasher.downloadImages(
                                                        binFiles,
                                                        mPortComb.currentText,
                                                        Number(
                                                            mBaudComb.currentText),
                                                        mFlashSize.flashSize,
                                                        mSpiSpeed.spiSpeed,
                                                        mSpiMode.spiMode)
                                            mOutPutsShowBtn.checked = true
                                            mChipInfoText.clear()
                                        } else {
                                            mEspFlasher.stop()
                                        }
                                    }

                                    state: "download"
                                    states: [
                                        State {
                                            name: "download"
                                            PropertyChanges {
                                                target: mDownloadButton
                                                text: "下载"
                                            }
                                        },
                                        State {
                                            name: "stop"
                                            PropertyChanges {
                                                target: mDownloadButton
                                                text: "停止"
                                            }
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    footer: ToolBar {
        width: parent.width
        height: itemHeight
        background: Rectangle {
            color: "transparent"
            border.width: 1
            border.color: "lightgray"
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: applicationWindow.padding
            anchors.rightMargin: anchors.leftMargin
            Text {
                id: mStatusText
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "空闲"
                verticalAlignment: Text.AlignVCenter
            }

            ToolSeparator {
                Layout.fillHeight: true
                orientation: Qt.Vertical
            }

            Text {
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.RichText
                text: "<a href=mailto:mengzawj@qq.com>发送邮件给作者</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    id: mMailMouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.PointingHandCursor
                }
                ToolTip.delay: 1000
                ToolTip.text: "mengzawj@qq.com"
                ToolTip.visible: mMailMouseArea.containsMouse
                ToolTip.timeout: 5000
            }

            ToolSeparator {
                Layout.fillHeight: true
                orientation: Qt.Vertical
            }

            Text {
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.RichText
                text: "<a href=\"http://www.todo.com\" target=\"_self\" title=\"wang\">www.todo.com</a>"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.PointingHandCursor
                }
            }

            ToolSeparator {
                Layout.fillHeight: true
                orientation: Qt.Vertical
            }

            Button {
                id: mOutPutsShowBtn
                Layout.fillHeight: true
                text: ">>"
                checkable: true
                background: Rectangle {
                    color: mOutPutsShowBtn.checked
                           | mOutPutsShowBtn.pressed ? "gray" : "transparent"
                }
                onCheckedChanged: {
                    if (checked) {
                        mCmdOutputsWindow.show()
                    } else {
                        mCmdOutputsWindow.close()
                    }
                }
            }
        }
    }
}
