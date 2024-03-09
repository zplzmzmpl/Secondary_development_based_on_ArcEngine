#include "Buffer.h"
#include "MapTypes.h"
#include "Map.h"
#include"ShapefileFeatureTable.h"
#include "MapQuickView.h"
#include "SimpleFillSymbol.h"
#include "SimpleMarkerSymbol.h"
#include "MapTypes.h"
#include "TaskWatcher.h"
#include "GraphicsOverlayListModel.h"
#include "GraphicListModel.h"
#include "SymbolTypes.h"
#include"GeometryEngine.h"
#include "GraphicsOverlay.h"
#include "SpatialReference.h"
#include "Point.h"
#include"PolylineBuilder.h"
#include"SimpleRenderer.h"
#include "SimpleLineSymbol.h"
#include"SketchEditor.h"
#include "Envelope.h"
#include"FeatureLayer.h"
#include "Graphic.h"
#include <QUrl>
#include<QtGui>
#include<QSqlDatabase>
#include<QSqlError>

using namespace Esri::ArcGISRuntime;

Point m1(114.610864, 30.461618,SpatialReference::wgs84());
Point m2(114.610435, 30.460700,SpatialReference::wgs84());
Point m3(114.611817, 30.460338,SpatialReference::wgs84());
Point m4(114.614057, 30.460042,SpatialReference::wgs84());
Point m5(114.614598, 30.461751,SpatialReference::wgs84());
Point m6(114.614967, 30.458762,SpatialReference::wgs84());
QVector<Point> vecPt;

Buffer::Buffer(QObject* parent /* = nullptr */):
    QObject(parent),
    m_map(new Map(BasemapStyle::OsmStandard, this))
{
    m_sketchOverlay = new GraphicsOverlay(this);
    createSymbols();
}

Buffer::~Buffer()
{
}

void Buffer::openSHP(QString filelist)
{
    qDebug()<<filelist;
    QString path=filelist.remove("file:///");
        ShapefileFeatureTable *mfeatureTable = new ShapefileFeatureTable(path, this);
        FeatureLayer* layer = new FeatureLayer(mfeatureTable, this);
        connect(layer, &FeatureLayer::doneLoading, this, [this, layer, mfeatureTable](Error loadError)
        {
            if (!loadError.isEmpty())
                return;
            GeometryType geoType = mfeatureTable->geometryType();
            if (geoType == GeometryType::Point) {
                // 点渲染
                SimpleMarkerSymbol* pointSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Diamond, QColor("red"), 10, this);
                SimpleRenderer *renderer = new SimpleRenderer(pointSymbol,this);
                layer->setRenderer(renderer);
            }
            if (geoType == GeometryType::Polyline) {
                // 线渲染
                SimpleLineSymbol* sls = new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor("yellow"), 5, this);
                SimpleRenderer *renderer = new SimpleRenderer(sls,this);
                layer->setRenderer(renderer);
            }
            if (geoType == GeometryType::Polygon) {
                // 面渲染
                SimpleFillSymbol* sfs = new SimpleFillSymbol(SimpleFillSymbolStyle::Solid, QColor(0, 0, 255, 80), this);
                SimpleRenderer *renderer = new SimpleRenderer(sfs,this);
                layer->setRenderer(renderer);
            }
            if(m_boolFirstLoad){
                m_boolFirstLoad = false;//将图层自动缩放至第一个shape所在位置
                m_mapView->setViewpointCenter(layer->fullExtent().center(), 80000);
            }
        });
        m_map->operationalLayers()->append(layer);

    m_boolFirstLoad = true;
}



void Buffer::clear()
{
    m_graphicsOverlayGeodesic->graphics()->clear();
    m_graphicsOverlayPlanar->graphics()->clear();
    m_graphicsOverlayPoints->graphics()->clear(); 
    lineoverlay->graphics()->clear();

}

void Buffer::locate()
{
        // 经纬度坐标
        Point pt(114.6127,30.4608,SpatialReference::wgs84());
        // 比例尺设置
        double scale = 30000.0;
        m_mapView->setViewpointCenter(pt, scale);

}

void Buffer::position()
{
    // start location display
       m_mapView->locationDisplay()->start();
       // center the location display around the device location
       m_mapView->locationDisplay()->setAutoPanMode(LocationDisplayAutoPanMode::Recenter);
}

void Buffer::zoomin()
{
    double cur_scale = m_mapView->currentViewpoint(ViewpointType::CenterAndScale).targetScale();
    cur_scale -= 100000.0;

    m_mapView->setViewpointScale(cur_scale);
}

void Buffer::zoomout()
{
    double cur_scale = m_mapView->currentViewpoint(ViewpointType::CenterAndScale).targetScale();
    cur_scale += 100000.0;

    m_mapView->setViewpointScale(cur_scale);
}

void Buffer::rotate()
{
    double cur_rotation = m_mapView->currentViewpoint(ViewpointType::CenterAndScale).rotation();
    cur_rotation += 30.0;

    m_mapView->setViewpointRotation(cur_rotation);
}

