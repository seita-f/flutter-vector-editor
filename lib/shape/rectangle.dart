import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import 'line.dart';
import 'package:flutter/material.dart';

class Rectangle extends Shape {

  Color backgroundColor = Color(0xFFF5F5F5);
  late List<Point> upper_line;
  late List<Point> right_line;
  late List<Point> lower_line;
  late List<Point> left_line;

  Rectangle(List<Point> points, int thickness, Color color, int id) : super(points, thickness, color, id)
  {
    print("----- Rectangle obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

    this.start_dx = points[0].dx;
    this.start_dy = points[0].dy;
    this.end_dx = points[1].dx;
    this.end_dy = points[1].dy;
    this.id = id;

    // upper line
    upper_line = [Point(this.start_dx, this.start_dy), Point(this.end_dx, this.start_dy)];
    // right line
    right_line = [Point(this.end_dx, this.start_dy), Point(this.end_dx, this.end_dy)];
    // lower line
    lower_line = [Point(this.end_dx, this.end_dy), Point(this.start_dx, this.end_dy)];
    // 左の辺
    left_line = [Point(this.start_dx, this.end_dy), Point(this.start_dx, this.start_dy)];

  }
    
  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {

    Line(upper_line, this.thickness, this.color, -10).draw(pixels, size, isAntiAliased: isAntiAliased);
    Line(right_line, this.thickness, this.color, -10).draw(pixels, size, isAntiAliased: isAntiAliased);
    Line(lower_line, this.thickness, this.color, -10).draw(pixels, size, isAntiAliased: isAntiAliased);
    Line(left_line, this.thickness, this.color, -10).draw(pixels, size, isAntiAliased: isAntiAliased);

  }

  double customFloor(double x) {
    if (x >= 0) {
        return x.floorToDouble();
    } else {
        return x.ceilToDouble() - 1;
    }
  }
  
  //------ Edit graph ------
  @override
  bool contains(Point touchedPoint) {
    // Point temp = Point(this.start_dx, this.start_dy);
    // return (temp - touchedPoint).distance < radius;
    return false;
  }

  @override
  bool isCenterPoint(Point tappedPoint){

    Point start = Point(this.start_dx, this.start_dy);

    // Calculate the distance from the tapped point to the start point
    final distance = (tappedPoint - start).distance;
    print("distance: $distance");
    // Return true if the distance is less than or equal to 10 pixels
    return distance <= 20;
  }

  @override
  void movingVertex(Point originalPoint, Point newPoint, Color color, int thickness) {
      // keep start point & change radius size
      this.color = color;
      this.thickness = thickness;
      this.color = color;

  }

  @override
  void movingShape(Point originalPoint, Point newPoint, Color color, int thickness) {
      // change start point & keep radius size
      this.color = color;
      this.thickness = thickness;
      this.color = color;

      this.start_dx = newPoint.dx;
      this.start_dy = newPoint.dy;
  }

  //------ File Manager ------
  @override
  static Shape? fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'rectangle') {
      
        List<Point> points = [
                Point(json['start']['dx'], json['start']['dy']),
                Point(json['end']['dx'], json['end']['dy']),
        ];
        int thickness = json['thickness'];
        Color color = Color(json['color']);
        int id = json['id'];
        return Rectangle(points, thickness, color, id);
    }
  }

  @override
  Map<String, dynamic> toJson() { 
    return {
      'type': 'rectangle',
      'start': {'dx': start_dx, 'dy': start_dy},
      'end': {'dx': end_dx, 'dy': end_dy},
      'thickness': thickness,
      'color': color.value,
      'id': id,
      };
  }

  @override
  String toString() {
    return "<${this.id}> Circle Object: start (${this.start_dx}, ${this.start_dy}),"
          "thickness ${this.thickness}, color ${this.color} \n";
  }
}
