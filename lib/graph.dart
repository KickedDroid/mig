import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MachineGraph extends StatefulWidget {
  final String docRef;
  final double cMin;
  final double cMax;

  MachineGraph(this.docRef, this.cMin, this.cMax);

  @override
  _MachineGraphState createState() => _MachineGraphState();
}

class _MachineGraphState extends State<MachineGraph> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          child: Scaffold(
        body: HistoryHomePage(widget.docRef, widget.cMin, widget.cMax),
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
  final double cMin;
  final double cMax;

  HistoryHomePage(this.docRef, this.cMin, this.cMax);

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

  String name;
  _generateData(mydata) {
    _seriesBarData = List<charts.Series<History, DateTime>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (History history, _) => history.time,
        measureFn: (History history, _) => double.parse(history.data),
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        areaColorFn: (_, __) => charts.MaterialPalette.blue.makeShades(100)[99],
        id: 'Sales',
        data: mydata,
        labelAccessorFn: (History row, _) => "${row.data}",
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getNameFromFireStore(widget.docRef);
  }

  _getNameFromFireStore(String docRef) {
    var box = Hive.box('myBox');
    Firestore.instance
        .collection(box.get('companyId'))
        .document(docRef)
        .get()
        .then((value) {
      setState(() {
        name = value.data['name'];
      });
      print(value.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coolant Percentage History'),
        backgroundColor: Color(0xFF1c6b92),
      ),
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
      padding: EdgeInsets.fromLTRB(4, 10, 4, 30),
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
                    includeArea: true,
                    stacked: false,
                  ),
                  animate: true,
                  behaviors: [
                    charts.ChartTitle("Machine:  $name",
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
                    charts.ChartTitle("Coolant Concentration:  (Limits = " + widget.cMin.toStringAsFixed(0) + "% - " + widget.cMax.toStringAsFixed(0) + "%)",
                        behaviorPosition: charts.BehaviorPosition.start,
                        titleOutsideJustification:
                            charts.OutsideJustification.middleDrawArea,
                        outerPadding: 10),
                    charts.SlidingViewport(),
                    charts.PanAndZoomBehavior(),
                    charts.RangeAnnotation([
                      charts.RangeAnnotationSegment(widget.cMin+1, widget.cMax-1,
                          charts.RangeAnnotationAxisType.measure,
                          //startLabel: 'Min',
                          //endLabel: 'Max',
                          labelAnchor: charts.AnnotationLabelAnchor.start,
                          color:
                              charts.MaterialPalette.green.makeShades(100)[80]),
                      charts.RangeAnnotationSegment(0, widget.cMin,
                          charts.RangeAnnotationAxisType.measure,
                          startLabel: 'Low',
                          labelAnchor: charts.AnnotationLabelAnchor.start,
                          color:
                              charts.MaterialPalette.red.makeShades(100)[90]),
                      charts.RangeAnnotationSegment(
                          widget.cMax,
                          widget.cMax + 2,
                          charts.RangeAnnotationAxisType.measure,
                          endLabel: 'High',
                          labelAnchor: charts.AnnotationLabelAnchor.start,
                          color:
                              charts.MaterialPalette.red.makeShades(100)[90]),
                      charts.RangeAnnotationSegment(widget.cMin, widget.cMin+1,
                          charts.RangeAnnotationAxisType.measure,
                          startLabel: 'Min',
                          labelAnchor: charts.AnnotationLabelAnchor.start,
                          color:
                              charts.MaterialPalette.yellow.makeShades(100)[80]),
                      charts.RangeAnnotationSegment(widget.cMax-1, widget.cMax,
                          charts.RangeAnnotationAxisType.measure,
                          startLabel: 'Max',
                          labelAnchor: charts.AnnotationLabelAnchor.start,
                          color:
                              charts.MaterialPalette.yellow.makeShades(100)[80]),
                    ]),
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
