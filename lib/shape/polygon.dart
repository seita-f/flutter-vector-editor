import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import '../image.dart';
import 'line.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:math' as math;


class Polygon extends Shape {

  // final List<Point> all_points = [];
  late List<Point> all_points;
  late List<Line> lines = []; 
  bool closed = false;
  
  bool isFillColor = false;
  bool isFillImage = false;

  Color? fillColor;
  ImageData? fillImage;

  Polygon(List<Point> all_points, int thickness, Color color, int id, Color fillColor) : super(all_points, thickness, color, id)
  {
    print("----- Polygon obj -----");
    // print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    // print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");
    this.all_points = all_points;
    for (var i = 0; i < this.all_points.length - 1; i++) {
      print("start: (${this.all_points[i].dx}, ${all_points[i].dy})\n");
      print("end: (${this.all_points[i+1].dx}, ${all_points[i+1].dy})\n");
    }

    this.closed = false;
    this.id = id;
    this.fillColor = fillColor;
    // this.fillImage;
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
    if (this.isClosed(all_points[0], all_points[all_points.length - 1])) {
      print("isClosed() true!!\n");
      final point1 = all_points[all_points.length - 1];
      final point2 = all_points[0];
      drawEdge(point1, point2, pixels, size, isAntiAliased);

      // check filling option
      if (fillColor != null && isFillColor == true) {
        scanlineFill(pixels, size, (x, y) => fillColor!);
      }
      // check filling option
      if (fillImage != null && isFillImage == true) {
        scanlineFill(pixels, size, (x, y) {
          final top = topLeft!.dy;
          final left = topLeft!.dx;
          final bottom = bottomRight!.dy;
          final right = bottomRight!.dx;

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
    final line = Line(linePoints, thickness, color, -10); // id
    line.draw(pixels, size, isAntiAliased: isAntiAliased);
  }
  void scanlineFill(Uint8List pixels, ui.Size size, ui.Color Function(int x, int y) color) {
    List<int> sortedIndices = List<int>.generate(all_points.length, (i) => i);
    sortedIndices.sort((a, b) {
      int yCompare = all_points[a].dy.compareTo(all_points[b].dy);
      return yCompare == 0 ? all_points[a].dx.compareTo(all_points[b].dx) : yCompare;
    });

    List<EdgeEntry> aet = [];

    for (int y = 0; y < size.height.toInt(); y++) {
      while (sortedIndices.isNotEmpty && all_points[sortedIndices.first].dy.toInt() == y) {
        int currentIndex = sortedIndices.removeAt(0);
        int prevIndex = (currentIndex - 1 + all_points.length) % all_points.length;
        int nextIndex = (currentIndex + 1) % all_points.length;

        Point currentPoint = all_points[currentIndex];
        if (all_points[nextIndex].dy > currentPoint.dy) {
          aet.add(createEdge(all_points[currentIndex], all_points[nextIndex]));
        }
        if (all_points[prevIndex].dy > currentPoint.dy) {
          aet.add(createEdge(all_points[currentIndex], all_points[prevIndex]));
        }
      }

      aet.removeWhere((edge) => edge.yMax.toInt() == y);
      for (var edge in aet) {
        edge.x += edge.dx;
      }

      aet.sort((a, b) => (a.x).compareTo(b.x));

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

  @override
  void movingVertex(Point originalPoint, Point newPoint, Color color, int thickness){
    // updateLines(color, thickness);
    print("polygon moving vertex is called \n");

    print(originalPoint);
    print(newPoint);

    this.color = color;
    this.thickness = thickness;

    for (var i = 0; i < this.all_points.length -1; i++) {
      final distance = (all_points[i+1]-all_points[i]).distance;
        final distance1 = (originalPoint - all_points[i]).distance;
        final distance2 = (originalPoint - all_points[i+1]).distance;
        if((distance1 + distance2 - distance).abs() < 20){
          print("newPoint is assgined \n");
          all_points[i] = newPoint;
        }
    }
  }

  double calc_distance(Point point1, Point point2){
    return math.sqrt(math.pow(point1.dx - point2.dx, 2) + math.pow(point1.dy - point2.dy, 2));
  }

  // check if the start point is closed to the last point
  bool isClosed(Point point1, Point point2){
    final distance = calc_distance(point1, point2);
    print("isClosed distance: $distance");
    return distance <= 17;
  }

  @override
  bool isCenterPoint(Point tappedPoint){ 
    print("isCenterPoint is called!!!!!!!!!!!!!!!!\n");
    // for moving polygone (supposed inside the graph clicked)
    int crossings = 0;
    for (int i = 0; i < all_points.length; i++) {
      int next = (i + 1) % all_points.length; // Ensure loop back to start for last segment
      Point point1 = all_points[i];
      Point point2 = all_points[next];

      // Check if the line from point1 to point2 crosses the line from tappedPoint horizontally
      if (((point1.dy > tappedPoint.dy) != (point2.dy > tappedPoint.dy)) &&
          (tappedPoint.dx < (point2.dx - point1.dx) * (tappedPoint.dy - point1.dy) / (point2.dy - point1.dy) + point1.dx)) {
        crossings++;
      }
    }

    // If the number of crossings is odd, the point is inside the polygon
    print('is it the center point? : ${crossings % 2}\n');
    return (crossings % 2 != 0);
  }

  @override
  void movingShape(Point originalPoint, Point newPoint, Color color, int thickness) {
    // Calculate the differences in x and y directions
    double dx = newPoint.dx - originalPoint.dx;
    double dy = newPoint.dy - originalPoint.dy;

    // Update color and thickness properties
    this.color = color;
    this.thickness = thickness;

    // Move all points by the calculated differences
    for (int i = 0; i < all_points.length; i++) {
      Point currentPoint = all_points[i];
      all_points[i] = Point(currentPoint.dx + dx, currentPoint.dy + dy);
    }

    print("Polygon moved to new position");
  }

  //------- Edit graph -------
  @override
  bool contains(Point touchedPoints) {

      // check if the click point is on vertex
      for (var i = 0; i < this.all_points.length - 1; i++) {
        final distance = (all_points[i+1]-all_points[i]).distance;
        final distance1 = (touchedPoints - all_points[i]).distance;
        final distance2 = (touchedPoints - all_points[i+1]).distance;
        if((distance1 + distance2 - distance).abs() < 5){
          return true;
        }
      }

      // check if the click point is inside the shape
      int crossings = 0;
      for (int i = 0; i < all_points.length; i++) {
        int next = (i + 1) % all_points.length; // Ensure loop back to start for last segment
        Point point1 = all_points[i];
        Point point2 = all_points[next];

        // Check if the line from point1 to point2 crosses the line from tappedPoint horizontally
        if (((point1.dy > touchedPoints.dy) != (point2.dy > touchedPoints.dy)) &&
            (touchedPoints.dx < (point2.dx - point1.dx) * (touchedPoints.dy - point1.dy) / (point2.dy - point1.dy) + point1.dx)) {
          crossings++;
        }
      }

      // If the number of crossings is odd, the point is inside the polygon
      print('is it the center point? : ${crossings % 2}\n');
      return (crossings % 2 != 0);

      // return false;
  }

  //------ File Manager ------
  static Shape? fromJson(Map<String, dynamic> json) {
    // if (json['type'] == 'polygon') {
    //   final points = <Point>[];
    //   for (var i = 0; i < json['points'].length; i++) {
    //     final point = json['points'][i];
    //     all_points.add(Point(point['x'], point['y']));
    //   }
   
    //   return Polygon(all_points, ui.Offset.zero,
    //       closed: json['closed'],
    //       thickness: json['thickness'],
    //       color: ui.Color(json['color'])
    //   );
    // }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final all_points = <Map<String, double>>[];
    for (var i = 0; i < this.all_points.length; i++) {
      final point = this.all_points[i];
      all_points.add({'dx': point.dx, 'dy': point.dy});
    }
    return {
      'type': 'polygon',
      'points': points,
      'closed': closed,
      'thickness': thickness,
      'color': color.value,
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
    double dx;

    EdgeEntry({
      required this.x,
      required this.yMax,
      required this.dx,
    });
}