void Buffer::centermap()
{
    m_mapView->setViewpointRotation(0);
}


void Buffer::setSketchCreationMode(SampleSketchMode sketchCreationMode)
{
    switch(sketchCreationMode)
      {
        case SampleSketchMode::PointSketchMode:
          m_sketchEditor->start(SketchCreationMode::Point);
          break;

        case SampleSketchMode::MultipointSketchMode:
          m_sketchEditor->start(SketchCreationMode::Multipoint);
          break;

        case SampleSketchMode::PolylineSketchMode:
          m_sketchEditor->start(SketchCreationMode::Polyline);
          break;

        case SampleSketchMode::PolygonSketchMode:
          m_sketchEditor->start(SketchCreationMode::Polygon);
          break;

        default:
          break;
      }
    emit sketchEditorStartedChanged();
}

void Buffer::stopSketching(bool saveGeometry)
{
    if (!m_sketchEditor->isStarted() || !saveGeometry)
      {
        m_sketchEditor->stop();
        emit sketchEditorStartedChanged();
        return;
      }

      if (!m_sketchEditor->isSketchValid())
      {
        qWarning() << "Unable to save sketch. Sketch is not valid.";
        return;
      }

      // To save the sketch, create a graphic with the sketch's geometry before stopping the sketchEditor
      Geometry sketchGeometry = m_sketchEditor->geometry();
      Symbol* geometrySymbol = nullptr;

      switch (m_sketchEditor->creationMode())
      {
        case SketchCreationMode::Point:
          geometrySymbol = m_pointSymbol;
          break;

        case SketchCreationMode::Multipoint:
          geometrySymbol = m_multiPointSymbol;
          break;

        case SketchCreationMode::Polyline:
          geometrySymbol = m_lineSymbol;
          break;

        case SketchCreationMode::Polygon:
          geometrySymbol = m_polygonSymbol;
          break;

        default:
          return;
      }

      Graphic* sketchGraphic = new Graphic(sketchGeometry, geometrySymbol, this);

      m_sketchOverlay->graphics()->append(sketchGraphic);

      m_sketchEditor->stop();

      emit sketchEditorStartedChanged();
}

void Buffer::clearGraphics()
{
    m_sketchOverlay->graphics()->clear();
}

void Buffer::undo()
{
    m_sketchEditor->undo();
}

void Buffer::redo()
{
    m_sketchEditor->redo();
}

void Buffer::deleteVertex()
{
    if (m_sketchEditor->geometry().extent().isValid())
        m_sketchEditor->removeSelectedVertex();
}

bool Buffer::connectmysql()
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");
        db.setHostName("localhost");
        db.setPort(3306);
        db.setDatabaseName("s-l");
        db.setUserName("visitor");
        db.setPassword("cug12312");
        bool ok = db.open();

        return ok;
}

MapQuickView* Buffer::mapView() const
{
    return m_mapView;
}

// Set the view (created in QML)
void Buffer::setMapView(MapQuickView* mapView)
{
    if (!mapView || mapView == m_mapView)
    {
        return;
    }

    m_mapView = mapView;

    m_mapView->setAttributionTextVisible(false);

    m_mapView->setViewpointCenter(Point(114.5314, 30.3286, SpatialReference::wgs84()), 100'000);

    m_mapView->setMap(m_map);

    m_mapView->graphicsOverlays()->append(m_sketchOverlay);

    m_sketchEditor = new SketchEditor(this);

    m_mapView->setSketchEditor(m_sketchEditor);

    // add a graphics overlay for the geodesic buffer
      m_graphicsOverlayGeodesic = new GraphicsOverlay(this);
      m_mapView->graphicsOverlays()->append(m_graphicsOverlayGeodesic);

      // add a graphics overlay for the planar buffer
      m_graphicsOverlayPlanar = new GraphicsOverlay(this);
      m_mapView->graphicsOverlays()->append(m_graphicsOverlayPlanar);

      // add a graphics overlay for the mouse click
      m_graphicsOverlayPoints = new GraphicsOverlay(this);
      m_mapView->graphicsOverlays()->append(m_graphicsOverlayPoints);

      // create symbol for the geodesic buffer result
      SimpleLineSymbol* outlineGeodesic = new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor("red"), 2.0f /*width*/, this);
      SimpleFillSymbol* sfsGeodesic = new SimpleFillSymbol(SimpleFillSymbolStyle::Solid, QColor(255, 0, 0, 122), outlineGeodesic, this);
      m_graphicsOverlayGeodesic->setRenderer(new SimpleRenderer(sfsGeodesic, this));

      // create symbol for the planar buffer result
      SimpleLineSymbol* outlinePlanar = new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor("blue"), 2.0f /*width*/, this);
      SimpleFillSymbol* sfsPlanar = new SimpleFillSymbol(SimpleFillSymbolStyle::Solid, QColor(0, 0, 255, 122), outlinePlanar, this);
      m_graphicsOverlayPlanar->setRenderer(new SimpleRenderer(sfsPlanar, this));

      // create symbol for the mouse click
      SimpleMarkerSymbol* sms = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Cross, QColor("white"), 14.0f /*width*/, this);
      m_graphicsOverlayPoints->setRenderer(new SimpleRenderer(sms, this));

      // connect to mouse clicked signal

      connect(m_mapView, &MapQuickView::mouseClicked, this, &Buffer::onMouseClicked);

      overlay = new GraphicsOverlay(this);

      lineoverlay = new GraphicsOverlay(this);

      createGraphics(overlay);

      //showtrace(overlay);

      m_mapView->graphicsOverlays()->append(overlay);

      emit mapViewChanged();
}

