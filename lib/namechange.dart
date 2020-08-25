import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeNamePage extends StatefulWidget {
  final String docRef;

  ChangeNamePage(this.docRef);

  @override
  _ChangeNamePageState createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  String newName = "";

  getTextInputData() {
    setState(() {
      newName = controller.text;
    });
  }

  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Color(0xFF1c6b92),
        title: Text('Edit Machine Name'),
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF1c6b92),
          onPressed: () {
            getTextInputData();
            _changeName(widget.docRef, newName);
            Navigator.of(context).pop();
          },
          child: Icon(Icons.edit),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Color(0xFF1c6b92),
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 0.5, 0.7, 0.9],
                colors: [
                  Colors.white,
                  Colors.blue[50],
                  Colors.lightBlue[100],
                  Colors.lightBlue[200],
                ],
              ),

              color: Colors.white,

              borderRadius: BorderRadius.circular(00.0),

              // the box shawdow property allows for fine tuning as aposed to shadowColor
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Text(
                    'Edit Name of Machine',
                    style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: controller,
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'SFUIDisplay'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'New Name',
                        labelStyle: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _changeName(String docRef, String newName) async {
  var box = Hive.box('myBox');

  await Firestore.instance
      .collection(box.get('companyId'))
      .document("$docRef")
      .updateData({
    "name": "$newName",
  });
}
