import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0 as PlatFrom
import Esri.Buffer 1.0

Page {

    title: "Mapview"

    // Create MapQuickView here, and create its Map etc. in C++ code
    MapView {
        id: view
        anchors.fill: parent
        // set focus to enable keyboard navigation
        focus: true

    }

    // Declare the C++ instance which creates the map etc. and supply the view
    Buffer {
        id: model
        mapView: view
    }

    enum DrawingModes {
            NotDrawing,
            Point,
            Multipoint,
            Line,
            Polygon
        }

    property int drawStatus: Home.DrawingModes.NotDrawing




    Switch{
        id:editStatus
        anchors.right:parent.right
        anchors.top:parent.top
        rightPadding: 10
        topPadding: 10
        onCheckedChanged: {
            editStatus.text = editStatus.checked ? "Begin Buffer" : "End Buffer"
            model.bufClick=editStatus.checked?true:false
        }
    }


    Drawer{
        id:drawer
        width: root.width*0.2
        height: root.height
        modal: true
        clip: true
        edge: Qt.RightEdge
        dragMargin: root*0.1
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle{
                   anchors.fill: parent
                   color: "lightgray"
                   opacity: 0.8
               }
        Column{
            anchors.fill: parent
            ItemDelegate{
                text: "Connect"
                icon.source: "connect.png"
                onClicked: checksql()
            }
            ItemDelegate{
                text: "Open Map"
                icon.source: "openmap.png"
                onClicked: {
                    fileOpenDialog.open()
                    drawer.close()
                }

            }
            ItemDelegate{
                text: "Locate"
                icon.source: "mylocation.png"
                onClicked: {
                    model.position()
                    drawer.close()
                }
            }
            ItemDelegate{
                text: "MapCenter"
                icon.source: "location.png"
                onClicked: {
                    model.locate()
                    //drawer.close()
                }
            }
            ItemDelegate{
                text: "Rotate"
                icon.source: "rotate.png"
                onClicked: {
                    model.rotate()
                    //drawer.close()
                }
            }
            ItemDelegate{
                text: "PanView"
                icon.source: "map.png"
                onClicked: {
                    model.centermap()
                    //drawer.close()
                }
            }
            ItemDelegate{
                text: "Zoom in"
                icon.source: "zoomin.png"
                onClicked: {
                    model.zoomin()
                    //drawer.close()
                }
            }
            ItemDelegate{
                text: "Zoom out"
                icon.source: "zoomout.png"
                onClicked: {
                    model.zoomout()
                    //drawer.close()
                }
            }
            ItemDelegate{
                text: "Trace"
                icon.source: "footprint.png"
                onClicked: {
                    if(login_check==true)
                    {
                        model.showtrace()
                        drawer.close()
                    }
                    else
                        loghint.open()
                }
            }    
        }

    }   

    function checksql()
    {
        if(login_check==true)
        {
            if(model.connectmysql()===true)
            suc_hint.open()
            else
                fal_hint.open()
        }
        else
        {
            loghint.open()
        }
    }

    Popup{
        id:loghint
        width: 400
        height: 300
        opacity: 0.7
        anchors.centerIn: parent
        Label{
            anchors.centerIn: parent
            text:"PLEASE CONTACT ADMINISTRATOR TO LOG IN"
            font{
                family: "Arial Black"
                pixelSize: 14
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

    PlatFrom.FileDialog{
        id:fileOpenDialog
        title: "slect shapefile"
        nameFilters: "shapefiles(*.shp)"
        onAccepted: model.openSHP((fileOpenDialog.currentFile).toString())
        }


    //buffer----------------------------

    BufferForm {
        anchors.fill: parent
    }

    //edit area-----------------------------------------------------------------------------------------------
    MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            enabled: model.sketchEditorStarted
            onClicked: {
                contextMenu.popup()
            }

            Menu {
                id: contextMenu
                width: actionComponent.width
                Action {
                    id: actionComponent
                    text: "Delete"
                    onTriggered: model.deleteVertex()
                }
            }
        }

        Control {
            id: control
            anchors.right: parent.right
            anchors.top: editStatus.bottom
            rightPadding: 20
            //padding: 5
            width: 300
            height: parent.height*0.5

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 5
                opacity: 0.5
                border {
                    color: "darkgray"
                    width: 1
                }
            }

            contentItem: ColumnLayout {
                id: columns
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 20

                GridLayout {
                    id: geometryColumn
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    columns: 2

                    Text {
                        id: geometryHeader
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.columnSpan: 2
                        text: "Geometry"
                        color: "black"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    SketchButton {
                        id: ptButton
                        buttonName: "Point"
                        iconPath: "point-32.png"

                        highlighted: drawStatus ===Home.DrawingModes.Point
                        enabled: !model.sketchEditorStarted

                        onClicked: {
                            model.setSketchCreationMode(Buffer.PointSketchMode)
                            drawStatus = Home.DrawingModes.Point
                        }
                    }

                    SketchButton {
                        id: mPtButton
                        buttonName: "Multipoint"
                        iconPath: "point-32.png"
                        images: 2

                        highlighted: drawStatus === Home.DrawingModes.Multipoint
                        enabled: !model.sketchEditorStarted

                        onClicked: {
                            model.setSketchCreationMode(Buffer.MultipointSketchMode);
                            drawStatus = Home.DrawingModes.Multipoint;
                        }
                    }

                    SketchButton {
                        id: lineButton
                        buttonName: "Line"
                        iconPath: "line-32.png"

                        highlighted: drawStatus === Home.DrawingModes.Line
                        enabled: !model.sketchEditorStarted

                        onClicked: {
                            model.setSketchCreationMode(Buffer.PolylineSketchMode);
                            drawStatus = Home.DrawingModes.Line;
                        }
                    }

                    SketchButton {
                        id: polygonButton
                        buttonName: "Polygon"
                        iconPath: "polygon-32.png"

                        highlighted: drawStatus === Home.DrawingModes.Polygon
                        enabled: !model.sketchEditorStarted

                        onClicked: {
                            model.setSketchCreationMode(Buffer.PolygonSketchMode);
                            drawStatus = Home.DrawingModes.Polygon;
                        }
                    }
                }

                GridLayout {
                    id: editingColumn
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    columns: 2

                    Text {
                        id: editingHeader
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.columnSpan: 2
                        text: "Editing"
                        color: "black"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    SketchButton {
                        id: undoButton
                        buttonName: "Undo"
                        iconPath: "undo-32.png"

                        enabled: model.sketchEditorStarted

                        onClicked: model.undo()
                    }

                    SketchButton {
                        id: redoButton
                        buttonName: "Redo"
                        iconPath: "redo-32.png"

                        enabled: model.sketchEditorStarted

                        onClicked: model.redo()
                    }

                    SketchButton {
                        id: deleteSelectedVertexButton
                        columnSpan: 2
                        buttonName: "Delete selected vertex"
                        iconPath: "erase-32.png"

                        enabled: model.sketchEditorStarted

                        onClicked: model.deleteVertex()
                    }

                    SketchButton {
                        id: saveEditsButton
                        columnSpan: 2
                        buttonName: "Save edits"
                        iconPath: "check-circle-32.png"

                        enabled: model.sketchEditorStarted

                        onClicked: {
                            model.stopSketching(true);
                            drawStatus = Home.DrawingModes.NotDrawing
                            if (!model.sketchEditorStarted && !clearGraphicsButton.enabled)
                                clearGraphicsButton.enabled = true
                        }
                    }

                    SketchButton {
                        id: discardEditsButton
                        columnSpan: 2
                        buttonName: "Discard edits"
                        iconPath: "circle-disallowed-32.png"

                        enabled: model.sketchEditorStarted

                        onClicked: {
                            model.stopSketching(false)
                            drawStatus = Home.DrawingModes.NotDrawing
                        }
                    }

                    SketchButton {
                        id: clearGraphicsButton
                        columnSpan: 2
                        buttonName: "Clear graphics"
                        iconPath: "trash-32.png"

                        enabled: false

                        onClicked: {
                            model.clearGraphics()
                            enabled = false
                        }
                    }
                }
            }
        }

}
