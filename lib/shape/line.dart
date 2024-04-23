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
 
  // DDA Algorithm for line drawing
  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {
    // if (thickness != 1) {
    //   final brush = Brush.rounded(thickness, color: outlineColor);
    //   brushLine(size, pixels, brush);
    // } else if (antiAlias) {
    //   wuLine(size, pixels);
    // } else {
    //   ddaLine(size, pixels);
    // }
    DDA_line(size, pixels);
  }

  void DDA_line(ui.Size size, Uint8List pixels) {
    
    if (points.length == 1) {
        print("length is 1");
    } else {
        // Handle error or do nothing if points is empty or index is out of bounds
        print("Attempted to access an out-of-range or empty list of points.");
        print(points.length);
        return;
    }
    var dx = end_dx - start_dx;
    var dy = end_dy - start_dy;
    // var dy = this.points[1].dy - this.points[0].dy;
    // var dx = this.points[1].dx - this.points[0].dx;
    var steps = dy.abs() > dx.abs() ? dy.abs() : dx.abs();

    dx = dx / steps;
    dy = dy / steps;

    var x = this.points[0].dx;
    var y = this.points[0].dy;

    for (var i = 0; i <= steps; i++) {
      drawPixel(size, pixels, x, y, 1.0);
      x += dx;
      y += dy;
    }
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

//   void draw(Uint8List pixels, {bool isAntiAliased = false, bool isSuperSampled = false, int ssaa = 2}) {
//     print("Draw Function (LINE) is called!");
//     if (isAntiAliased) {
//       drawAntiAliased(pixels);
//       return;
//     }

//     int SSAA = isSuperSampled ? ssaa : 1;
//     double x0 = (SSAA * points[0].dx);
//     double y0 = (SSAA * points[0].dy);
//     double x1 = (SSAA * points[1].dx);
//     double y1 = (SSAA * points[1].dy);

//     double dy = y1 - y0;
//     double dx = x1 - x0;

//     if (dx != 0 && (dy / dx).abs() < 1) {
//       double y = y0.toDouble();
//       double m = dy / dx;

//       if (dx > 0) {
//         for (int x = x0.toInt(); x <= x1.toInt(); ++x) {
//           // applyBrush(pixels, x, y.round(), SSAA * thickness, color);
//           y += m;
//         }
//       } else {
//         for (int x = x0.toInt(); x >= x1.toInt(); --x) {
//           // applyBrush(pixels, x, y.round(), SSAA * thickness, color);
//           y -= m;
//         }
//       }
//     } else if (dy != 0) {
//       double x = x0.toDouble();
//       double m = dx / dy;

//       if (dy > 0) {
//         for (int y = y0.toInt(); y <= y1.toInt(); ++y) {
//           // applyBrush(pixels, x.round(), y, SSAA * thickness, color);
//           x += m;
//         }
//       } else {
//         for (int y = y0.toInt(); y >= y1.toInt(); --y) {
//           // applyBrush(pixels, x.round(), y, SSAA * thickness, color);
//           x -= m;
//         }
//       }
//     }
//   }

  void drawAntiAliased(Uint8List pixels) {
    // Implementation of anti-aliased line drawing (not complete)
    // This method should be implemented based on the specific graphics library used (e.g., Skia, custom bitmap manipulation)
  }
}
