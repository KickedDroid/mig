import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const greenPercent = Color(0xff14c4f7);

class NotesList extends StatefulWidget {
  final String docRef;

  NotesList(this.docRef);

  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  var box = Hive.box('myBox');

  TextEditingController controller = TextEditingController();

  void deleteNote(String docRef, String item) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Are You Sure You Want To Delete?"),
        content: Text(""),
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
                  .collection('notes')
                  .document(item)
                  .delete();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void editNote(String docRef, String item, String note) {
    setState(() {
      controller = new TextEditingController(text: note);
    });
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
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot machines = snapshot.data.documents[index];
                  return Card(
                    elevation: 5,
                    child: (
                      Slidable(
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Edit Note',
                            color: Colors.black45,
                            icon: Icons.edit,
                            onTap: () => {
                              editNote(widget.docRef, machines.documentID,
                                  machines['note'])
                            },
                          ),
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () =>
                                deleteNote(widget.docRef, machines.documentID),
                          ),
                        ],
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: MachineItem(
                          notes: machines['note'],
                          name: machines['time'],
                        ),
                      )),
                  
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
        trailing: Icon(Icons.delete_sweep),
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
                    Card(
                      elevation: 5,
                    child: ListTile(
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
                    //Divider(color: Colors.blueGrey)
                    ),
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
