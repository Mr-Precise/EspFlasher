import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.0

RadioDelegate {
    id: mItemRoot
    leftPadding: rightPadding + indicator.width + 5
    autoExclusive: true
    background: null
    indicator: Rectangle {
        implicitWidth: mItemRoot.height * 0.618
        implicitHeight: implicitWidth
        anchors.left: parent.left
        anchors.leftMargin: mItemRoot.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        radius: width / 2
        border.color: mItemRoot.down ? "#17a81a" : "#21be2b"

        Rectangle {
            width: parent.width * 0.618
            height: width
            anchors.centerIn: parent
            radius: width / 2
            color: mItemRoot.down ? "#17a81a" : "#21be2b"
            visible: mItemRoot.checked
        }
    }
    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        text: mItemRoot.text
    }
}
