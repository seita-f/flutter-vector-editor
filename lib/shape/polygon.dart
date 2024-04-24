import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import '../pixelOperation.dart';
import 'package:flutter/material.dart';

class Polygon extends Shape {

  Polygon(List<Point> points, int thickness, Color color) : super(points, thickness, color)
  {
    print("----- Polygon obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

    start_dx = points[0].dx;
    start_dy = points[0].dy;
    end_dx = points[1].dx;
    end_dy = points[1].dy;
  }
 
  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {

    if(!isAntiAliased){
        Midpoint_circle(size, pixels);
    }
    else{
        print("Wu-antialiased");
    }
  }
}
