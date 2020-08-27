import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:hive/hive.dart';
import 'namechange.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'generateQr.dart';
import 'qr.dart';
import 'extensions.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const greenPercent = Color(0xff009970);

class MachineList extends StatefulWidget {
  @override
  _MachineListState createState() => _MachineListState();
}

class _MachineListState extends State<MachineList> {
  var box = Hive.box('myBox');

  deleteMachine(String docRef) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Are You Sure You Want To Delete?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Submit'),
            onPressed: () {
              Firestore.instance
                  .collection(box.get('companyId'))
                  .document(docRef)
                  .delete();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

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
            body: SafeArea(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection(box.get('companyId'))
                    .orderBy("name", descending: false)
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
                        return Slidable(
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () => {deleteMachine(machines.documentID)},
                            ),
                          ],
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: MachineItem(
                            name: machines['name'],
                            c_percent: machines['coolant-percent'],
                            last_updated:
                                machines['last-updated'].substring(5, 7) +
                                    "/" +
                                    machines['last-updated'].substring(8, 10) +
                                    "/" +
                                    machines['last-updated'].substring(0, 4),
                            notes: machines['history'],
                            docRef: machines.documentID,
                            cMin: double.parse(machines['c-min']),
                            cMax: double.parse(machines['c-max']),
                          ),
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
  final double cMin;
  final double cMax;

  MachineItem(
      {this.name,
      this.last_updated,
      this.c_percent,
      this.notes,
      this.docRef,
      this.cMin,
      this.cMax});

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(last_updated != null
                          ? "Last Updated: " + last_updated
                          : 'Last Updated'),
                      Text(cMax != null
                          ? "Concentration Limits: (" +
                              cMin.toStringAsFixed(0) +
                              "% -" +
                              cMax.toStringAsFixed(0) +
                              "%)"
                          : 'LastUpdated'),
                    ],
                  ),
                  Card(
                    color: double.parse(c_percent) < cMax &&
                            double.parse(c_percent) > cMin
                        ? greenPercent
                        : Colors.red,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
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
                  Row(
                    children: <Widget>[
                      Text('Edit Name'),
                      IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 18.0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNamePage(docRef, name),
                              ),
                            );
                          })
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenerateScreen(
                            name: name,
                            docRef: docRef,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        Text('Share QR Code'),
                        QrImage(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          data: docRef,
                          size: 50,
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
                              builder: (context) =>
                                  UpdateMachinePage(docRef, name)),
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
                    ).padding(),
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
