import 'package:flutter/material.dart';
import 'package:graphx/graphx.dart';

class PieChart<T> extends StatelessWidget {
  final List<T> lista;
  final double Function(T value) value;
  final String Function(T value) texto;
  final void Function(T value) onTap;
  final double radiusCircle;
  const PieChart(
    this.lista,
    this.value, {
    Key key,
    this.texto,
    this.onTap,
    this.radiusCircle = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SceneBuilderWidget(
      builder: () => SceneController.withLayers(
        front: _PieChartPainter(
          lista,
          value,
          texto,
          onTap,
          radiusCircle: radiusCircle,
        ),
      ),
    );
  }
}

class _PieChartPainter<T> extends SceneRoot {
  final List<T> list;
  final double Function(T value) value;
  final String Function(T value) text;
  final void Function(T value) onTap;
  final double radiusCircle;
  _PieChartPainter(
    this.list,
    this.value,
    this.text,
    this.onTap, {
    this.radiusCircle = 30,
  });
  @override
  void init() {
    config(
      autoUpdateAndRender: true,
      usePointer: true,
    );
  }

  @override
  void ready() {
    super.ready();
    final obj = _Base<T>(
      list,
      value,
      text,
      onTap,
      radiusCircle: radiusCircle,
    );
    obj.setPosition(
      stage.stageWidth / 2,
      stage.stageHeight / 2,
    );
    addChild(obj);
  }
}

class _Base<T> extends Sprite {
  final List<T> list;
  final double Function(T value) value;
  final String Function(T value) text;
  final void Function(T value) onTap;
  final double radiusCircle;
  _Base(
    this.list,
    this.value,
    this.text,
    this.onTap, {
    this.radiusCircle = 40,
  });
  @override
  void addedToStage() {
    init();
    super.addedToStage();
  }

  void init() {
    final total = list.fold<double>(
      0.0,
      (v, element) => v += value(element),
    );
    stage.alignPivot(Alignment.center);
    // $debugBounds = true;

    // final cX = stage.stageWidth / 2;
    // final cY = stage.stageHeight / 2;
    // final container = Sprite();
    // final angleStep = 1 / lista.length * deg2rad(360);
    var currentAngle = 0.0;
    // var toolTipPie = ToolTipPie<T>(
    //   texto: 'prueba',
    // );
    // toolTipPie.name = 'toolTip';
    // addChild(toolTipPie);
    for (var i = 0; i < list.length; i++) {
      var color = Colors.primaries[i % Colors.primaries.length];
      final percent = value(list[i]) / total;
      final angleStep = deg2rad(percent * 360);
      var pie = Pie<T>(
        list[i],
        currentAngle: currentAngle,
        originalColor: color,
        angleStep: angleStep,
        radiusCircle: radiusCircle,
        onTap: onTap,
      );
      pie.x = 0;
      pie.y = 0;
      pie.scaleX = -1;
      pie.scaleY = -1;
      pie.rotation = -2;
      pie.alpha = 0;

      pie.tween(
        alpha: 1,
        duration: 1,
        scaleX: 1,
        scaleY: 1,
        rotation: 0,
        ease: GEase.defaultEasing,
        delay: .5 + i * .1,
      );
      
      currentAngle += angleStep;
      addChild(pie);
    }
    print(currentAngle);
  }
}

class Pie<T> extends Sprite {
  double radiusCircle;
  double currentAngle;
  double angleStep;
  Color originalColor;

  T data;
  void Function(T) onTap;

  Color color;
  Pie(
    this.data, {
    this.radiusCircle,
    this.currentAngle,
    this.angleStep,
    this.originalColor,
    @required this.onTap,
  });
  @override
  void addedToStage() {
    mouseUseShape = true;
    // $debugBounds = true;
    init();
    super.addedToStage();
  }

  void draw() {
    graphics.clear();
    graphics
        .beginFill(color.value)
        .moveTo(0.0, 0.0)
        .arc(0, 0, radiusCircle, currentAngle, angleStep)
        .lineTo(0, 0)
        .endFill();
  }

  void init() {
    color = originalColor;
    draw();
    onMouseClick.add(
      (_) {
        onTap(data);
      },
    );

    onMouseDown.add(
      (e) {
        scale = 1.1;
        onMouseUp.addOnce((y) {
          scale = 1;
        });
      },
    );
  }
}
