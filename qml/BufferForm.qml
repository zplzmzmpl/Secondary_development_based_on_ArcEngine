// Copyright 2023 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Esri.Buffer 1.0

Item {

    // display a control pane to change size

    //menu area---------------------------------------------------------------------------------------
    Rectangle{

        id: barRect
        width: unfold ? 200 : 64
        height: root.selectBottomPadding +
                root.selectBottomPadding +
                appModel.count * root.selectCompomonetHeight +
                (appModel.count-1) * root.selectSpacing
        radius: 10
        opacity: 0.8
        anchors{
            left: parent.left
            top: controlColumn.bottom
            margins: 10
        }

        color: "#f5f5f5"
        clip: true

        Behavior on width{
            NumberAnimation{duration: 300;}
        }

        ListModel{
            id: appModel
            ListElement{
                name: "Face"
                icon: "face.png"
            }
            ListElement{
                name: "Monitor"
                icon: "monitor.png"
            }
            ListElement{
                name: "Tool"
                icon: "tool.png"
            }
        }

        Component{
            id: appDelegate
            Rectangle {
                id: delegateBackground
                width: barRect.width
                height: root.selectCompomonetHeight
                radius: 5
                color: "#00000000"
                //显示图标
                Image {
                    id: imageIcon
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    mipmap: true
                    source: icon
                }
                //显示APP文字
                Text {
                    anchors.left: imageIcon.right
                    anchors.leftMargin: 40
                    anchors.verticalCenter: imageIcon.verticalCenter
                    color: "black"
                    text: name
                    font{family: "微软雅黑"
                        pixelSize: 20}
                }
                //鼠标处理
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        pos=index
                        switch(pos)
                        {
                        case 0:
                            if(login_check==true)
                            stackview.push("Face.qml")
                            else
                                loghint.open()
                            break
                        case 1:
                            if(login_check==true)
                            stackview.push("Monitor.qml")
                            else
                                loghint.open()
                            break
                        case 2:
                            drawer.open()
                            break
                        }
                    }
                    onEntered: delegateBackground.color = "#10000000"
                    onExited: delegateBackground.color = "#00000000"
                }
            }
        }




        Column{
            anchors.fill: parent
            spacing: root.selectSpacing
            topPadding: root.selectTopPadding
            bottomPadding: root.selectBottomPadding
            opacity: 0.8
            Repeater{
                model: appModel
                delegate: appDelegate
            }

        }

    }

    // 展开/收回按钮
    Rectangle{
        width: 34
        height: width
        radius: width/2
        color: "#f5f5f5"
        anchors.left: barRect.right
        anchors.leftMargin: -width/2
        anchors.verticalCenter: barRect.verticalCenter
        Image {
            width: 24
            height: 24
            anchors.centerIn: parent
            mipmap: true
            //此处使用旋转180度实现展开按钮图标和收回按钮图标
            rotation: unfold? 180:0
            source: "expand.png"
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                unfold = !unfold
            }
        }
    }

        Rectangle {
            anchors {
                margins: -5
                fill: controlColumn
            }
            color: "lightgray"
            radius: 5
            opacity: 0.5
            border {
                color: "darkgray"
                width: 1
            }
        }

        Column {
            id: controlColumn
            opacity: 0.8
            anchors {
                left: parent.left
                top: parent.top
                margins: 10
            }
            spacing: 5

            Text {
                text: "Buffer size (meters):"
            }

            TextField {
                id: bufferSizeText
                selectByMouse: true
                validator: IntValidator { bottom: 1; top: 10000 }
                text: "1000"
                opacity: 0.7
                onTextChanged: model.bufferSize = Number(text);
            }

            Row {
                spacing: 10

                Rectangle {
                    radius: 100
                    width: 15
                    height: width
                    color: "blue"
                    opacity: 0.7
                }

                Text {
                    text: "Planar Buffer"
                }
            }

            Row {
                spacing: 10

                Rectangle {
                    radius: 100
                    width: 15
                    height: width
                    color: "red"
                    opacity: 0.8
                }

                Text {
                    text: "Geodesic Buffer"
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Clear"
                opacity: 0.8
                onClicked: {
                    model.clear();
                }
            }
        }


}
