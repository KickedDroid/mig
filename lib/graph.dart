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
        body: HistoryHomePage(widget.docRef),
      )),
    );
  }
}

// Testing

class History {
  final String data;
  final DateTime time;
  History(this.data, this.time);

  History.fromMap(Map<String, dynamic> map)
      : data = map['data'],
        time = DateTime.parse(map['time']);
}

class HistoryHomePage extends StatefulWidget {
  final String docRef;

  HistoryHomePage(this.docRef);

  @override
  _HistoryHomePageState createState() {
    return _HistoryHomePageState();
  }
}

class MachineItem extends StatelessWidget {
  final String notes;
  final String name;
  //final String c_percent;

  MachineItem({this.notes, this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.note),
        title: Text(
          notes,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(name.substring(0, 10)));
  }
}

class _HistoryHomePageState extends State<HistoryHomePage> {
  List<charts.Series<History, DateTime>> _seriesBarData;
  List<History> mydata;
  _generateData(mydata) {
    _seriesBarData = List<charts.Series<History, DateTime>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (History history, _) => history.time,
        measureFn: (History history, _) => double.parse(history.data),
        id: 'Sales',
        data: mydata,
        labelAccessorFn: (History row, _) => "${row.data}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Coolant Percentage History'),backgroundColor: Color(0xFF1c6b92),),
      backgroundColor: Colors.white,
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
          List<History> sales = snapshot.data.documents
              .map((documentSnapshot) => History.fromMap(documentSnapshot.data))
              .toList();
          return _buildChart(context, sales);
        }
      },
    );
  }

  Widget _buildChart(BuildContext context, List<History> saledata) {
    mydata = saledata;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 50, 8, 50),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.TimeSeriesChart(
                  _seriesBarData,
                  defaultRenderer: charts.LineRendererConfig(
                      includeArea: true, stacked: false),
                  animate: true,
                  behaviors: [
                    charts.ChartTitle("Machine:  ${widget.docRef}",
                        subTitle: "Line Graph",
                        behaviorPosition: charts.BehaviorPosition.top,
                        titleOutsideJustification:
                            charts.OutsideJustification.start,
                        innerPadding: 40),
                    charts.ChartTitle('Date/Timeline',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea,
                        innerPadding: 20),
                    charts.ChartTitle("Coolant Percentage",
                        behaviorPosition: charts.BehaviorPosition.start,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea,
                        outerPadding: 20),
                    charts.SlidingViewport(),
                    charts.PanAndZoomBehavior(),
                    charts.RangeAnnotation([
                      charts.LineAnnotationSegment(
                          DateTime.now(), charts.RangeAnnotationAxisType.domain)
                    ])
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
