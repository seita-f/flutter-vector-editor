import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import '../pixelOperation.dart';
import 'package:flutter/material.dart';

class Circle extends Shape {

  int radius = 0; 
  Color backgroundColor = Color(0xFFF5F5F5);
  double startAngle = 0;
  double endAngle = 0;
  double relativeStartAngle = 0;
  bool full = true;

  Circle(List<Point> points, int thickness, Color color) : super(points, thickness, color)
  {
    print("----- Circle obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

    start_dx = points[0].dx;
    start_dy = points[0].dy;
    end_dx = points[1].dx;
    end_dy = points[1].dy;

    this.radius = sqrt(pow((end_dx - start_dx), 2) + pow((end_dy - start_dy), 2) ).toInt();
    // this.startAngle = 0;
    // this.endAngle = 2 * pi;
    // this.relativeStartAngle = 0;
    // this.full = true;
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

  // DDA Algorithm for line drawing
  void Midpoint_circle(ui.Size size, Uint8List pixels) {

    int dE = 3;
    int dSE = 5 - 2 * radius;
    int d = 1 - radius;
    int x = 0;
    int y = radius;

    print("radius: $radius");

    while (y >= x) {
      drawCircle(pixels, size, x, y);
      if (d < 0) {
        d += dE;
        dE += 2;
        dSE += 2;
      } else {
        d += dSE;
        dE += 2;
        dSE += 4;
        y--;
      }
      x++;
    }
  }

  void drawCircle(Uint8List pixels, Size size, int x, int y) {
    drawPixel(pixels, size, x, y);
    drawPixel(pixels, size, x, -y);
    drawPixel(pixels, size, -x, y);
    drawPixel(pixels, size, -x, -y);
    drawPixel(pixels, size, y, x);
    drawPixel(pixels, size, y, -x);
    drawPixel(pixels, size, -y, x);
    drawPixel(pixels, size, -y, -x);
  }

  void drawPixel(Uint8List pixels, Size size, int i, int j,{var alpha = 1.0}) {

    final x = (start_dx + i).toInt();
    final y = (start_dy + j).toInt();

    final width = size.width.toInt();
    final height = size.height.toInt();

    if (!full) {
      double angle = atan2(j.toDouble(), i.toDouble());
      if (startAngle < 0) startAngle += 2 * pi;
      if (startAngle > endAngle) endAngle += 2 * pi;

      if (angle < 0) angle += 2 * pi;
      if ((angle < startAngle || angle > endAngle) &&
          (angle + 2 * pi < startAngle || angle + 2 * pi > endAngle)) return;
    }

    if (x >= 0 && x < width && y >= 0 && y < height) {
      final index = (x + y * width) * 4;

      if (alpha != 1.0) {
        pixels[index] = backgroundColor.red;
        pixels[index + 1] = backgroundColor.green;
        pixels[index + 2] = backgroundColor.blue;
        pixels[index + 3] = backgroundColor.alpha;
        return;
      }

      pixels[index] = color.red;
      pixels[index + 1] = color.green;
      pixels[index + 2] = color.blue;
      pixels[index + 3] = color.alpha;
    }
  }
}
