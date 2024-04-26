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
  Shape(this.points, this.thickness, this.color);

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

  // ----- Edit graph ------
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

  int getVertexIndexOf(Point point) {
    for (int i = 0; i < points.length; i++) {
      if ((point - points[i]).distance < thickness + grabDistance) {
        return i;
      }
    }
    return -1;
  }

  void moveVertex(int vertexIndex, Point offSet) {
    points[vertexIndex] = points[vertexIndex] + offSet;
  }

  int getEdgeIndexOf(Point point) {
    for (int i = 0; i < points.length - 1; i++) {
      if (_distanceFromLine(point, points[i], points[i + 1]) < thickness + grabDistance) {
        return i;
      }
    }
    if (_distanceFromLine(point, points.last, points.first) < thickness + grabDistance) {
      return points.length - 1;
    }
    return -1;
  }

  void moveEdge(int edgeIndex, Point offSet) {
    points[edgeIndex] = points[edgeIndex] + offSet;
    int nextIndex = edgeIndex == points.length - 1 ? 0 : edgeIndex + 1;
    points[nextIndex] = points[nextIndex] + offSet;
  }

  void moveShape(Point offset) {
    for (int i = 0; i < points.length; i++) {
      points[i] = points[i] + offset;
    }
  }

  double _distanceFromLine(Point point, Point a, Point b) {
    double normalLength = (b - a).distance;
    return ((point.dx - a.dx) * (b.dy - a.dy) - (point.dy - a.dy) * (b.dx - a.dx)).abs() / normalLength;
  }
}

