import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import 'line.dart';
import 'package:flutter/material.dart';

class Polygon extends Shape {

  final List<Point> all_points = [];
  bool closed = false;
  
  Polygon(List<Point> all_points, int thickness, Color color, int id) : super(all_points, thickness, color, id)
  {
    print("----- Polygon obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

    all_points = all_points;
    closed = false;
    id = id;
  }

  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {

    print("Polygon draw() is called! \n");
    for (var i = 0; i < all_points.length - 1; i++) {
      final point1 = all_points[i];
      final point2 = all_points[i + 1];
      drawEdge(point1, point2, pixels, size, isAntiAliased);
    }
    // if (closed) {
    //   final point1 = all_points[all_points.length - 1];
    //   final point2 = all_points[0];
    //   drawEdge(point1, point2, pixels, size, isAntiAliased);
    // }
  }

  void drawEdge(Point point1, Point point2, Uint8List pixels, ui.Size size, bool isAntiAliased) {

    List<Point> linePoints = [
      point1,  
      point2 
    ];
    final line = Line(linePoints, thickness, color, -10); // id
    line.draw(pixels, size, isAntiAliased: isAntiAliased);
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

  @override
  bool contains(Point tappedPoint) {
    return false;
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
