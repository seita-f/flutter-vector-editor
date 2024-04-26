import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../points.dart';
import 'dart:math' as math;
import 'line.dart';
import 'circle.dart';
import 'polygon.dart';

abstract class Shape {

  // properties
  static const int grabDistance = 10;
  final List<Point> points;
  int thickness;
  Color color;
  int id;
  int radius = 0;

  var start_dx;
  var start_dy;
  var end_dx;
  var end_dy;
 
  //----- override methods ------
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false});
  bool contains(Point points) => false; // default
  bool isStartPoint(Point tappedPoint) => false;  // for circle 

  static Shape? fromJson(Map<String, dynamic> json) {
    String type = json['type'];
    switch (type) {
      case 'line':
        return Line.fromJson(json);
      case 'circle':
        return Circle.fromJson(json);
      default:
        return null;  // 未知のタイプの場合はnullを返すか、例外を投げる
    }
  }

  Map<String, dynamic> toJson();

  String toString();

  //----- Constructor -----
  Shape(this.points, this.thickness, this.color, this.id);

  int getId(){
    return this.id;
  }
}

