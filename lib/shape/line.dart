import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'shape.dart';
import '../points.dart';
import '../pixelOperation.dart';

class Line extends Shape {

  Line(List<Point> points, int thickness, Color color) : super(points, thickness, color)
  {
    print("----- Line obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");
  }
 
  // DDA Algorithm for line drawing
  @override
  void draw(Uint8List pixels, {bool isAntiAliased = false, bool isSuperSampled = false, int ssaa = 2}) {
    print("Draw Function (LINE) is called!");
    if (isAntiAliased) {
      drawAntiAliased(pixels);
      return;
    }

    int SSAA = isSuperSampled ? ssaa : 1;
    double x0 = (SSAA * points[0].dx);
    double y0 = (SSAA * points[0].dy);
    double x1 = (SSAA * points[1].dx);
    double y1 = (SSAA * points[1].dy);

    double dy = y1 - y0;
    double dx = x1 - x0;

    if (dx != 0 && (dy / dx).abs() < 1) {
      double y = y0.toDouble();
      double m = dy / dx;

      if (dx > 0) {
        for (int x = x0.toInt(); x <= x1.toInt(); ++x) {
          applyBrush(pixels, x, y.round(), SSAA * thickness, color);
          y += m;
        }
      } else {
        for (int x = x0.toInt(); x >= x1.toInt(); --x) {
          applyBrush(pixels, x, y.round(), SSAA * thickness, color);
          y -= m;
        }
      }
    } else if (dy != 0) {
      double x = x0.toDouble();
      double m = dx / dy;

      if (dy > 0) {
        for (int y = y0.toInt(); y <= y1.toInt(); ++y) {
          applyBrush(pixels, x.round(), y, SSAA * thickness, color);
          x += m;
        }
      } else {
        for (int y = y0.toInt(); y >= y1.toInt(); --y) {
          applyBrush(pixels, x.round(), y, SSAA * thickness, color);
          x -= m;
        }
      }
    }
  }

  void drawAntiAliased(Uint8List pixels) {
    // Implementation of anti-aliased line drawing (not complete)
    // This method should be implemented based on the specific graphics library used (e.g., Skia, custom bitmap manipulation)
  }

  void applyBrush(Uint8List pixels, int x, int y, int size, Color color) {
    // Direct manipulation of pixels based on `Uint8List`
    // This method should map (x, y) to the index in `pixels` and blend the color accordingly
    // The actual implementation depends on the data structure and format of the image represented by `Uint8List`
  }
}
