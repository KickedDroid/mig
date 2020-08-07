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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getTextInputData();
            _changeName(widget.docRef, newName);
          },
          child: Icon(Icons.edit),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
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
