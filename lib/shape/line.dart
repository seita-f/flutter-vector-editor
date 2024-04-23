import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import '../pixelOperation.dart';
import 'package:flutter/material.dart';

class Line extends Shape {

  Line(List<Point> points, int thickness, Color color) : super(points, thickness, color)
  {
    print("----- Line obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

    start_dx = points[0].dx;
    start_dy = points[0].dy;
    end_dx = points[1].dx;
    end_dy = points[1].dy;
  }
 
  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {
    if (thickness == 1){
        DDA_line(size, pixels);
    }
    else if(thickness > 1 && isAntiAliased){
        Wu_antiAliased_line(size, pixels);
    }
    else{
        DDA_line(size, pixels);
        copyLine(size, pixels); // CopyLine method
    }
  }

  // DDA Algorithm for line drawing
  void DDA_line(ui.Size size, Uint8List pixels) {

    var dx = end_dx - start_dx;
    var dy = end_dy - start_dy;

    var steps = dy.abs() > dx.abs() ? dy.abs() : dx.abs();

    dx = dx / steps;
    dy = dy / steps;

    var x = start_dx;
    var y = start_dy;

    for (var i = 0; i <= steps; i++) {
      drawPixel(size, pixels, x, y, 1.0);
      x += dx;
      y += dy;
    }
  }

  // Copy-Line algorithm for line drawing
  void copyLine(ui.Size size, Uint8List pixels) {
    var dx = end_dx - start_dx;
    var dy = end_dy - start_dy;
    var steps = dy.abs() > dx.abs() ? dy.abs() : dx.abs();

    dx = dx / steps;
    dy = dy / steps;

    var x = start_dx;
    var y = start_dy;

    // より水平な線の場合
    if (dx.abs() > dy.abs()) {
        for (var i = 0; i <= steps; i++) {
        for (int j = 1; j <= thickness / 2; j++) {
            drawPixel(size, pixels, x, y + j, 1.0); // 上方向にコピー
            drawPixel(size, pixels, x, y - j, 1.0); // 下方向にコピー
        }
        x += dx;
        y += dy;
        }
    }
    // より垂直な線の場合
    else {
        for (var i = 0; i <= steps; i++) {
        for (int j = 1; j <= thickness / 2; j++) {
            drawPixel(size, pixels, x + j, y, 1.0); // 右方向にコピー
            drawPixel(size, pixels, x - j, y, 1.0); // 左方向にコピー
        }
        x += dx;
        y += dy;
        }
    }
  }

  // anti-aliased algorithm for d
  void Wu_antiAliased_line(ui.Size size, Uint8List pixels) {


  }

  void drawPixel(ui.Size size, Uint8List pixels, double x, double y, double c) {

    final index = (x.floor() + y.floor() * size.width).toInt() * 4;
    if (index < 0 ||
        index >= pixels.length ||
        c < 0 ||
        c > 1 ||
        x < 0 ||
        x >= size.width ||
        y < 0 ||
        y >= size.height) {
      return;
    }

    pixels[index] = color.red;
    pixels[index + 1] = color.green;
    pixels[index + 2] = color.blue;
    pixels[index + 3] = color.alpha;
  }
}
