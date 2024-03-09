#-------------------------------------------------
#  Copyright 2023 ESRI
#
#  All rights reserved under the copyright laws of the United States
#  and applicable international laws, treaties, and conventions.
#
#  You may freely redistribute and use this sample code, with or
#  without modification, provided you include the original copyright
#  notice and use restrictions.
#
#  See the Sample code usage restrictions document for further information.
#-------------------------------------------------

TEMPLATE = app

CONFIG += c++14

# additional modules are pulled in via arcgisruntime.pri
QT += qml quick
QT += sql
TARGET = Buffer

equals(QT_MAJOR_VERSION, 5) {
    lessThan(QT_MINOR_VERSION, 15) {
        error("$$TARGET requires Qt 5.15.2")
    }
	equals(QT_MINOR_VERSION, 15) : lessThan(QT_PATCH_VERSION, 2) {
		error("$$TARGET requires Qt 5.15.2")
	}
}

ARCGIS_RUNTIME_VERSION = 100.15.1
include($$PWD/arcgisruntime.pri)

HEADERS += \
    Buffer.h \
    face_recog.h

SOURCES += \
    face_recog.cpp \
    main.cpp \
    Buffer.cpp

RESOURCES += \
    qml/qml.qrc \
    Resources/Resources.qrc

#-------------------------------------------------------------------------------

win32 {
    include (Win/Win.pri)
}

macx {
    include (Mac/Mac.pri)
}

ios {
    include (iOS/iOS.pri)
}

android {
    include (Android/Android.pri)
}

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../../opencv/opencv/build/x64/vc14/lib/ -lopencv_world460
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../../opencv/opencv/build/x64/vc14/lib/ -lopencv_world460

INCLUDEPATH += $$PWD/../../../../opencv/opencv/build/include
DEPENDPATH += $$PWD/../../../../opencv/opencv/build/include

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../../dlib-19.24/install/lib/ -ldlib19.24.0_release_64bit_msvc1929
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../../dlib-19.24/install/lib/ -ldlib19.24.0_release_64bit_msvc1929d

INCLUDEPATH += $$PWD/../../../../dlib-19.24/install/include
DEPENDPATH += $$PWD/../../../../dlib-19.24/install/include
