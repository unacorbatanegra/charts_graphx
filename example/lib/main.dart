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
    final lista = Venta.generate(15);
    lista.forEach((element) => print(element.cliente));

    return Scaffold(
      appBar: AppBar(
        title: const Text('LineChart'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(border: Border.all()),
              margin: const EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              // child: LineChart<Venta>(
              //   [
              //     lista,
              //     Venta.generate(20),
              //   ],
              //   (e) => e.total,
              //   text: (value) => value.cliente,
              //   onTap: (value) {
              //     print(value.cliente);
              //     showDialog(
              //       context: context,
              //       builder: (context) => AlertDialog(
              //         title: Text('asdasdas'),
              //         content: Text(value.cliente),
              //       ),

              //     );
              //   },
              // ),
              child: PieChart<Venta>(
                lista,
                (e)=>e.total,
                onTap: (value) => print(value.cliente),
              //   [
              //     lista,
              //     Venta.generate(20),
              //   ],
              //   (e) => e.total,
              //   text: (value) => value.cliente,
              //   onTap: (value) {
              //     print(value.cliente);
              //     showDialog(
              //       context: context,
              //       builder: (context) => AlertDialog(
              //         title: Text('asdasdas'),
              //         content: Text(value.cliente),
              //       ),

              //     );
              //   },
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
  static List<Venta> generate(int length) {
    final lista = <Venta>[];
    final rng = Random();
    for (var i = 1; i <= length; i++) {
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
    // lista.sort((v1, v2) => v1.date.millisecondsSinceEpoch);
    return lista;
  }
}
