import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MachineGraph extends StatefulWidget {
  MachineGraph({Key key}) : super(key: key);

  @override
  _MachineGraphState createState() => _MachineGraphState();
}

class _MachineGraphState extends State<MachineGraph> {
  List<charts.Series<History, String>> _seriesBarData;
  List<History> myData;

  _generateData(myData) {
    _seriesBarData.add(charts.Series(
      domainFn: (History history, _) => history.time,
      measureFn: (History history, _) => double.parse(history.data),
      data: myData,
      id: "history",
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          child: Scaffold(
        body: SalesHomePage(),
      )),
    );
  }

  Widget _buildBody(BuildContext context) {
    var box = Hive.box('myBox');
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(box.get('companyId'))
          .orderBy("history")
          .snapshots(),
      builder: (context, snapshot) {
        assert(snapshot != null);
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          for (int index = 0; index < snapshot.data.documents.length; index++) {
            List<History> history = snapshot.data.documents
                .map((e) => History.fromMap(e.data))
                .toList();
            _seriesBarData.add(charts.Series(
              id: 'history',
              data: history,
              domainFn: (datum, index) => datum.data,
              measureFn: (datum, index) => double.parse(datum.time),
            ));
          }
          return _buildChart(context);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[Expanded(child: charts.LineChart(_seriesBarData))],
      ),
    );
  }
}

class History {
  final String data;
  final String time;

  History(this.data, this.time);

  History.fromMap(Map<String, dynamic> map)
      : data = map['coolant-percent'],
        time = map['last-updated'];

  @override
  String toString() {
    // TODO: implement toString
    return data.toString();
  }
}

// Testing

class Sales {
  final String saleVal;
  final String saleYear;
  Sales(this.saleVal, this.saleYear);

  Sales.fromMap(Map<String, dynamic> map)
      : saleVal = map['data'],
        saleYear = map['time'];

  @override
  String toString() => "Record<$saleVal:$saleYear";
}

class SalesHomePage extends StatefulWidget {
  @override
  _SalesHomePageState createState() {
    return _SalesHomePageState();
  }
}

class _SalesHomePageState extends State<SalesHomePage> {
  List<charts.Series<Sales, num>> _seriesBarData;
  List<Sales> mydata;
  _generateData(mydata) {
    _seriesBarData = List<charts.Series<Sales, num>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (Sales sales, _) => double.parse(sales.saleYear),
        measureFn: (Sales sales, _) => double.parse(sales.saleVal),
        id: 'Sales',
        data: mydata,
        labelAccessorFn: (Sales row, _) => "${row.saleYear}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Firestore.instance
              .collection('companies')
              .getDocuments()
              .then((query) {
            query.documents.forEach((element) {
              Firestore.instance
                  .collection('companies')
                  .document(element.documentID)
                  .collection('history')
                  .getDocuments()
                  .then((value) {
                value.documents.forEach((element) {
                  print(element.data);
                });
              });
            });
          });
        },
      ),
      appBar: AppBar(title: Text('History')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('companies')
          .document('Aidan')
          .collection('history')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          List<Sales> sales = snapshot.data.documents
              .map((documentSnapshot) => Sales.fromMap(documentSnapshot.data))
              .toList();
          return _buildChart(context, sales);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<Sales> saledata) {
    mydata = saledata;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 120),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'History',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.LineChart(
                  _seriesBarData,
                  animate: true,
                  animationDuration: Duration(seconds: 1),
                  behaviors: [
                    charts.SlidingViewport(),
                    charts.PanAndZoomBehavior(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
