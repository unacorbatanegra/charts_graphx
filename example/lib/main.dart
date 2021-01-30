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
    final lista = Sale.generate(15);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LineChart'),
      ),
      body: PageView(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              margin: const EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: PieChart<Sale>(
                lista,
                (e) => e.total,
                onTap: (value) => showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(title: Text(value.customer)),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              margin: const EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: LineChart<Sale>(
                [
                  lista,
                  Sale.generate(20),
                ],
                (e) => e.total,
                text: (value) => value.customer,
                onTap: (value) => showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(title: Text(value.customer)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Sale {
  final DateTime date;
  final double total;
  final double iva;
  final String customer;

  Sale({
    this.date,
    this.total,
    this.iva,
    this.customer,
  });
  static List<Sale> generate(int length) {
    final lista = <Sale>[];
    final rng = Random();
    for (var i = 1; i <= length; i++) {
      lista.add(
        Sale(
          customer: 'customer-$i',
          total: rng.nextInt(100).toDouble(),
          iva: rng.nextInt(100).toDouble(),
          date: DateTime.now().subtract(
            Duration(days: 30 * i),
          ),
        ),
      );
    }
    return lista;
  }
}
