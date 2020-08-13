import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      ),
      appBar: AppBar(
          backgroundColor: Color(0xFF1c6b92),
          title: Text('User Notes',
              style: TextStyle(
                color: Color(0xffFFFFFF),
              ))),
      body: SafeArea(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection(box.get('companyId'))
              .orderBy("notes.time", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            assert(snapshot != null);
            if (!snapshot.hasData) {
              return Text('Please Wait');
            } else {
              return ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.lightBlue),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot machines = snapshot.data.documents[index];
                  return MachineItem(
                    notes: Notes.fromMap(machines['notes']),
                    name: machines['name'],
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

class Notes {
  final String note;
  final String date;

  Notes(this.date, this.note);

  Notes.fromMap(Map<String, dynamic> map)
      : note = map['note'],
        date = map['time'];
}

class MachineItem extends StatelessWidget {
  final Notes notes;
  final String name;
  //final String c_percent;

  MachineItem({this.notes, this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon (Icons.note),
      title: Text(
        name,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(notes.note + " (" + notes.date.substring(5, 7) + "/" + notes.date.substring(8, 10) + "/" + notes.date.substring(2, 4) + ") " ?? "NO Data"),
    );
  }
}
