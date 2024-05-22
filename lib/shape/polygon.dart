import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import '../image.dart';
import 'line.dart';
import 'rectangle.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Polygon extends Shape {

  late List<Point> all_points;
  late List<Line> lines = []; 
  bool closed = false;
  
  bool isFillColor = false;
  bool isFillImage = false;

  Color? fillColor;
  ImageData? fillImage;
  Rectangle? clippingRectangle;

  Point? boundingTopLeft;
  Point? boundingBottomRight;

  Polygon(List<Point> all_points, int thickness, Color color, int id, Color fillColor) : super(all_points, thickness, color, id) {
    this.all_points = all_points;
    this.closed = false;
    this.id = id;
    this.fillColor = fillColor;
    // this.isFillColor = fillColor != null;
  }
  
  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {

    if (all_points.length < 2) {
      return; // 要素数が1未満の場合は処理をスキップ
    }

    for (var i = 0; i < all_points.length - 1; i++) {
      final point1 = all_points[i];
      final point2 = all_points[i + 1];
      drawEdge(point1, point2, pixels, size, isAntiAliased);
    }

    if (isClosed(all_points[0], all_points[all_points.length - 1])) {
      final point1 = all_points[all_points.length - 1];
      final point2 = all_points[0];
      drawEdge(point1, point2, pixels, size, isAntiAliased);

      // check filling option
      if (fillColor != null && isFillColor == true) {
        scanlineFill(pixels, size, (x, y) => fillColor!);
      }
      if (this.fillImage != null && this.isFillImage == true) {
        scanlineFill(pixels, size, (x, y) {
          final top = topLeft.dy;
          final left = topLeft.dx;
          final bottom = bottomRight.dy;
          final right = bottomRight.dx;

          var u = (x - left) / (right - left) * fillImage!.width;
          var v = (y - top) / (bottom - top) * fillImage!.height;

          if (u < 0) {
            u = 0;
          } else if (u >= fillImage!.width) {
            u = fillImage!.width - 1;
          }
          if (v < 0) {
            v = 0;
          } else if (v >= fillImage!.height) {
            v = fillImage!.height - 1;
          }
          return fillImage!.getPixel(u.toInt(), v.toInt());
        });
      }
    }

    if (clippingRectangle != null) {
      // List<Point> clippedPoints = clipPolygon(all_points, clippingRectangle!);
      // connectClippedEdges(clippedPoints, pixels, size, isAntiAliased);
      clipPolygon(all_points, clippingRectangle!);
      connectClippedEdges(all_points, pixels, size, isAntiAliased);
    }
  }
  
  // ---------- Clipping Algorithm ----------
  void clipPolygon(List<Point> points, Rectangle clippingRectangle) {
    List<Point> clippedPoints = [];
    for (int i = 0; i < points.length - 1; i++) {
      var clippedLine = cohenSutherlandClip(
        points[i].dx,
        points[i].dy,
        points[i + 1].dx,
        points[i + 1].dy,
        clippingRectangle.left,
        clippingRectangle.top,
        clippingRectangle.right,
        clippingRectangle.bottom,
      );
      if (clippedLine != null) {
        clippedPoints.add(Point(clippedLine[0], clippedLine[1]));
        clippedPoints.add(Point(clippedLine[2], clippedLine[3]));
      }
    }
    // return clippedPoints;
    this.all_points = clippedPoints; // Assign clipped points to all_points
  }

  // Cohen-Sutherland clipping algorithm constants (4 bits area code for location)
  static const int INSIDE = 0; // 0000
  static const int LEFT = 1;   // 0001
  static const int RIGHT = 2;  // 0010
  static const int BOTTOM = 4; // 0100
  static const int TOP = 8;    // 1000

  int computeOutCode(double x, double y, double left, double top, double right, double bottom) {
    int code = INSIDE;

    if (x < left) {
      code |= LEFT;
    } else if (x > right) {
      code |= RIGHT;
    }
    if (y < top) {
      code |= TOP;
    } else if (y > bottom) {
      code |= BOTTOM;
    }

    return code;
  }

  List<double>? cohenSutherlandClip(double x1, double y1, double x2, double y2,
                                    double left, double top, double right, double bottom) {
    int outcode0 = computeOutCode(x1, y1, left, top, right, bottom); // out code for start point
    int outcode1 = computeOutCode(x2, y2, left, top, right, bottom); // out code for end point
    bool accept = false;

    while (true) {
      if ((outcode0 | outcode1) == 0) {  // both points are inside
        accept = true;
        break;
      } else if ((outcode0 & outcode1) != 0) { // both points are outside 
        break;
      } else {
        double x, y;
        int outcodeOut = outcode0 != 0 ? outcode0 : outcode1;
        
        if ((outcodeOut & TOP) != 0) { // if the point is outside of TOP, then its y = top
          x = x1 + (x2 - x1) * (top - y1) / (y2 - y1);
          y = top;
        } else if ((outcodeOut & BOTTOM) != 0) { // if the point is outside of Bottom, then its y = bottom
          x = x1 + (x2 - x1) * (bottom - y1) / (y2 - y1);
          y = bottom;
        } else if ((outcodeOut & RIGHT) != 0) { // if the point is outside of Right, then its x = right
          y = y1 + (y2 - y1) * (right - x1) / (x2 - x1);
          x = right;
        } else { // if the point is outside of Left, then its x = left
          y = y1 + (y2 - y1) * (left - x1) / (x2 - x1);
          x = left;
        }

        // update the start point, end point and outcode
        if (outcodeOut == outcode0) {
          x1 = x;
          y1 = y;
          outcode0 = computeOutCode(x1, y1, left, top, right, bottom);
        } else {
          x2 = x;
          y2 = y;
          outcode1 = computeOutCode(x2, y2, left, top, right, bottom);
        }
      }
    }

    if (accept) {
      return [x1, y1, x2, y2];
    }
    return null;
  }

  void connectClippedEdges(List<Point> clippedPoints, Uint8List pixels, ui.Size size, bool isAntiAliased) {
    if (clippedPoints.length < 2) {
      return;
    }

    // draw edges bwetween connected points
    for (var i = 0; i < clippedPoints.length - 1; i++) {
      final point1 = clippedPoints[i];
      final point2 = clippedPoints[i + 1];
      drawEdge(point1, point2, pixels, size, isAntiAliased);
    }

    // close the polygon
    final point1 = clippedPoints[clippedPoints.length - 1];
    final point2 = clippedPoints[0];
    drawEdge(point1, point2, pixels, size, isAntiAliased);
  }

  Point get topLeft {
    double minX = all_points.map((p) => p.dx).reduce(math.min);
    double minY = all_points.map((p) => p.dy).reduce(math.min);
    return Point(minX, minY);
  }

  Point get bottomRight {
    double maxX = all_points.map((p) => p.dx).reduce(math.max);
    double maxY = all_points.map((p) => p.dy).reduce(math.max);
    return Point(maxX, maxY);
  }

  void drawEdge(Point point1, Point point2, Uint8List pixels, ui.Size size, bool isAntiAliased) {
    List<Point> linePoints = [
      point1,  
      point2 
    ];

    if(clippingRectangle == null){
      final line = Line(linePoints, thickness, color, -10); // id
      line.draw(pixels, size, isAntiAliased: isAntiAliased);
    } else {
      var lineClipping = cohenSutherlandClip(
        point1.dx,
        point1.dy,
        point2.dx,
        point2.dy,
        clippingRectangle!.left,
        clippingRectangle!.top,
        clippingRectangle!.right,
        clippingRectangle!.bottom,
      );
      if (lineClipping == null) {
        return;
      }
      List<Point> points = [Point(lineClipping[0], lineClipping[1]), Point(lineClipping[2], lineClipping[3])];
      final line = Line(points, this.thickness, this.color, -10);
      line.draw(pixels, size, isAntiAliased: isAntiAliased);
    }
  }
  // ------------------------------------------

  // ---------- Filling Algotithm -------------
  void scanlineFill(Uint8List pixels, ui.Size size, ui.Color Function(int x, int y) color) {

    // sorting the vertex by y (if y is the same, then x)
    List<int> sortedIndices = List<int>.generate(all_points.length, (i) => i);
    sortedIndices.sort((a, b) {
      int yCompare = all_points[a].dy.compareTo(all_points[b].dy);
      return yCompare == 0 ? all_points[a].dx.compareTo(all_points[b].dx) : yCompare;
    });

    List<EdgeEntry> aet = [];

    // iterate scan-line
    for (int y = 0; y < size.height.toInt(); y++) {

      // adding the edge
      while (sortedIndices.isNotEmpty && all_points[sortedIndices.first].dy.toInt() == y) {
        // remove current y achiving scan-line from the vertex list
        int currentIndex = sortedIndices.removeAt(0);
        int prevIndex = (currentIndex - 1 + all_points.length) % all_points.length;
        int nextIndex = (currentIndex + 1) % all_points.length;
        
        Point currentPoint = all_points[currentIndex];

        // if neighber vertexes are the under than the current one, add it to AET
        if (all_points[nextIndex].dy > currentPoint.dy) {
          aet.add(createEdge(all_points[currentIndex], all_points[nextIndex]));
        }
        if (all_points[prevIndex].dy > currentPoint.dy) {
          aet.add(createEdge(all_points[currentIndex], all_points[prevIndex]));
        }
      }

      // remove end edge and update x
      aet.removeWhere((edge) => edge.yMax.toInt() == y);
      for (var edge in aet) {
        edge.x += edge.dx;
      }

      // sort AET by x for the pair 
      aet.sort((a, b) => (a.x).compareTo(b.x));

      // fill between edges
      for (int i = 0; i < aet.length; i += 2) {
        int startX = aet[i].x.toInt();
        int endX = aet[i + 1].x.toInt();
        for (int x = startX; x <= endX; x++) {
          drawPixel(pixels, size, Point(x.toDouble(), y.toDouble()), color(x, y));
        }
      }
    }
  }

  EdgeEntry createEdge(Point start, Point end) {
    double dx = (end.dx - start.dx) / (end.dy - start.dy);
    return EdgeEntry(
      x: start.dx,
      yMax: end.dy,
      dx: dx,
    );
  }

  // ----------------------------------------------

  void rotate(Point centerPoint){
    print("Polygon rotate() is called\n");
    print("Center Point for the rotation: ${centerPoint}\n");

    // rotate 90 degrees for each call

    // x0 and y0 are the coordinates of the center of rotation 
    // x2 = cos(θ) * (x1 - x0) - sin(θ) * (y1 - y0) + x0
    // y2 = sin(θ) * (x1 - x0) - cos(θ) * (y1 - y0) + y0

    double cx = centerPoint.dx;
    double cy = centerPoint.dy;
    double angle = pi / 5;    // convert 90 degrees to radian 

    List<Point> rotatedPoints = [];

    for (var point in all_points) {
      double x = point.dx;
      double y = point.dy;

      double newX = cos(angle) * (x - cx) - sin(angle) * (y - cy) + cx;
      double newY = sin(angle) * (x - cx) + cos(angle) * (y - cy) + cy;

      rotatedPoints.add(Point(newX, newY));
    }

    this.all_points = rotatedPoints;
  }

  double calc_distance(Point point1, Point point2){
    return math.sqrt(math.pow(point1.dx - point2.dx, 2) + math.pow(point1.dy - point2.dy, 2));
  }

  bool isClosed(Point point1, Point point2){
    final distance = calc_distance(point1, point2);
    return distance <= 17;
  }

  @override
  bool isCenterPoint(Point tappedPoint){ 
    int crossings = 0;
    for (int i = 0; i < all_points.length; i++) {
      int next = (i + 1) % all_points.length; // Ensure loop back to start for last segment
      Point point1 = all_points[i];
      Point point2 = all_points[next];

      if (((point1.dy > tappedPoint.dy) != (point2.dy > tappedPoint.dy)) &&
          (tappedPoint.dx < (point2.dx - point1.dx) * (tappedPoint.dy - point1.dy) / (point2.dy - point1.dy) + point1.dx)) {
        crossings++;
      }
    }

    return (crossings % 2 != 0);
  }

  @override
  void movingVertex(Point originalPoint, Point newPoint, Color color, int thickness){
    this.color = color;
    this.thickness = thickness;

    for (var i = 0; i < this.all_points.length; i++) {
      final distance = (originalPoint - all_points[i]).distance;
      if (distance < 40) {  
        all_points[i] = newPoint;
        return;
      }
    }
  }

  @override
  void movingShape(Point originalPoint, Point newPoint, Color color, int thickness) {
    double dx = newPoint.dx - originalPoint.dx;
    double dy = newPoint.dy - originalPoint.dy;

    this.color = color;
    this.thickness = thickness;

    for (int i = 0; i < all_points.length; i++) {
      Point currentPoint = all_points[i];
      all_points[i] = Point(currentPoint.dx + dx, currentPoint.dy + dy);
    }

    if(this.fillImage != null){
       updateBoundingBox();
    }

    print("Polygon moved to new position");
  }

  void updateBoundingBox() {

    if (all_points.isEmpty) {
      print("all points are empty\n");
      return;
    }

    final top = all_points.reduce((value, element) {
      if (element.dy < value.dy) {
        return element;
      }
      return value;
    }).dy;
    final bottom = all_points.reduce((value, element) {
      if (element.dy > value.dy) {
        return element;
      }
      return value;
    }).dy;
    final left = all_points.reduce((value, element) {
      if (element.dx < value.dx) {
        return element;
      }
      return value;
    }).dx;
    final right = all_points.reduce((value, element) {
      if (element.dx > value.dx) {
        return element;
      }
      return value;
    }).dx;
    boundingTopLeft = Point(left, top);
    boundingBottomRight = Point(right, bottom);
  }

  @override
  bool contains(Point touchedPoints) {
    for (var i = 0; i < this.all_points.length - 1; i++) {
      final distance = (all_points[i+1]-all_points[i]).distance;
      final distance1 = (touchedPoints - all_points[i]).distance;
      final distance2 = (touchedPoints - all_points[i+1]).distance;
      if((distance1 + distance2 - distance).abs() < 5){
        return true;
      }
    }

    int crossings = 0;
    for (int i = 0; i < all_points.length; i++) {
      int next = (i + 1) % all_points.length; // Ensure loop back to start for last segment
      Point point1 = all_points[i];
      Point point2 = all_points[next];

      if (((point1.dy > touchedPoints.dy) != (point2.dy > touchedPoints.dy)) &&
          (touchedPoints.dx < (point2.dx - point1.dx) * (touchedPoints.dy - point1.dy) / (point2.dy - point1.dy) + point1.dx)) {
        crossings++;
      }
    }

    return (crossings % 2 != 0);
  }

  static Shape? fromJson(Map<String, dynamic> json) {
    print("polygon fromJson is called\n");

    if (json['type'] == 'polygon') {
      final points = <Point>[];
      for (var i = 0; i < json['points'].length; i++) {
        final point = json['points'][i];
        points.add(Point(point['dx'], point['dy']));
      }
      
      for (var i = 0; i < points.length - 1; i++) {
        print("start: (${points[i].dx}, ${points[i].dy})\n");
        print("end: (${points[i+1].dx}, ${points[i+1].dy})\n");
      }

      bool _isFillColor = false;
      bool _isFillImage = false;

      ImageData? fillImage;
      if (json['fillImage'] != null) {
        fillImage = ImageData.fromJson(json['fillImage']);
        _isFillImage = true;
        _isFillColor = false;
        print("fillImage:\n");
        // print(fillImage);
      } else {
        fillImage = null;
        print("null is not called right?\n");
      }

      Color fillColor;
      if (json['fillColor'] != null) {
        fillColor = Color(json['fillColor']);
        _isFillImage = false;
        _isFillColor = true;
      } else {
        fillColor = Colors.transparent;
      }

      // clippingRectangleの処理を追加
      Rectangle? clippingRectangle = json['clipRectangle'] != null
          ? Rectangle.fromJson(json['clipRectangle']) as Rectangle?
          : null;

      Polygon temp_polygon = Polygon(
        points, 
        json['thickness'], 
        Color(json['color']), 
        json['id'], 
        fillColor, // Provide a default fill color if null
      );

      temp_polygon.fillImage = fillImage;
      temp_polygon.clippingRectangle = clippingRectangle;
      temp_polygon.isFillColor = _isFillColor;
      temp_polygon.isFillImage = _isFillImage;

      print(temp_polygon.fillColor);
  
      return temp_polygon;
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final pointsJson = <Map<String, dynamic>>[];
    for (var i = 0; i < this.all_points.length; i++) {
      final point = this.all_points[i];
      pointsJson.add(point.toJson());
    }
    return {
      'type': 'polygon',
      'points': pointsJson,
      'closed': closed,
      'thickness': thickness,
      'color': color.value,
      'fillColor': this.fillColor?.value,
      'fillImage': this.fillImage?.toJson(),
      'clipRectangle': this.clippingRectangle?.toJson(),
      'id': id,
    };
  }
  
  void drawPixel(Uint8List pixels, ui.Size size, Point point, ui.Color color) {
    final x = point.dx.toInt();
    final y = point.dy.toInt();
    if (x < 0 || x >= size.width || y < 0 || y >= size.height) {
      return;
    }
    final index = ((x + y * size.width) * 4).round();
    pixels[index] = color.red;
    pixels[index + 1] = color.green;
    pixels[index + 2] = color.blue;
    pixels[index + 3] = color.alpha;
  }

  @override
  String toString() {
    return "<${this.id}> Polygon Object: thickness ${this.thickness}, color ${this.color} \n";
  }
}

class EdgeEntry {
    double x;
    double yMax;
    double dx;  // 1/m : スキャンラインが1ピクセル上昇するごとにX座標がどれだけ変化するかを表す

    EdgeEntry({
      required this.x,
      required this.yMax,
      required this.dx,
    });
}
