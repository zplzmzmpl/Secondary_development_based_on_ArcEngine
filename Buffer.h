// [WriteFile Name=Buffer, Category=Geometry]
// [Legal]
// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

#ifndef BUFFER_H
#define BUFFER_H

#include "Graphic.h"
namespace Esri
{
namespace ArcGISRuntime
{
class Map;
class Graphic;
class MapQuickView;
class SketchEditor;
class GraphicsOverlay;
class SimpleMarkerSymbol;
class SimpleLineSymbol;
class SimpleFillSymbol;
}
}

#include <QObject>
#include <QMouseEvent>

//Q_MOC_INCLUDE("MapQuickView.h");

class Buffer : public QObject
{
  Q_OBJECT
  Q_PROPERTY(Esri::ArcGISRuntime::MapQuickView* mapView READ mapView WRITE setMapView NOTIFY mapViewChanged)
  Q_PROPERTY(int bufferSize READ bufferSize WRITE setBufferSize NOTIFY bufferSizeChanged)
  Q_PROPERTY(bool bufClick READ bufClick WRITE setbufClick NOTIFY bufClickChanged)
  Q_PROPERTY(bool sketchEditorStarted READ sketchEditorStarted NOTIFY sketchEditorStartedChanged)

public:
  explicit Buffer(QObject* parent = nullptr);

   Q_INVOKABLE void openSHP(QString filelist);
   Q_INVOKABLE void clear();//can be invoked by qml file;
   Q_INVOKABLE void locate();
   Q_INVOKABLE void position();
   Q_INVOKABLE void zoomin();
   Q_INVOKABLE void zoomout();
   Q_INVOKABLE void rotate();
   Q_INVOKABLE void centermap();
   Q_INVOKABLE void showtrace();
   Q_INVOKABLE bool connectmysql();



    enum class SampleSketchMode {
        PointSketchMode,
        MultipointSketchMode,
        PolylineSketchMode,
        PolygonSketchMode
      };

      Q_ENUM(SampleSketchMode)

      static void init();
      Q_INVOKABLE void setSketchCreationMode(Buffer::SampleSketchMode sketchCreationMode);
      Q_INVOKABLE void stopSketching(bool saveGeometry);
      Q_INVOKABLE void clearGraphics();
      Q_INVOKABLE void undo();
      Q_INVOKABLE void redo();
      Q_INVOKABLE void deleteVertex();


    ~Buffer() override;
signals:
  void mapViewChanged();
  void bufferSizeChanged();
  void bufClickChanged();
  void sketchEditorStartedChanged();

private:
  Esri::ArcGISRuntime::MapQuickView* mapView() const;
  void setMapView(Esri::ArcGISRuntime::MapQuickView* mapView);
  int bufferSize() const;
  void setBufferSize(int size);
  void onMouseClicked(QMouseEvent& mouse);
  bool bufClick() const;
  void setbufClick(bool q);
  void createGraphics(Esri::ArcGISRuntime::GraphicsOverlay* overlay);




  void createConnections();
  void createSymbols();
  bool sketchEditorStarted() const;


  Esri::ArcGISRuntime::GraphicsOverlay* overlay = nullptr;
  Esri::ArcGISRuntime::GraphicsOverlay* lineoverlay = nullptr;
  Esri::ArcGISRuntime::GraphicsOverlay* m_sketchOverlay = nullptr;
  Esri::ArcGISRuntime::SketchEditor* m_sketchEditor = nullptr;
  Esri::ArcGISRuntime::Graphic* editingGraphic = nullptr;
  Esri::ArcGISRuntime::SimpleMarkerSymbol* m_pointSymbol = nullptr;
  Esri::ArcGISRuntime::SimpleMarkerSymbol* m_multiPointSymbol = nullptr;
  Esri::ArcGISRuntime::SimpleLineSymbol* m_lineSymbol = nullptr;
  Esri::ArcGISRuntime::SimpleFillSymbol* m_polygonSymbol = nullptr;

  Esri::ArcGISRuntime::Map* m_map = nullptr;
  Esri::ArcGISRuntime::MapQuickView* m_mapView = nullptr;
  Esri::ArcGISRuntime::GraphicsOverlay* m_graphicsOverlayPlanar = nullptr;
  Esri::ArcGISRuntime::GraphicsOverlay* m_graphicsOverlayGeodesic = nullptr;
  Esri::ArcGISRuntime::GraphicsOverlay* m_graphicsOverlayPoints = nullptr;

  int m_bufferSize = 1000;
  bool m_boolFirstLoad=false;
  bool clickornot=false;

};
#endif // BUFFER_H
