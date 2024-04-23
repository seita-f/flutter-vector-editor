import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../points.dart';
import '../pixelOperation.dart';
import 'dart:math' as math;


abstract class Shape {
  static const int grabDistance = 10;
  final List<Point> points;
  int thickness;
  Color color;

  Shape(this.points, this.thickness, this.color);

  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false});

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

  void applyBrush(Uint8List pixels, Point start, Point end, int thickness, Color color) {
    // ここで実際のライン描画ロジックを実装します
    // このメソッドは、Pixel操作のロジックと組み合わせて使用されることを想定しています。
  }
}

