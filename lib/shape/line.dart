import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import 'package:flutter/material.dart';

class Line extends Shape {

  Line(List<Point> points, int thickness, Color color, int id) : super(points, thickness, color, id)
  {
    print("----- Line obj -----");
    print("start point dx: ${points[0].dx}, dy: ${points[0].dy}");
    print("end point dx: ${points[1].dx}, dy: ${points[1].dy}");

    start_dx = points[0].dx;
    start_dy = points[0].dy;
    end_dx = points[1].dx;
    end_dy = points[1].dy;
    id = id;
    radius = -10;
  }
 
  // DDA Algorithm for line drawing
  @override
  void draw(Uint8List pixels, ui.Size size, {bool isAntiAliased = false}) {
    if (thickness == 1){
        DDA_line(size, pixels);
    }
    else if(thickness > 1 && isAntiAliased){
        Wu_anitiAliasing(size, pixels);
    }
    else if(thickness > 1 && !isAntiAliased){
        DDA_line(size, pixels);
        copyLine(size, pixels); // CopyLine メソッドを追加
    }
  }

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

    void Wu_anitiAliasing(ui.Size size, Uint8List pixels)
    {
        // print("Wu_anitiAliasing is called!");

        double x0 = start_dx;
        double y0 = start_dy;
        double x1 = end_dx;
        double y1 = end_dy;

        final steep = (y1 - y0).abs() > (x1 - x0).abs();
        if (steep) {
            double temp;
            temp = x0;
            x0 = y0;
            y0 = temp;
            temp = x1;
            x1 = y1;
            y1 = temp;
        }

        if (x0 > x1) {
            double temp;
            temp = x0;
            x0 = x1;
            x1 = temp;
            temp = y0;
            y0 = y1;
            y1 = temp;
        }

        double dx = x1 - x0;
        double dy = y1 - y0;
        double gradient = dy / dx;

        if (dx == 0.0) {
            gradient = 1.0;
        }

        double xEnd = x0.roundToDouble();
        double yEnd = y0 + gradient * (xEnd - x0);
        double xGap = 1 - (x0 + 0.5).remainder(1);

        double xPixel1 = xEnd;
        double yPixel1 = yEnd.floorToDouble();

        if (steep) {
        antiAliased_drawPixel(
            size, pixels, yPixel1, xPixel1, xGap * (yEnd - yPixel1).remainder(1));
        antiAliased_drawPixel(size, pixels, yPixel1 + 1, xPixel1,
            xGap * (1 - (yEnd - yPixel1).remainder(1)));
        } else {
        antiAliased_drawPixel(
            size, pixels, xPixel1, yPixel1, xGap * (yEnd - yPixel1).remainder(1));
        antiAliased_drawPixel(size, pixels, xPixel1, yPixel1 + 1,
            xGap * (1 - (yEnd - yPixel1).remainder(1)));
        }

        double interY = yEnd + gradient;

        xEnd = x1.roundToDouble();
        yEnd = y1 + gradient * (xEnd - x1);
        xGap = (x1 + 0.5).remainder(1);

        double xPixel2 = xEnd;
        double yPixel2 = yEnd.floorToDouble();

        if (steep) {
        antiAliased_drawPixel(
            size, pixels, yPixel2, xPixel2, xGap * (yEnd - yPixel2).remainder(1));
        antiAliased_drawPixel(size, pixels, yPixel2 + 1, xPixel2,
            xGap * (1 - (yEnd - yPixel2).remainder(1)));
        } else {
        antiAliased_drawPixel(
            size, pixels, xPixel2, yPixel2, xGap * (yEnd - yPixel2).remainder(1));
        antiAliased_drawPixel(size, pixels, xPixel2, yPixel2 + 1,
            xGap * (1 - (yEnd - yPixel2).remainder(1)));
        }

        if (steep) {
        for (double x = xPixel1 + 1; x < xPixel2; x++) {
            antiAliased_drawPixel(
                size, pixels, interY.floorToDouble(), x, 1 - interY.remainder(1));
            antiAliased_drawPixel(
                size, pixels, interY.floorToDouble() + 1, x, interY.remainder(1));
            interY += gradient;
        }
        } else {
            for (double x = xPixel1 + 1; x < xPixel2; x++) {
                antiAliased_drawPixel(
                    size, pixels, x, interY.floorToDouble(), 1 - interY.remainder(1));
                antiAliased_drawPixel(
                    size, pixels, x, interY.floorToDouble() + 1, interY.remainder(1));
                interY += gradient;
            }
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

    void antiAliased_drawPixel(Size size, Uint8List pixels, double x, double y, double c) {

        int radius = this.thickness ~/ 2; // 半径を太さから計算
        for (int dx = -radius; dx <= radius; dx++) {
            for (int dy = -radius; dy <= radius; dy++) {
                if (dx * dx + dy * dy <= radius * radius) { // 円形パターンの計算
                    int nx = x.floor() + dx;
                    int ny = y.floor() + dy;
                    if (nx >= 0 && nx < size.width && ny >= 0 && ny < size.height) { // 範囲チェック
                        final index = (nx + ny * size.width).toInt() * 4;
                        if (index >= 0 && index < pixels.length - 4) {
                            pixels[index] = (pixels[index] * (1 - c) + color.red * c).toInt();
                            pixels[index + 1] = (pixels[index + 1] * (1 - c) + color.green * c).toInt();
                            pixels[index + 2] = (pixels[index + 2] * (1 - c) + color.blue * c).toInt();
                            pixels[index + 3] = (pixels[index + 3] * (1 - c) + color.alpha * c).toInt();
                        }
                    }
                }    
            }
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
        if (json['type'] == 'line') {
            List<Point> points = [
                Point(json['start']['dx'], json['start']['dy']),
                Point(json['end']['dx'], json['end']['dy']),
            ];
            int thickness = json['thickness'];
            Color color = Color(json['color']);
            int id = json['id'];

            // Fix: Pass the required positional arguments directly
            return Line(points, thickness, color, id);
        }
        return null;
    }

    @override
    Map<String, dynamic> toJson() {
        // print("start: $start_dx, $end_dx");
        // print("end  : $end_dx,   $end_dy");
        return {
        'type': 'line',
        'start': {'dx': start_dx, 'dy': start_dy},
        'end': {'dx': end_dx, 'dy': end_dy},
        'thickness': thickness,
        'color': color.value,
        'id': id,
        };
    }

    @override
    String toString() {
        return "<${this.id}> Line Object : start (${this.start_dx}, ${this.start_dy}), end "
                "(${this.end_dx}, ${this.end_dy}), "
                "thickness ${this.thickness}, color ${this.color} \n";
    }
}
