import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import 'package:flutter/material.dart';

class Circle extends Shape {

  int radius = 0; 
  Color backgroundColor = Color(0xFFF5F5F5);
  double startAngle = 0;
  double endAngle = 0;
  double relativeStartAngle = 0;
  bool full = true;

  Circle(List<Point> points, int thickness, Color color, int id) : super(points, thickness, color, id)
  {
    print("----- Circle obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

    this.start_dx = points[0].dx;
    this.start_dy = points[0].dy;
    this.end_dx = points[1].dx;
    this.end_dy = points[1].dy;
    this.id = id;
    this.radius = (sqrt(pow((end_dx - start_dx), 2) + pow((end_dy - start_dy), 2) )).toInt();
  }
 
  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {
    
    if(!isAntiAliased){
        Midpoint_circle(size, pixels);
    }
    else{
        Wu_Circle(size, pixels);
    }
  }

  double customFloor(double x) {
    if (x >= 0) {
        return x.floorToDouble();
    } else {
        return x.ceilToDouble() - 1;
    }
  }
  
  // Midpont algorithm
  void Midpoint_circle(ui.Size size, Uint8List pixels) {

    print("Midpoint_circle() is called! \n");
    int dE = 3;
    int dSE = 5 - 2 * radius;
    int d = 1 - radius; // decision parameter
    int x = 0;
    int y = radius;

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

  void drawCircle(Uint8List pixels, ui.Size size, int x, int y) {
    drawPixel(pixels, size, x, y);
    drawPixel(pixels, size, x, -y);
    drawPixel(pixels, size, -x, y);
    drawPixel(pixels, size, -x, -y);
    drawPixel(pixels, size, y, x);
    drawPixel(pixels, size, y, -x);
    drawPixel(pixels, size, -y, x);
    drawPixel(pixels, size, -y, -x);
  }
  
  // alpha 0: completely transaparent (far from circle line)
  // alpha 255:  filled (close to cirlce line)
  void Wu_Circle(ui.Size size, Uint8List pixels) {
    double x = radius.toDouble();
    double y = 0;

    drawPixel(pixels, size, x.round(), y.round());
    drawPixel(pixels, size, y.round(), x.round());
    drawPixel(pixels, size, -x.round(), y.round());
    drawPixel(pixels, size, -y.round(), -x.round());

    // 各ピクセルの位置に応じてアルファ値を計算
    while (x > y) {
      y++;
      x = sqrt(radius * radius - y * y).ceilToDouble();
      var alpha = x - sqrt(radius * radius - y * y);
      drawWuCircle(pixels, size, x, y, alpha);
    }
  }

  void drawWuCircle(Uint8List pixels, ui.Size size, double x, double y, double alpha) {
    final dx = x.round();
    final dy = y.round();
    print(1-alpha);
    drawPixel(pixels, size, dx, dy, alpha: (1 - alpha)); 
    drawPixel(pixels, size, dx - 1, dy, alpha: alpha);
    drawPixel(pixels, size, dy, dx, alpha: (1 - alpha));
    drawPixel(pixels, size, dy, dx - 1, alpha: alpha);
    drawPixel(pixels, size, -dx, dy, alpha: (1 - alpha));
    drawPixel(pixels, size, -dx + 1, dy, alpha: alpha);
    drawPixel(pixels, size, -dy, dx, alpha: (1 - alpha));
    drawPixel(pixels, size, -dy, dx - 1, alpha: alpha);
    drawPixel(pixels, size, dx, -dy, alpha: (1 - alpha));
    drawPixel(pixels, size, dx - 1, -dy, alpha: alpha);
    drawPixel(pixels, size, dy, -dx, alpha: (1 - alpha));
    drawPixel(pixels, size, dy, -dx + 1, alpha: alpha);
    drawPixel(pixels, size, -dx, -dy, alpha: (1 - alpha));
    drawPixel(pixels, size, -dx + 1, -dy, alpha: alpha);
    drawPixel(pixels, size, -dy, -dx, alpha: (1 - alpha));
    drawPixel(pixels, size, -dy, -dx + 1, alpha: alpha);
  }
  
  void drawPixel(Uint8List pixels, ui.Size size, int i, int j,{var alpha = 1.0}) {

    final x = (start_dx + i).toInt();
    final y = (start_dy + j).toInt();

    final width = size.width.toInt();
    final height = size.height.toInt();

    if (!full) {
      double angle = atan2(j.toDouble(), i.toDouble());
      if (startAngle < 0) startAngle += 2 * pi;  // start angleが負の値の場合、正の値に補正
      if (startAngle > endAngle) endAngle += 2 * pi; // 円弧の終了角度が開始角度よりも小さい場合、endAngle にも同様に 2 * pi を加えて正の値に補正

      // if (angle < 0) angle += 2 * pi;
      if ((angle < startAngle || angle > endAngle) &&
          (angle + 2 * pi < startAngle || angle + 2 * pi > endAngle)) return;
    }

    // check if given (x,y) is within the screen size
    if (x >= 0 && x < width && y >= 0 && y < height) {  
      final index = (x + y * width) * 4; // 2D to 1D

      if (alpha != 1.0) {

        Color pixelColor = Color.fromARGB(
            (color.alpha * alpha).toInt(), // アルファ値を適用
            color.red,
            color.green,
            color.blue
        );

        pixels[index] = pixelColor.red;
        pixels[index + 1] = pixelColor.green;
        pixels[index + 2] = pixelColor.blue;
        pixels[index + 3] = pixelColor.alpha;
        return;
      }

      pixels[index] = color.red;
      pixels[index + 1] = color.green;
      pixels[index + 2] = color.blue;
      pixels[index + 3] = color.alpha;
    }
  }

  //------ Edit graph ------
  @override
  bool contains(Point touchedPoint) {
    Point temp = Point(this.start_dx, this.start_dy);
    return (temp - touchedPoint).distance < radius;
  }

  @override
  bool isCenterPoint(Point tappedPoint){
    Point start = Point(this.start_dx, this.start_dy);

    // Calculate the distance from the tapped point to the start point
    final distance = (tappedPoint - start).distance;
    print("distance: $distance");
    // Return true if the distance is less than or equal to 10 pixels
    return distance <= 20;
  }

  @override
  void movingVertex(Point originalPoint, Point newPoint, Color color, int thickness) {
      // keep start point & change radius size
      this.color = color;
      this.thickness = thickness;
      this.color = color;

      int new_radius = (sqrt(pow((newPoint.dx - start_dx), 2) + pow((newPoint.dy - start_dy), 2) )).toInt();
      this.radius = new_radius;
  }

  @override
  void movingShape(Point originalPoint, Point newPoint, Color color, int thickness) {
      // change start point & keep radius size
      this.color = color;
      this.thickness = thickness;
      this.color = color;

      this.start_dx = newPoint.dx;
      this.start_dy = newPoint.dy;
      this.radius = this.radius;
  }

  //------ File Manager ------
  @override
  static Shape? fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'circle') {
      
        List<Point> points = [
                Point(json['start']['dx'], json['start']['dy']),
                Point(json['end']['dx'], json['end']['dy']),
        ];
        int thickness = json['thickness'];
        Color color = Color(json['color']);
        int id = json['id'];
        return Circle(points, thickness, color, id);
    }
  }

  @override
  Map<String, dynamic> toJson() { 
    return {
      'type': 'circle',
      'start': {'dx': start_dx, 'dy': start_dy},
      'end': {'dx': end_dx, 'dy': end_dy},
      'thickness': thickness,
      'color': color.value,
      'id': id,
      };
  }

  @override
  String toString() {
    return "<${this.id}> Circle Object: start (${this.start_dx}, ${this.start_dy}), radius "
          "${this.radius}, "
          "thickness ${this.thickness}, color ${this.color} \n";
  }
}
