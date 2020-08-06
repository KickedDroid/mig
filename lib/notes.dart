import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:mig/batch.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import './graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'extensions.dart';

const greenPercent = Color(0xff14c4f7);

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      appBar: AppBar(
          title: Text('User Notes',
              style: TextStyle(
                color: Color(0xffFFFFFF),
                backgroundColor: Colors.lightBlue[600],
              ))),
      body: SafeArea(
        child: StreamBuilder(
          stream:
              Firestore.instance.collection(box.get('companyId')).snapshots(),
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
                    notes: machines['note'] ?? "No data",
                  );
                },
              );
            }
          },
        ),
      ),

    );
  }
}

class MachineItem extends StatelessWidget {
  final String name;
  final String notes;
  //final String c_percent;

  MachineItem({this.notes, this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(notes),
      subtitle: Text(name),
    );
  }
}


