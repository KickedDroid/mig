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
    return Scaffold(
        backgroundColor: Colors.blueAccent[300],
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_back),
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
                return Text('PLease Wait');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot machines = snapshot.data.documents[index];
                    return MachineItem(
                      name: machines['name'],
                      c_percent: machines['coolant-percent'],
                      last_updated: machines['last-updated'],
                    );
                  },
                );
              }
            },
          ),
        ));
  }
}

class MountainList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('machines').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((document) {
            return new ListTile(
              title: new Text(document['name']),
              subtitle: new Text(document['coolant-percent']),
            );
          }).toList(),
        );
      },
    );
  }
}

class MachineItem extends StatelessWidget {
  final String name;
  final String last_updated;
  final String c_percent;

  MachineItem({this.name, this.last_updated, this.c_percent});

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
                  LineChartSample2(),
                  GestureDetector(
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
                        width: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Colors.blueGrey[300],
                              Colors.blueGrey
                            ])),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Edit Machine',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        )),
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
