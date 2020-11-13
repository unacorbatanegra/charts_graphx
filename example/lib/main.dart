import 'dart:math';

import 'package:charts_graphx/charts_graphx.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LineChartt'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: LineChart<Venta>(
                Venta.generate(),
                (e) => e.total,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Venta {
  final DateTime date;
  final double total;
  final double iva;
  final String cliente;

  Venta({
    this.date,
    this.total,
    this.iva,
    this.cliente,
  });
  static List<Venta> generate() {
    final lista = <Venta>[];
    final rng = Random();
    for (int i = 1; i <= 10; i++) {
      lista.add(
        Venta(
          cliente: 'cliente-$i',
          total: rng.nextInt(100).toDouble(),
          iva: rng.nextInt(100).toDouble(),
          date: DateTime.now().subtract(
            Duration(days: 30 * i),
          ),
        ),
      );
    }
    lista.sort((v1, v2) => v1.date.millisecondsSinceEpoch);
    return lista;
  }
}
