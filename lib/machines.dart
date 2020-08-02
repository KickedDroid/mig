import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import './graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr.dart';

const greenPercent = Color(0xff14c4f7);

class MachineList extends StatefulWidget {
  @override
  _MachineListState createState() => _MachineListState();
}

class _MachineListState extends State<MachineList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1,0.5,0.7,0.9],
          colors: [
            Colors.blue[50],
            Colors.blue[100],
            Colors.blue[200],
            Colors.blue[300],
          ],
        ),
    ),
    child: Scaffold(
        backgroundColor: Color(0x00000000),
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
        body: SafeArea(
          child: StreamBuilder(
            stream: Firestore.instance.collection("companies").snapshots(),
            builder: (context, snapshot) {
              assert(snapshot != null);
              if (!snapshot.hasData) {
                return Text('Please Wait');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot machines = snapshot.data.documents[index];
                    return MachineItem(
                      name: machines['name'],
                      c_percent: machines['coolant-percent'],
                      last_updated: machines['last-updated'].substring(0,10),
                      notes: machines['history'],
                    );
                  },
                );
              }
            },
          ),
        )));
  }
}

class MachineItem extends StatelessWidget {
  final String name;
  final String last_updated;
  final String c_percent;
  final dynamic notes;

  MachineItem({this.name, this.last_updated, this.c_percent, this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          elevation: 10.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ExpandablePanel(
              header: Text(
                name != null ? name : 'Name',
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
              ),
              collapsed: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(last_updated != null ? last_updated : 'LastUpdated'),
                  Card(
                    color: greenPercent,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        c_percent != null ? c_percent : 'Coolant Percent',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                    )),
                  )
                ],
              ),
              expanded: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text(last_updated != null
                            ? last_updated
                            : 'LastUpdated'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Coolant Percent',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w300),
                        ),
                        Card(
                          color: greenPercent,
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              c_percent != null
                                  ? "$c_percent%"
                                  : 'Coolant Percent',
                              style: TextStyle(
                                  fontSize: 24.0, color: Colors.white),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateMachinePage(name),
                          ),
                        );
                      },
                      onLongPress: () => {},
                      child: Container(
                          height: 40,
                          width: 180,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.orange[500]])),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enter Coolant %',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              )
                            ],
                          )),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Notes {
  final String note;
  final String date;

  Notes({this.date, this.note});

  factory Notes.fromMap(Map data) {
    return Notes(note: data['note'], date: data['time']);
  }
}
