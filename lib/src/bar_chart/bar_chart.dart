import 'package:flutter/material.dart';
import 'package:graphx/graphx.dart';

class BarChart<T> extends StatelessWidget {
  final List<List<T>> list;
  final double Function(T value) value;
  final String Function(T value) text;
  final void Function(T value) onTap;
  final double radiusCircle;
  const BarChart(
    this.list,
    this.value, {
    Key key,
    this.text,
    this.onTap,
    this.radiusCircle = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SceneBuilderWidget(
      builder: () => SceneController.withLayers(
        front: _BarChartPainter(
          list,
          value,
          text,
          onTap,
        ),
      ),
    );
  }
}

class _BarChartPainter<T> extends SceneRoot {
  final List<List<T>> list;
  final double Function(T value) value;
  final String Function(T value) text;
  final void Function(T value) onTap;
  _BarChartPainter(
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

  double h;
  double w;
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
    w = stage.stageWidth - (padding * 2);
    h = stage.stageHeight - (padding * 2);
    final verticalLines = Shape();
    final horizontalLines = Shape();
    final container = Sprite();

    stage.onResized.add(() {
      container.scale = stage.stageWidth / w;
    });
    final overlayContainer = Sprite();

    addChild(overlayContainer);

    // var toolTip = ToolTipOverlay<T>(
    //   texto: (e) => '',
    // );
    // toolTip.name = 'toolTip';
    // container.addChild(toolTip);

    container.addChild(verticalLines);
    container.addChild(horizontalLines);
    container.x = 40;
    container.y = 40;

    verticalLines.graphics.lineStyle(
      5.0,
      Colors.blueGrey.value,
    );

    final separatorX = w / list.length;
    final separatorY = h / 4;

    verticalLines.graphics.moveTo(0.0, 0.0);
    verticalLines.graphics.lineTo(0.0, h);

    verticalLines.graphics.lineTo(w, h);
    verticalLines.graphics.lineStyle(
      1,
      Colors.blueGrey.value,
      .5,
    );
    horizontalLines.graphics.lineStyle(
      1,
      Colors.blueGrey.value,
      .5,
    );
    final divisions = maxTotal / 4;
    for (var i = 0; i < 5; i++) {
      final tY = i * separatorY;
      horizontalLines.graphics.moveTo(0, tY);
      horizontalLines.graphics.lineTo(w, tY);

      final myAxisText = StaticText();

      myAxisText.text = (maxTotal - (divisions * i)).toString();
      print(tY);
      myAxisText.y = tY - 10;
      myAxisText.x = -40;
      container.addChild(myAxisText);
    }

    final bars = <Bar>[];
    list.asMap().entries.forEach(
      (element) {
        for (var i = 0; i < list[element.key].length; i++) {
          final tX = (i + 1) * separatorX;
          //linea vertical

          verticalLines.graphics.moveTo(tX, 0);
          verticalLines.graphics.lineTo(tX, h);
          final percent = 1 - (value(list[element.key][i]) / maxTotal);

          final currentY = percent * h;
          final currentX = tX;
          final width = 15 / 2;

          var bar = Bar(
            width,
            currentY,
            () {},
            (e) => '',
          );

          bar.y = h - 2.5;
          bar.x = currentX - 30;
          bars.add(bar);
          bar.scaleY = 0;
          bar.tween(
            duration: 1,
            scaleY: 1,
            x: '30',
            ease: GEase.linear,
            delay: 1 + i * .1,
          );

          container.addChild(bars[i]);
        }
      },
    );
    addChild(container);
  }

  int round(int n) {
    final a = (n ~/ 10) * 10;
    final b = a + 10;
    final result = (n - a > b - n) ? b : a;
    return result > n ? result : result + 10;
  }
}

class Bar<T> extends Sprite {
  String texto;
  final double w;
  final double h;
  Color color;
  T data;
  VoidCallback onTap;
  String Function(T) fromString;
  double scaleInternal = 1;
  Bar(
    this.w,
    this.h,
    this.onTap,
    this.data,
  ) {
    color = Colors.yellow;
    init();
  }
  void draw() {
    graphics.clear();
    graphics.beginFill(
      color.value,
    );
    graphics
        .drawRect(
          0,
          0,
          w,
          h,
        )
        .endFill();
    scale = scaleInternal;
    alignPivot(Alignment.bottomCenter);
  }

  void init() {
    draw();
    onMouseClick.add((_) {
      onTap();
      print(h);
    });
    onMouseDown.add((e) {
      color = Colors.red;
      scaleInternal = 2;
      draw();
      onMouseOut.addOnce((y) {
        color = Colors.yellow;
        scaleInternal = 1;
        draw();
      });
    });
  }
}
