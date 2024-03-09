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
import QtQuick.Layouts 1.12
import Qt.labs.platform 1.0 as PlatFrom
import Esri.Buffer 1.0

ApplicationWindow
{
    visible: true
    width: 800
    height: 600
    id: root
    title:"mymap"

    property bool unfold: false
    property int pos:0
    property int selectTopPadding: 15
    property int selectBottomPadding: 15
    property int selectSpacing: 5
    property int selectCompomonetHeight: 45
    property bool login_check: false
    property string username:"" 
    property string password:""
    property var videoPath:[]
    property int len : 0
    property string tip:""
    property var tips:["success!","failed!","videos limited to 6!"]

    menuBar: MenuBar{
        height: 30
        background: Rectangle{
                   anchors.fill: parent
                   color: "#f5f5f5"
                   opacity: 0.8
               }
        Menu{
            title: qsTr("&File")
            width: 100
            MenuItem{
                text: "open video"
                onTriggered: videoOpen.open()
            }
            MenuItem{
                text: "save"
            }
            MenuItem{
                text: "exit"
                onTriggered: Qt.quit()
            }
        }
        Menu{
            title: qsTr("&Edit")

            width:100
            MenuItem{
                text: "point"
                icon.source: "point-32.png"
            }
            MenuItem{
                text: "line"
                icon.source: "line-32.png"
            }
            MenuItem{
                text: "polygon"
                icon.source: "polygon-32.png" 
            }
        }
        Menu{
            title:qsTr("&Help")
            width: 100
            MenuItem{
                text:"website"
                onTriggered: Qt.openUrlExternally("https://www.bilibili.com/")
            }
            MenuItem{
                text:"contact us"
                onTriggered: contacthint.open()
            }
        }
    }

    PlatFrom.FileDialog{
        id:videoOpen
        title:"upload monitor video"
        nameFilters: "video(*.mp4 *.avi *.wmv *.mov *.webm)"
        acceptLabel: "confirm"
        rejectLabel: "cancel"
        fileMode: PlatFrom.FileDialog.OpenFiles
        onAccepted: {

            for (var i in files) {
                if(len>6)
                {
                    tip=tips[2]
                    hint.open()
                }
                else
                    {
                    videoPath[len+Number(i)]=files[i]
                    //console.log(files[i])
                }
            }
            len=videoPath.length
            //console.log(len)
        }
    }

    header: ToolBar {
        background: Rectangle{
                   anchors.fill: parent
                   color: "#f5f5f5"
                   opacity: 0.8
               }
            RowLayout {
                anchors.fill: parent
                ToolButton {
                    text: qsTr("\u25C0")
                    enabled: stackview.depth>1
                    onClicked:stackview.pop()
                    background:Rectangle{
                        anchors.fill: parent
                        color: "#f5f5f5"
                        opacity: 0.8
                    }
                }
                ToolSeparator{}
                Label {
                    text: stackview.currentItem.title
                    font{
                        family: "微软雅黑"
                        pixelSize: 20
                    }

                    elide: Label.ElideRight
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }
                ToolSeparator{}
                ToolButton {
                    icon.source: login_check?"accept.png":"login.png"
                    enabled: login_check==false
                    onClicked:
                    {
                        popup.open()
                    }
                    background:Rectangle{
                        anchors.fill: parent
                        color: "#f5f5f5"
                        opacity: 0.8
                    }
                }
        }
    }

    Popup{
        id:contacthint
        anchors.centerIn: parent
        width:300
        height: 250
        opacity: 0.7
        ColumnLayout
        {
            anchors.centerIn: parent
            Label{
                id:lab1
                text: "PLEASE CONTACT US BY E-MAIL"
                font{
                    family: "Arial Black"
                    pixelSize: 14
                }
            }
            Label{
                id:lab2
                Layout.alignment: Qt.AlignHCenter
                text: "3110837313@qq.com"
                font{
                    family: "Arial Black"
                    pixelSize: 14
                }
            }
        }
        contentItem: Rectangle {
                width: parent.width
                height: parent.height
                color: "#f5f5f5"
                opacity: 0.7
                border.color: "black"
                border.width: 2
                radius: 10 // set the radius to 10 pixels
            }
    }

    Popup{
        id:popup
        anchors.centerIn: parent
        modal: true
        opacity: 0.5
        width:300
        height: 400
        closePolicy:Popup.CloseOnEscape | Popup.CloseOnPressOutside
        enter: Transition {
                NumberAnimation { property: "opacity"; from: 0.0; to: 0.8 }
            }
        contentItem: Rectangle {
                width: parent.width
                height: parent.height
                color: "#f5f5f5"
                opacity: 0.6
                border.color: "black"
                border.width: 2
                radius: 10 // set the radius to 10 pixels
            }
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10
                Text {
                    text: qsTr("user name:")
                    font{
                        family: "Arial Black"
                        pixelSize: 14
                    }
                }
                TextField{
                    id:user
                    selectByMouse: true

                    onTextChanged: username=text
                    opacity: 0.8
                }

                Text {
                    text: qsTr("password:")
                    font{
                        family: "Arial Black"
                        pixelSize: 14
                    }
                }
                TextField{
                    id:pas
                    selectByMouse: true

                    onTextChanged: password=text
                    echoMode: TextField.Password
                    opacity: 0.8
                }

                Button{
                    id:enter
                    Layout.alignment: Qt.AlignHCenter
                    contentItem: Rectangle {
                            width: parent.width
                            height: parent.height
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("LOG IN")
                                font{
                                    family: "Arial Black"
                                    pixelSize: 14
                                }
                            }
                            color: "#f5f5f5"
                            border.color: "black"
                            border.width: 2
                            radius: 5
                        }
                    onClicked: checkLog()
                  }
        }

    }

    function checkLog()
    {
        if(username=="visitor001"&&password=="cug12312")
        {
            popup.close()
            tip=tips[0]
            hint.open()
            login_check=true
        }
        else{
            tip=tips[1]
            hint.open()
        }

    }

    Popup{
        id:hint
        width: 300
        height: 300
        opacity: 0.7
        anchors.centerIn: parent
        modal: true
        contentItem: Rectangle {
                width: parent.width
                height: parent.height
                opacity: 0.7
                color: "#f5f5f5"
                border.color: "black"
                border.width: 2
                radius: 10 // set the radius to 10 pixels
            }
        Label{
            text: tip
            anchors.centerIn: parent
            font{
                family: "Arial Black"
                pixelSize: 24
            }
        }
    }


    Monitor{
        visible: false
    }

    StackView{
        id:stackview
        anchors.fill: parent
        initialItem: Home{}
    }
}
