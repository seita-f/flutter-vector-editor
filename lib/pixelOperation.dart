// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:math' as math;
// import 'dart:async';
// import 'points.dart';
// import 'package:flutter/material.dart';


// class Brush {
//   final List<Point> points;
//   final Color color;

//   Brush(this.points, {this.color = Colors.black});

//   void draw(Uint8List pixels, ui.Size size, Point offset) {
//     for (var point in points) {
//       final x = (point.dx + offset.dx).toInt();
//       final y = (point.dy + offset.dy).toInt();
//       final width = size.width.toInt();
//       final height = size.height.toInt();

//       if (x >= 0 && x < width && y >= 0 && y < height) {
//         final index = (x + y * width) * 4;
//         pixels[index] = color.red;
//         pixels[index + 1] = color.green;
//         pixels[index + 2] = color.blue;
//         pixels[index + 3] = color.alpha;
//       }
//     }
//   }

//   static Brush rounded(int radius, {Color color = Colors.black}) {
//     final points = <Point>[];
//     for (var i = -radius; i < radius; i++) {
//       for (var j = -radius; j < radius; j++) {
//         if (i * i + j * j >= radius * radius) continue;
//         points.add(Point(i.toDouble(), j.toDouble()));
//       }
//     }
//     return Brush(points, color: color);
//   }
// }
