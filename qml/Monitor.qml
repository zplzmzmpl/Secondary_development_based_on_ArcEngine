import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtMultimedia 5.9
Page {
    title: "MonitorView"

    ComboBox {
            id: control
            width: parent.width
            height: 40
            model: ["tunnel_1", "tunnel_2", "tunnel_3","tunnel_4","tunnel_5","tunnel_6"]
            onCurrentIndexChanged: {
                switch(control.currentIndex)
                {
                case 0:
                    mediaPlayer.source=Qt.resolvedUrl(videoPath[0])
                    break
                case 1:
                    mediaPlayer.source=Qt.resolvedUrl(videoPath[1])
                    break
                case 2:
                    mediaPlayer.source=Qt.resolvedUrl(videoPath[2])
                    break
                case 3:
                    mediaPlayer.source=Qt.resolvedUrl(videoPath[3])
                    break
                case 4:
                    mediaPlayer.source=Qt.resolvedUrl(videoPath[4])
                    break
                case 5:
                    mediaPlayer.source=Qt.resolvedUrl(videoPath[5])
                    break
                }

            }

            delegate: ItemDelegate {
                width: control.width
                contentItem: Text {
                    text: modelData
                    color: "black"
                    font: control.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: control.highlightedIndex === index

                required property int index
                required property var modelData
            }

            indicator: Canvas {
                id: canvas
                x: control.width - width - control.rightPadding
                y: control.topPadding + (control.availableHeight - height) / 2
                width: 12
                height: 8
                contextType: "2d"

                Connections {
                    target: control
                    function onPressedChanged() { canvas.requestPaint()}
                }

                onPaint: {
                    context.reset()
                    context.moveTo(0, 0)
                    context.lineTo(width, 0)
                    context.lineTo(width / 2, height)
                    context.closePath()
                    context.fillStyle = control.pressed ? "black" : "darkgray"
                    context.fill()
                }
            }

            contentItem: Text {
                leftPadding: 0
                rightPadding: control.indicator.width + control.spacing

                text: control.displayText
                font: control.font
                color: control.pressed ? "black" : "darkgray"
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 120
                implicitHeight: 40
                border.color: control.pressed ? "black" : "darkgray"
                border.width: control.visualFocus ? 2 : 1
                radius: 2
            }

            popup: Popup {
                y: control.height - 1
                width: control.width
                implicitHeight: contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: control.popup.visible ? control.delegateModel : null
                    currentIndex: control.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    border.color: "darkgray"
                    radius: 2
                }
            }
        }
    Rectangle{
        id:mainpage
        anchors{
            top:control.bottom
            topMargin: 5
            left: parent.left
            right: parent.right
            bottom: progressRow.top
        }
        MediaPlayer{
                id:mediaPlayer
                audioRole: MediaPlayer.VideoRole
                onError: {
                    console.log(errorString)
                }
            }
            VideoOutput{
                anchors.fill: parent
                source: mediaPlayer
                //flushMode: VideoOutput.LastFrame;
            }
    }


        //播放按钮
        Rectangle {
            id: startButton
            property bool isPlay: false
            width: parent.width / 4
            height: width
            anchors.centerIn: parent
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    if (mediaPlayer.playbackState !== Audio.PlayingState) {
                        mediaPlayer.play()
                        imageForStart.visible=false
                    } else {
                        mediaPlayer.pause()
                        imageForStart.visible=true
                    }
                }
            }
            Image {
                id: imageForStart
                visible: true
                anchors.centerIn: parent
                width: parent.width - 5
                height: parent.height - 5

                source: "pause.png"
            }
        }
       //进度条和静音按钮
        Rectangle {
            id: progressRow
            visible: true
            height: parent.height / 9
            anchors{left: parent.left
                right: parent.right
                bottom: parent.bottom}
            color: "transparent"

            Text {
                id: durationTime
                anchors{verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 10}
                color: "black"
                font{pointSize: 12
                    family: "PingFang SC"
                    weight: Font.Medium}
                text: {
                    var milliseconds = mediaPlayer.position
                    var minutes = Math.floor(milliseconds / 60000)
                    milliseconds -= minutes * 60000
                    var seconds = milliseconds / 1000
                    seconds = Math.round(seconds)
                    if (seconds < 10)
                        return minutes + ":0" + seconds
                    else
                        return minutes + ":" + seconds
                }
            }

            Slider {
                id: durationTimeSlider
                height: parent.height
                anchors{verticalCenter: parent.verticalCenter
                    left: durationTime.right; leftMargin: 10;
                   right: endTime.left
                   rightMargin: 10}
                value: mediaPlayer.position / mediaPlayer.duration

                background: Rectangle {
                    x: durationTimeSlider.leftPadding
                    y: durationTimeSlider.topPadding
                       + durationTimeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 4
                    width: durationTimeSlider.availableWidth
                    height: implicitHeight
                    radius: 2
                    color: "#bdbebf"

                    Rectangle {
                        width: durationTimeSlider.visualPosition * parent.width
                        height: parent.height
                        color: "red"
                        radius: 2
                    }
                }

                handle: Rectangle {
                    antialiasing: true
                    x: durationTimeSlider.leftPadding + durationTimeSlider.visualPosition
                       * (durationTimeSlider.availableWidth - width)
                    y: durationTimeSlider.topPadding
                       + durationTimeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 15
                    implicitHeight: 15
                    radius: 10
                    //color: durationTimeSlider.pressed ? "#f0f0f0" : "#f6f6f6"
                    border.width: durationTimeSlider.pressed ? 3 : 2
                    border.color: durationTimeSlider.pressed ? "silver" : "#bdbebf"
                    Rectangle {
                        width: 4
                        height: 4
                        radius: 2
                        color: "red"
                        anchors.centerIn: parent
                    }
                }
                property real index: 0
                property bool changed: false
                onMoved: {
                    if (pressed) {
                        index = position
                    }
                }
                onPressedChanged: {
                    if (pressed === true) {
                        changed = true
                    } else if (changed === true) {
                        mediaPlayer.seek(index * mediaPlayer.duration)
                        changed = false
                    }
                }
            }

            Text {
                id: endTime;
                anchors{verticalCenter: parent.verticalCenter
                    right: volumeBtn.left
                    rightMargin: 5}
                color: "black"
                font{pointSize: 12
                    family: "PingFang SC"
                    weight: Font.Medium}
                text: {
                    var milliseconds = mediaPlayer.duration.valueOf()
                    var minutes = Math.floor(milliseconds / 60000)
                    milliseconds -= minutes * 60000
                    var seconds = milliseconds / 1000
                    seconds = Math.round(seconds)
                    if (seconds < 10)
                        return minutes + ":0" + seconds
                    else
                        return minutes + ":" + seconds /*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               return m + ":" + s*/
                }
            }
            Rectangle {
                id: volumeBtn
                width: 25
                height: 25
                color: "#00000000"
                anchors{right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter}
                Image {
                    id: voiceImage
                    anchors.fill: parent
                    source: mediaPlayer.muted ? "vlooff.png" : "volume.png"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mediaPlayer.muted = !mediaPlayer.muted
                    }
                }
            }

        }



}
