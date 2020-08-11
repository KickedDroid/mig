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
        body: Column(
          children: <Widget>[
            _buildBody(context),
          ],
        ),
      )),
    );
  }

  Widget _buildBody(BuildContext context) {
    var box = Hive.box('myBox');
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(box.get('companyId')).snapshots(),
      builder: (context, snapshot) {
        assert(snapshot != null);
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          List<History> history =
              snapshot.data.documents.map((e) => History.fromMap(e.data));
          return _buildChart(context, history);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<History> history) {
    _generateData(history);
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
