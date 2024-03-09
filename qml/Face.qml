import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Esri.Buffer 1.0

Page {
    title: "FaceView"
    property int sqe: 3
        Image {
                    id: image
                    asynchronous: true  //加载网络图片默认为true  表示是否在单独的线程中异步加载本地文件系统上的图像
                    cache: false    //指定是否应该缓存图像 大般大型图像设置为false
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop  //填充模式为缩放但不裁剪
                    source:"file:///E:/Qt/qt5152/myfile/Buffer/qml/face003.jpg"

                    Grid{
                        id:func
                        topPadding: 20
                        leftPadding: 10
                        spacing: 15
                        anchors{
                            right: image.right
                        }

                        RoundButton{
                            id:pre
                            icon.source: "pre.png"
                            opacity: 0.5                           
                            hoverEnabled: true
                            onClicked: {
                                image.source="file:///E:/Qt/qt5152/myfile/Buffer/qml/face00"+(Math.abs(--sqe)%6).toString()+".jpg"
                                //console.log(sqe)
                            }

                        }

                        RoundButton{
                            //objectName: "trace"
                            id:showtrace
                            icon.source: "accept.png"
                            opacity: 0.5
                            hoverEnabled: true
                            onClicked: stackview.pop()
                            }


                        RoundButton{
                            id:next
                            opacity: 0.5
                            icon.source: "next.png"
                            hoverEnabled: true
                            onClicked:
                            {
                                image.source="file:///E:/Qt/qt5152/myfile/Buffer/qml/face00"+(Math.abs(++sqe)%6).toString()+".jpg"
                                //console.log(sqe)
                            }

                        }
                    }
                }


}
