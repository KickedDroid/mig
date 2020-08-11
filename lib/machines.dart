import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:hive/hive.dart';
import 'package:mig/namechange.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'generateQr.dart';
import 'qr.dart';

const greenPercent = Color(0xff009970);

class MachineList extends StatefulWidget {
  @override
  _MachineListState createState() => _MachineListState();
}

class _MachineListState extends State<MachineList> {
  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 0.2, 0.8, 0.9],
            colors: [
              Colors.white,
              Colors.blue[50],
              Colors.blue[100],
              Colors.white,
            ],
          ),
        ),
        child: Scaffold(
            backgroundColor: Color(0x00000000),
            bottomNavigationBar: BottomAppBar(
              color: Color(0xFF1c6b92),
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
                stream: Firestore.instance
                    .collection(box.get('companyId'))
                    .snapshots(),
                builder: (context, snapshot) {
                  assert(snapshot != null);
                  if (!snapshot.hasData) {
                    return Text('Please Wait');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot machines =
                            snapshot.data.documents[index];
                        return MachineItem(
                          name: machines['name'],
                          c_percent: machines['coolant-percent'],
                          last_updated:
                              machines['last-updated'].substring(0, 10),
                          notes: machines['history'],
                          docRef: machines.documentID,
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
  final String docRef;
  final String name;
  final String last_updated;
  final String c_percent;
  final dynamic notes;

  MachineItem(
      {this.name, this.last_updated, this.c_percent, this.notes, this.docRef});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: Color(0xFFffffff),
          elevation: 3.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ExpandablePanel(
              header: Text(
                name != null ? name : 'Name',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[500]),
              ),
              collapsed: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(last_updated != null ? last_updated : 'LastUpdated'),
                  Card(
                    color: double.parse(c_percent) < 6
                        ? Colors.grey[200]
                        : greenPercent,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Text(
                        c_percent != null ? c_percent : 'Coolant Percent',
                        style: TextStyle(
                            fontSize: 24.0,
                            color: double.parse(c_percent) < 6
                                ? Color(0xFFff0000)
                                : Colors.white),
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
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateMachinePage(docRef, name),
                          ),
                        );
                      },
                      onLongPress: () => {},
                      child: Container(
                        height: 40,
                        width: 350,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(colors: [
                              Colors.lightBlue[300],
                              Colors.lightBlue[400]
                            ])),
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
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      8,
                      0,
                      8,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNamePage(docRef),
                          ),
                        );
                      },
                      onLongPress: () => {},
                      child: Container(
                          height: 40,
                          width: 350,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: LinearGradient(colors: [
                                Color(0xFF1c6b92),
                                Color(0xFF217ca9)
                              ])),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Edit Name',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              )
                            ],
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenerateScreen(
                            name: docRef,
                          ),
                        ),
                      );
                    },
                    onLongPress: () => {},
                    child: Container(
                        height: 40,
                        width: 350,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                                colors: [Color(0xFF1c6b92), Colors.blueGrey])),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Generate Qr Code',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        )),
                  ),
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
