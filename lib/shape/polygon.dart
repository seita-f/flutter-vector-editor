import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'shape.dart';
import '../points.dart';
import 'package:flutter/material.dart';

class Polygon extends Shape {

  Polygon(List<Point> points, int thickness, Color color) : super(points, thickness, color, id)
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

    
  }

  //------ File Manager ------
  // @override
  // static Shape? fromJson(Map<String, dynamic> json) {
  //   if (json['type'] == 'circle') {
      
  //       List<Point> points = [
  //               Point(json['start']['dx'], json['start']['dy']),
  //               Point(json['end']['dx'], json['end']['dy']),
  //       ];
  //       int thickness = json['thickness'];
  //       Color color = Color(json['color']);
  //       int id = json['id'];
  //       return Circle(points, thickness, color, id);
  //   }
  // }

  // bool isStartPoint(Point tappedPoint){
  //   dist_to_start = abs(tappedPoint - this.points[0]);
  //   dist_to_end = abs(tappedPoint - this.points[1]);
  //   return dist_to_start < dist_to_end;  // true => moving circle by tapping starting point
  // }

  // @override
  // Map<String, dynamic> toJson() { 
  //   return {
  //     'type': 'circle',
  //     'start': {'dx': start_dx, 'dy': start_dy},
  //     'end': {'dx': end_dx, 'dy': end_dy},
  //     'thickness': thickness,
  //     'color': color.value,
  //     'id': id,
  //     };
  // }

  // @override
  // String toString() {
  //   return "<${this.id}> Circle Object: start (${this.start_dx}, ${this.start_dy}), radius "
  //         "${this.radius}, "
  //         "thickness ${this.thickness}, color ${this.color} \n";
  // }
}
