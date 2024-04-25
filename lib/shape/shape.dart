import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../points.dart';
import 'dart:math' as math;
import 'line.dart';
import 'circle.dart';

abstract class Shape {

  // properties
  static const int grabDistance = 10;
  final List<Point> points;
  int thickness;
  Color color;
  int id;

  var start_dx;
  var start_dy;
  var end_dx;
  var end_dy;
 
  
  //----- override methods ------
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false});
  bool contains(Point points) => false; // default

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

  // ----- Edit graph ------
  int getVertexIndexOf(Point point) {
    for (int i = 0; i < points.length; i++) {
      if ((point - points[i]).distance < thickness + grabDistance) {
        return i;
      }
    }
    return -1;
  }

  int getId(){
    return this.id;
  }
}

