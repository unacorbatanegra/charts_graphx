import 'package:flutter/material.dart';
import 'package:graphx/graphx.dart';

class Background extends Sprite {
  final int length;
  final int maxTotal;
  Background({this.length, this.maxTotal});
  @override
  void addedToStage() {
    init();
    super.addedToStage();
  }

  double h;
  double w;
  void init() {
    final padding = 40.0;
    x = 40;
    y = 40;
    w = stage.stageWidth - (padding * 2);
    h = stage.stageHeight - (padding * 2);
    final verticalLines = Shape();
    final horizontalLines = Shape();
    addChild(verticalLines);
    verticalLines.graphics.lineStyle(
      5.0,
      Colors.blueGrey.value,
    );

    // final separatorX = w / length;
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
      addChild(myAxisText);
    }
    addChild(horizontalLines);
    addChild(verticalLines);
  }
}