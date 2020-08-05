import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:hive/hive.dart';

class MachineGraph extends StatefulWidget {
  MachineGraph({Key key}) : super(key: key);

  @override
  _MachineGraphState createState() => _MachineGraphState();
}

class _MachineGraphState extends State<MachineGraph> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          child: Scaffold(
        body: Column(
          children: <Widget>[
            sample3(context),
          ],
        ),
      )),
    );
  }
}

Widget sample3(BuildContext context) {
  final fromDate = DateTime(2019, 05, 22);
  final toDate = DateTime.now();

  final date1 = DateTime.now().subtract(Duration(days: 2));
  final date2 = DateTime.now().subtract(Duration(days: 3));

  return Center(
    child: Container(
      color: Colors.red,
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      child: BezierChart(
        fromDate: fromDate,
        bezierChartScale: BezierChartScale.WEEKLY,
        toDate: toDate,
        selectedDate: toDate,
        series: [
          BezierLine(
            label: "Coolant Percent",
            data: [
              DataPoint<DateTime>(value: 10, xAxis: date1),
              DataPoint<DateTime>(value: 50, xAxis: date2),
            ],
          ),
        ],
        config: BezierChartConfig(
          verticalIndicatorStrokeWidth: 3.0,
          verticalIndicatorColor: Colors.black26,
          showVerticalIndicator: true,
          verticalIndicatorFixedPosition: false,
          backgroundColor: Colors.blue,
          footerHeight: 30.0,
        ),
      ),
    ),
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
        return BezierChart(
            config: BezierChartConfig(
              verticalIndicatorStrokeWidth: 3.0,
              verticalIndicatorColor: Colors.black26,
              showVerticalIndicator: true,
              verticalIndicatorFixedPosition: false,
              backgroundColor: Colors.red,
              footerHeight: 30.0,
            ),
            bezierChartScale: BezierChartScale.WEEKLY,
            series: _buildList(context, snapshot.data.documents));
      }
    },
  );
}

List _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return snapshot.map((data) => _buildListItem(context, data)).toList();
}

DataPoint _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
  DocumentSnapshot machines = snapshot;
  return DataPoint(value: machines['data']);
}