int Buffer::bufferSize() const
{
    return m_bufferSize;
}

void Buffer::setBufferSize(int size)
{
    if (size == m_bufferSize)
        return;

    m_bufferSize = size;
}

void Buffer::onMouseClicked(QMouseEvent &mouse)
{
    //qDebug()<<clickornot;
    if(clickornot){
    // get the map point from the mouse click
      const Point point = m_mapView->screenToLocation(mouse.pos().x(), mouse.pos().y());

      // Create a variable to be the buffer size in meters. There are 1609.34 meters in one mile.
      const int bufferInMeters = bufferSize();

      // Create a planar buffer graphic around the input location at the specified distance.
      const Geometry buffer = GeometryEngine::buffer(point, bufferInMeters);

      // Add the result planar buffer as a graphic
      Graphic* resultGraphicPlanar = new Graphic(buffer, this);
      m_graphicsOverlayPlanar->graphics()->append(resultGraphicPlanar);

      // Create a geodesic buffer graphic around the input location at the specified distance.
      const Geometry bufferGeodesic = GeometryEngine::bufferGeodetic(point, bufferInMeters, LinearUnit(LinearUnitId::Meters), NAN, GeodeticCurveType::Geodesic);

      // Add the result geodesic buffer as a graphic
      Graphic* resultGraphicGeodesic = new Graphic(bufferGeodesic, this);

      m_graphicsOverlayGeodesic->graphics()->append(resultGraphicGeodesic);

      // Add the clicked point as a graphic
      Graphic* clickedPointGraphic = new Graphic(point, this);

      m_graphicsOverlayPoints->graphics()->append(clickedPointGraphic);
    }
}

bool Buffer::bufClick() const
{
    return clickornot;
}
void Buffer::setbufClick(bool q)
{
    clickornot=q;
}

void Buffer::createGraphics(Esri::ArcGISRuntime::GraphicsOverlay *overlay)
{
    vecPt.push_back(m1);
    vecPt.push_back(m2);
    vecPt.push_back(m3);
    vecPt.push_back(m4);
    vecPt.push_back(m5);
    vecPt.push_back(m6);

    // Create symbols for the point
    SimpleLineSymbol* point_outline = new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor("blue"), 3, this);
    SimpleMarkerSymbol* point_symbol = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Circle, QColor("red"), 6, this);
    point_symbol->setOutline(point_outline);

    // Create a graphic to display the point with its symbology
    Graphic* p1 = new Graphic(m1, point_symbol, this);
    Graphic* p2 = new Graphic(m2, point_symbol, this);
    Graphic* p3 = new Graphic(m3, point_symbol, this);
    Graphic* p4 = new Graphic(m4, point_symbol, this);
    Graphic* p5 = new Graphic(m5, point_symbol, this);
    Graphic* p6 = new Graphic(m6, point_symbol, this);

    // Add point graphic to the graphics overlay
    overlay->graphics()->append(p1);
    overlay->graphics()->append(p2);
    overlay->graphics()->append(p3);
    overlay->graphics()->append(p4);
    overlay->graphics()->append(p5);
    overlay->graphics()->append(p6);

}

void Buffer::showtrace()
{

    PolylineBuilder* polyline_builder = new PolylineBuilder(SpatialReference::wgs84(), this);

    for(const auto &i:vecPt)
    {
        polyline_builder->addPoint(i);
    }

    // Create a graphic to display the line with its symbology
    Graphic* polyline_graphic = new Graphic(polyline_builder->toGeometry(), m_lineSymbol, this);

    // Add line graphic to the graphics overlay
    lineoverlay->graphics()->append(polyline_graphic);

    m_mapView->graphicsOverlays()->append(lineoverlay);

}



void Buffer::createSymbols()
{
    m_pointSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Square, QColor(255, 0, 0), 10, this);
      m_multiPointSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbolStyle::Square, QColor(0, 0, 255), 10, this);
      m_lineSymbol = new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor(204, 10, 10), 3, this);
      m_polygonSymbol = new SimpleFillSymbol(SimpleFillSymbolStyle::Solid, QColor(67, 166, 198, 119),
                                             new SimpleLineSymbol(SimpleLineSymbolStyle::Solid, QColor(67, 166, 198), 2.0, this), this);

}

bool Buffer::sketchEditorStarted() const
{
    if (m_sketchEditor)
        return m_sketchEditor->isStarted();

      return false;
}


