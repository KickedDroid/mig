import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UpdateMachinePageQr extends StatefulWidget {
  final String docRef;

  UpdateMachinePageQr(this.docRef);

  @override
  _UpdateMachinePageState createState() => _UpdateMachinePageState();
}

class _UpdateMachinePageState extends State<UpdateMachinePageQr> {
  var time = new DateTime.now();

  TextEditingController controller;

  String data;
  String notes;

  bool cleaned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(
          'Add Refractometer Reading',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.green[50],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Enter Coolant Percentage",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          data = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Coolant Percentage',
                          labelStyle: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          notes = value;
                        });
                      },
                      controller: controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Add any notes',
                          labelStyle: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
                SwitchListTile(
                    title: Text(
                      "Cleaned Sump",
                      //style: whiteBoldText,
                    ),
                    value: cleaned,
                    onChanged: (val) {
                      setState(() {
                        cleaned = val;
                      });
                    }),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          var box = Hive.box('myBox');
                          if (data != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({
                              "coolant-percent": "$data",
                              "last-updated": "$time"
                            });
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({
                              "history": FieldValue.arrayUnion([
                                {"time": "$time", "data": "$data"},
                              ])
                            });
                          }
                          if (notes != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({
                              "notes": {"time": "$time", "note": "$notes"}
                            });
                          }

                          if (cleaned != false) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .updateData({"last-cleaned": "$time"});
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                            height: 50,
                            width: 300,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  Colors.blueAccent[700],
                                  Colors.blue
                                ])),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Update',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ],
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
