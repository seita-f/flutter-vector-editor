import 'dart:ui';
import 'dart:math' as math;
// 四つの Offset オブジェクトをプロパティとして持ち、それぞれが2D空間上の点を表します。
// Offset クラスは、幾何学的操作や他の数学的計算を行うためのメソッドも提供します
// class Point {
//   Offset startPoint;
//   Offset endPoint;

//   Point({
//     this.startPoint,
//     this.endPoint,
//   });
// }

// class TwoPoints {

//   double distanceFromPoint(Point point, Point point2) {
//     final dx = point2.dx - point.dx;
//     final dy = point2.dy - point.dy;
//     return math.sqrt(dx * dx + dy * dy);
//   }

//   double distanceFromLine(Point point, Point point2, Point point3) {
//     final denominator = distanceBetweenPoints(point2, point3);
//     final numerator = ((point2.dx - point1.dx) * (point1.dy - point.dy) -
//                        (point2.dx - point.dx) * (point3.dy - point2.dy)).abs();

//     return numerator / denominator;
//   }
// }

class Point {
  final double dx;
  final double dy;

  Point(this.dx, this.dy);

  double distanceTo(Point other) {
    return math.sqrt(math.pow(dx - other.dx, 2) + math.pow(dy - other.dy, 2));
  }
}