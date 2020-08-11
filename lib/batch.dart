import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'extensions.dart';

class BatchAddPage extends StatefulWidget {
  @override
  _BatchAddPageState createState() => _BatchAddPageState();
}

class _BatchAddPageState extends State<BatchAddPage> {
  int numOf;
  String batchName = "";
  String cmin;
  String cmax;

  getTextInputData() {
    setState(() {
      numOf = int.parse(controller.text);
      batchName = controller2.text;
      cmin = controllerCmin.text;
      cmax = controllerCmax.text;
    });
  }

  show() {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: Text("Batch: $batchName"),
        content: Text("Number of Machines: ${numOf.toString()}"),
        actions: <Widget>[
          FlatButton(
            child: Text('Submit'),
            onPressed: () {
              _batchAdd(batchName, numOf, cmin, cmax);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controllerCmin = TextEditingController();
  final TextEditingController controllerCmax = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1c6b92),
        child: Icon(Icons.check),
        onPressed: () {
          getTextInputData();
          show();
        },
      ),
      body: SafeArea(
        child: Expanded(
          child: Column(
            children: <Widget>[
              Text(
                'Create Multiple Machines',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ).padding(),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of Machines to Add',
                  labelStyle: TextStyle(fontSize: 15),
                ),
              ).padding(),
              TextFormField(
                controller: controller2,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name of Batch',
                  labelStyle: TextStyle(fontSize: 15),
                ),
              ).padding(),
              TextFormField(
                controller: controllerCmin,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Min',
                  labelStyle: TextStyle(fontSize: 15),
                ),
              ).padding(),
              TextFormField(
                controller: controllerCmax,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Max',
                  labelStyle: TextStyle(fontSize: 15),
                ),
              ).padding(),
              Text(
                'This screen allows you to setup multiple machines at once',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ).padding(),
            ],
          ),
        ),
      ),
    );
  }
}

void _batchAdd(String name, int numMachines, String cmin, String cmax) async {
  var box = Hive.box('myBox');
  var time = new DateTime.now();
  for (int i = 1; i <= numMachines; i++) {
    print('For Loop Called $i Times');
    await Firestore.instance
        .collection(box.get('companyId'))
        .document("$name $i")
        .setData({
      "name": "$name $i",
      "coolant-percent": "0.0",
      "last-updated": "$time",
      "last-cleaned": "$time",
      "notes": {"note": "No Notes", "time": "$time"},
      "c-min": "$cmin",
      "c-max": "$cmax"
    });
  }
}
