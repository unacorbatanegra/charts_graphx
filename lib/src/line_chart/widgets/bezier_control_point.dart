import 'package:graphx/graphx.dart';

class BezierControlPoint {
  GxPoint prev;
  GxPoint next;

  BezierControlPoint([this.prev, this.next]) {
    prev ??= GxPoint();
    next ??= GxPoint();
  }
}
