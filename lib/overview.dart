import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:mig/qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const greenPercent = Color(0xff14c4f7);

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue[600],
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop()),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
          title: Text('Machine Overview',
              style: TextStyle(
                color: Color(0xffFFFFFF),
                backgroundColor: Colors.lightBlue[600],
              ))),
      backgroundColor: Colors.white,
      body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/Coolantbg.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildBody(context),
                ),
              ),
            ),
          )),
    );
  }
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: DataTable(columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Last Updated')),
              DataColumn(label: Text('Coolant\nPercentage')),
            ], rows: _buildList(context, snapshot.data.documents)),
          ),
        );
      }
    },
  );
}

List _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
  return snapshot.map((data) => _buildListItem(context, data)).toList();
}

DataRow _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
  DocumentSnapshot machines = snapshot;

  return DataRow(cells: [
    DataCell(Text(machines['name'])),
    DataCell(Text(machines['last-updated'].substring(0, 10))),
    DataCell(Text(
      machines['coolant-percent'],
      style: TextStyle(
          color: double.parse(machines['coolant-percent']) < 6.0
              ? Colors.red
              : Colors.green),
    )),
  ]);
}
