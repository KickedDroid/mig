import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const greenPercent = Color(0xff14c4f7);

class NotesList extends StatefulWidget {
  final String docRef;

  NotesList(this.docRef);

  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  var box = Hive.box('myBox');

  final TextEditingController controller = TextEditingController();

  void deleteNote(String docRef, String item) {
    Firestore.instance
        .collection(box.get('companyId'))
        .document(docRef)
        .collection('notes')
        .document(item)
        .delete();
  }

  void editNote(String docRef, String item) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Edit Note"),
        content: TextField(
          controller: controller,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Submit'),
            onPressed: () {
              Firestore.instance
                  .collection(box.get('companyId'))
                  .document(docRef)
                  .collection('notes')
                  .document(item)
                  .updateData({"note": "${controller.text}"});
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

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
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
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
              .document("${widget.docRef}")
              .collection('notes')
              .orderBy('time', descending: true)
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
                  return Dismissible(
                    onDismissed: (direction) {
                      deleteNote(widget.docRef, machines.documentID);
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("Note deleted")));
                    },
                    background: Container(
                      color: Colors.red,
                    ),
                    key: Key(widget.docRef),
                    child: GestureDetector(
                      onTap: () {
                        editNote(widget.docRef, machines.documentID);
                      },
                      child: MachineItem(
                        notes: machines['note'],
                        name: machines['time'],
                      ),
                    ),
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

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
        title: Text('Notes'),
        backgroundColor: Color(0xFF1c6b92),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection(box.get('companyId')).snapshots(),
        builder: (context, snapshot) {
          assert(snapshot != null);
          if (!snapshot.hasData) {
            return Text('Please Wait');
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot machines = snapshot.data.documents[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(machines['name']),
                      leading: Icon(Icons.note),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NotesList(machines.documentID),
                          ),
                        );
                      },
                    ),
                    Divider()
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
