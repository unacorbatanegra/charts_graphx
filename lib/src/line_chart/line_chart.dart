import 'package:flutter/material.dart';
import 'package:graphx/graphx.dart';

import 'widgets/background.dart';
import 'widgets/bezier_control_point.dart';

class LineChart<T> extends StatelessWidget {
  final List<List<T>> list;
  final double Function(T value) value;
  final String Function(T value) text;
  final void Function(T value) onTap;
  const LineChart(
    this.list,
    this.value, {
    Key key,
    this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SceneBuilderWidget(
      builder: () => SceneController.withLayers(
        front: _LineChartPainter(
          list,
          value,
          text,
          onTap,
        ),
      ),
    );
  }
}

class _LineChartPainter<T> extends SceneRoot {
  final List<List<T>> list;
  final double Function(T value) value;
  final String Function(T value) text;
  final void Function(T value) onTap;
  _LineChartPainter(
    this.list,
    this.value,
    this.text,
    this.onTap,
  );
  @override
  void init() {
    config(autoUpdateAndRender: true, usePointer: true);
  }

  @override
  void ready() {
    super.ready();
    addChild(_Base<T>(list, value, text, onTap));
  }
}

class _Base<T> extends Sprite {
  final List<List<T>> list;
  final double Function(T) value;
  final String Function(T) texto;
  final void Function(T value) onTap;
  _Base(
    this.list,
    this.value,
    this.texto,
    this.onTap,
  );

  @override
  void addedToStage() {
    init();
    super.addedToStage();
  }

  double h;
  double w;
  final spriteList = <Shape>[];

  void init() {
    final points = [<GxPoint>[]];

    var maxTotalData = 0.0;
    var maxLength = 0;
    for (final element in list) {
      points.add([]);
      if (element.length > maxLength) maxLength = element.length;
      final max = element.fold<double>(
        0.0,
        (v, element) {
          if (v < value(element)) v = value(element);
          return v;
        },
      );
      if (max > maxTotalData) maxTotalData = max;
    }

    final maxTotal = round(maxTotalData.toInt());

    final padding = 40.0;

    h = stage.stageHeight - (padding * 2);

    final horizontalLines = Shape();
    final bk = Background(
      length: maxLength,
      maxTotal: maxTotal,
    );

    bk.addChild(horizontalLines);
    w = stage.stageWidth - (padding * 2);

    final separatorX = w / maxLength;
    addChild(bk);
    list.asMap().entries.forEach(
      (element) {
        horizontalLines.graphics.lineStyle(4.0,
            Colors.primaries[Random().nextInt(Colors.primaries.length)].value);
        var color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
        for (var i = 0; i < element.value.length; i++) {
          final tX = (i + 1) * separatorX;
          final dot = _Dot(
            element.value[i],
            texto,
            onTap,
            color,
          );
          // stage.addChild(dot);
          bk.addChild(dot);

          final percent = 1 - (value(element.value[i]) / maxTotal);

          dot.y = percent * h;
          dot.x = tX;

          if (i == 0) {
            bk.graphics.moveTo(dot.x, dot.y);
          } else {
            bk.graphics.lineTo(dot.x, dot.y);
          }
          // print('la x del punto es ${dot.x} y su Y es ${dot.y}');
          spriteList.add(dot);

          points[element.key].add(GxPoint(dot.x, dot.y));
        }
        bezierCurveThrough(
          horizontalLines.graphics,
          points[element.key],
          .15,
        );
      },
    );
    horizontalLines.graphics.endFill();
  }

  int round(int n) {
    final a = (n ~/ 10) * 10;
    final b = a + 10;
    final result = (n - a > b - n) ? b : a;
    return result > n ? result : result + 10;
  }

  void bezierCurveThrough(Graphics g, List<GxPoint> points,
      [double tension = .25]) {
    tension ??= .25;
    var len = points.length;
    if (len == 2) {
      g.moveTo(points[0].x, points[0].y);
      g.lineTo(points[1].x, points[1].y);
      return;
    }

    final cpoints = <BezierControlPoint>[];

    for (var i = 0; i < points.length; i++) {
      cpoints.add(BezierControlPoint());
    }
    for (var i = 1; i < len - 1; ++i) {
      final pi = points[i];
      final pp = points[i - 1];
      final pn = points[i + 1];
      var rdx = pn.x - pp.x;
      var rdy = pn.y - pp.y;
      var rd = _dist(rdx, rdy);
      var dx = rdx / rd;
      var dy = rdy / rd;

      var dp = _dist(pi.x - pp.x, pi.y - pp.y);
      var dn = _dist(pi.x - pn.x, pi.y - pn.y);

      var cpx = pi.x - dx * dp * tension;
      var cpy = pi.y - dy * dp * tension;
      var cnx = pi.x + dx * dn * tension;
      var cny = pi.y + dy * dn * tension;

      cpoints[i].prev.setTo(cpx, cpy);
      cpoints[i].next.setTo(cnx, cny);
    }

    /// end points
    cpoints[0].next = GxPoint(
      (points[0].x + cpoints[1].prev.x) / 2,
      (points[0].y + cpoints[1].prev.y) / 2,
    );

    cpoints[len - 1].prev = GxPoint(
      (points[len - 1].x + cpoints[len - 2].next.x) / 2,
      (points[len - 1].y + cpoints[len - 2].next.y) / 2,
    );

    /// draw?
    g.moveTo(points[0].x, points[0].y);
    for (var i = 1; i < len; ++i) {
      var p = points[i];
      var cp = cpoints[i];
      var cpp = cpoints[i - 1];
      g.cubicCurveTo(cpp.next.x, cpp.next.y, cp.prev.x, cp.prev.y, p.x, p.y);
    }
  }

  double _dist(double x, double y) => sqrt(x * x + y * y);
}

class _Dot<T> extends Shape {
  Color color;
  final T value;
  final String Function(T value) texto;
  final void Function(T value) onTap;

  _Dot(this.value, this.texto, this.onTap, this.color);
  @override
  void addedToStage() {
    super.addedToStage();
    init();
  }

  void draw() {
    graphics?.clear();
    graphics.beginFill(color.value, .7);
    graphics.drawCircle(0.0, 0.0, 5.0).endFill();
  }

  void init() {
    color ??= Colors.red;
    draw();

    onMouseDown.add((e) {
      color = Colors.black;
      draw();
      print('onMOuseDown');
      // print(texto(value));
      scale = 1.1;
      onTap(value);
      onMouseUp.addOnce((_) {
        scale = 1;
        color = Colors.red;
        draw();
      });
    });
  }
}
