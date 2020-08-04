import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import './graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BatchAddPage extends StatefulWidget {
  @override
  _BatchAddPageState createState() => _BatchAddPageState();
}

class _BatchAddPageState extends State<BatchAddPage> {
  int numOf;
  String batchName = "";

  getTextInputData() {
    setState(() {
      numOf = int.parse(controller.text);
      batchName = controller2.text;
    });
  }

  show() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: Text(batchName),
        content: Text(numOf.toString()),
        actions: <Widget>[
          FlatButton(
            child: Text('Close me!'),
            onPressed: () {
              _batchAdd(batchName, numOf);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            getTextInputData();
            _batchAdd(batchName, numOf);
          }),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Batch Add',
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of Machines to Add',
                  labelStyle: TextStyle(fontSize: 15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller2,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name of Batch',
                  labelStyle: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _batchAdd(String name, int numMachines) async {
  var box = Hive.box('myBox');
  var time = new DateTime.now();
  for (int i = 0; i <= numMachines; i++) {
    print('For Loop Called $i Times');
    await Firestore.instance
        .collection(box.get('companyId'))
        .document("$name $i")
        .setData({
      "name": "$name $i",
      "coolant-percent": "0.0",
      "last-updated": "$time",
      "last-cleaned": "$time"
    });
  }
}
