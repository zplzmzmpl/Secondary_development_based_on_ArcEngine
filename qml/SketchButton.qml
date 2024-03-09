import QtQuick 2.12

import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3


RoundButton {
    id: sketchEditorButton

    property int columnSpan: 1
    property string buttonName: ""
    property string iconPath: ""
    property int images: 1

    Layout.fillWidth: true
    Layout.columnSpan: columnSpan
    radius: 5

    // Set the focus policy so that the buttons do not take focus from the MapView
    focusPolicy: Qt.NoFocus

    Image {
        id: imgComponent
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -textComponent.height/2
        }
        source: iconPath
        width: 20
        fillMode: Image.PreserveAspectFit
        visible: images === 1
    }

    Image {
        id: imgComponentLeft
        anchors {
            right: parent.horizontalCenter
            rightMargin: -imgComponentRight.width/5
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -textComponent.height/2 - 2
        }
        source: iconPath
        width: 20
        fillMode: Image.PreserveAspectFit

        visible: images === 2
    }

    Image {
        id: imgComponentRight
        anchors {
            left: parent.horizontalCenter
            leftMargin: -imgComponentLeft.width/5
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -textComponent.height/2
        }
        source: iconPath
        width: 20
        fillMode: Image.PreserveAspectFit

        visible: images === 2
    }

    Text {
        id: textComponent
        anchors {
            top: images === 1 ? imgComponent.bottom : imgComponentRight.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text: buttonName
        font.pixelSize: 8
    }
}
