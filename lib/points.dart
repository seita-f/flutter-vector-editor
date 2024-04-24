import 'dart:ui';
import 'dart:math' as math;
import 'dart:math'; // dart:math 

class Point {
  final double dx;
  final double dy;

  Point(this.dx, this.dy);

  double distanceTo(Point other) {
    return math.sqrt(math.pow(dx - other.dx, 2) + math.pow(dy - other.dy, 2));
  }

  // overload
  Point operator +(Point other) {
    return Point(dx + other.dx, dy + other.dy);
  }

  Point operator -(Point other) {
    return Point(dx - other.dx, dy - other.dy);
  }

  double get distance {
    return sqrt(dx * dx + dy * dy);
  }
}