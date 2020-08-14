import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MachineGraph extends StatefulWidget {
  final String docRef;

  MachineGraph(this.docRef);

  @override
  _MachineGraphState createState() => _MachineGraphState();
}

class _MachineGraphState extends State<MachineGraph> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          child: Scaffold(
        body: SalesHomePage(widget.docRef),
      )),
    );
  }
}

// Testing

class Sales {
  final String saleVal;
  final DateTime saleYear;
  Sales(this.saleVal, this.saleYear);

  Sales.fromMap(Map<String, dynamic> map)
      : saleVal = map['data'],
        saleYear = DateTime.parse(map['time']);

  @override
  String toString() => "Record<$saleVal:$saleYear";
}

class SalesHomePage extends StatefulWidget {
  final String docRef;

  SalesHomePage(this.docRef);

  @override
  _SalesHomePageState createState() {
    return _SalesHomePageState();
  }
}

class _SalesHomePageState extends State<SalesHomePage> {
  List<charts.Series<Sales, DateTime>> _seriesBarData;
  List<Sales> mydata;
  _generateData(mydata) {
    _seriesBarData = List<charts.Series<Sales, DateTime>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (Sales sales, _) => sales.saleYear,
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
          .document("${widget.docRef}")
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
                child: charts.TimeSeriesChart(
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
