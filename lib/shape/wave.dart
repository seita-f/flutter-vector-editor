import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import 'package:flutter/material.dart';

class Wave extends Shape {

    int n_circle = 0;
    int count = 0; // to tell odd or even
    double startAngle = 0;
    double endAngle = 0;
    double relativeStartAngle = 0;
    bool full = true;
    int radius = 0; 
    Color backgroundColor = Color(0xFFF5F5F5);

    Wave(List<Point> points, int thickness, Color color, int id, int n_circle) : super(points, thickness, color, id)
    {
        print("----- Wave obj -----");
        print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
        print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

        start_dx = points[0].dx;
        start_dy = points[0].dy;
        end_dx = points[1].dx;
        end_dy = points[1].dy;
        id = id;
        this.radius = (sqrt(pow((end_dx - start_dx), 2) + pow((end_dy - start_dy), 2) )).toInt();
        this.n_circle = n_circle;
    }
    
    @override
    void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {
        // make all radius the same 
        double radius = (end_dx - start_dx) / (n_circle * 2 - 1);
        bool isUp = true;  // 初期の半円方向

        for (int i = 0; i < n_circle; i++) {
            // 各半円の中心点、隣接する半円は半径の2倍離れるように設定
            double center_dx = start_dx + radius * (1 + 2 * i);
            Midpoint_SemiCircle(size, pixels, center_dx, start_dy, radius.toInt(), isUp);
            isUp = !isUp;  
        }
    }

    void Midpoint_SemiCircle(ui.Size size, Uint8List pixels, double center_dx, double center_dy, int radius, bool isUp) {
        int dE = 3;
        int dSE = 5 - 2 * radius;
        int d = 1 - radius;
        int x = 0;
        int y = radius;

        while (y >= x) {
            if (isUp) {
                drawPixel(pixels, size, center_dx + x, center_dy - y);  // 上向き半円
                drawPixel(pixels, size, center_dx - x, center_dy - y);
                drawPixel(pixels, size, center_dx + y, center_dy - x);
                drawPixel(pixels, size, center_dx - y, center_dy - x);
            } else {
                drawPixel(pixels, size, center_dx + x, center_dy + y);  // 下向き半円
                drawPixel(pixels, size, center_dx - x, center_dy + y);
                drawPixel(pixels, size, center_dx + y, center_dy + x);
                drawPixel(pixels, size, center_dx - y, center_dy + x);
            }

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

    void drawPixel(Uint8List pixels, ui.Size size, double x, double y) {
        int ix = x.toInt();
        int iy = y.toInt();
        int width = size.width.toInt();
        int height = size.height.toInt();

        if (ix >= 0 && ix < width && iy >= 0 && iy < height) {
            int index = (iy * width + ix) * 4;
            pixels[index] = color.red;
            pixels[index + 1] = color.green;
            pixels[index + 2] = color.blue;
            pixels[index + 3] = color.alpha;
        }
    }

    //------- Edit graph -------
    @override
    bool contains(Point touchedPoints) {
        Point start = Point(start_dx, start_dy);
        Point end = Point(end_dx, end_dy);
        //   true if point is within 5 pixels of the line
        final distance = (end-start).distance;
        final distance1 = (touchedPoints - start).distance;
        final distance2 = (touchedPoints - end).distance;
        return (distance1 + distance2 - distance).abs() < 5;
    }

    @override
    bool isStartPoint(Point tappedPoint) => false;

    //----- File Manger -----
    @override
    static Shape? fromJson(Map<String, dynamic> json) {
        if (json['type'] == 'wave') {
            List<Point> points = [
                Point(json['start']['dx'], json['start']['dy']),
                Point(json['end']['dx'], json['end']['dy']),
            ];
            int thickness = json['thickness'];
            Color color = Color(json['color']);
            int id = json['id'];
            int n_circle = json['n_circle'];

            // Fix: Pass the required positional arguments directly
            return Wave(points, thickness, color, id, n_circle);
        }
        return null;
    }

    @override
    Map<String, dynamic> toJson() {
        // print("start: $start_dx, $end_dx");
        // print("end  : $end_dx,   $end_dy");
        return {
        'type': 'wave',
        'start': {'dx': start_dx, 'dy': start_dy},
        'end': {'dx': end_dx, 'dy': end_dy},
        'thickness': thickness,
        'color': color.value,
        'id': id,
        'n_cirlce': n_circle,
        };
    }

    @override
    String toString() {
        return "<${this.id}> Wave Object : start (${this.start_dx}, ${this.start_dy}), end "
                "(${this.end_dx}, ${this.end_dy}), "
                "thickness ${this.thickness}, color ${this.color} \n";
    }
    
}
