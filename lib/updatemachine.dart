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
  String name;
  String data;
  String notes;

  bool cleaned = false;

  final cminController = TextEditingController();
  final cmaxController = TextEditingController();
  final ctargetController = TextEditingController();
  final cuwarningController = TextEditingController();
  final clwarningController = TextEditingController();

  String cMin;
  String cMax;
  String cTarget;
  String cUwarning;
  String cLwarning;

  void getInputData() {
    setState(() {
      cMin = cminController.text;
      cMax = cmaxController.text;
      cTarget = ctargetController.text;
      cUwarning = cuwarningController.text;
      cLwarning = clwarningController.text;
    });
  }

  Future<void> getName(String docRef) async {
    var box = Hive.box('myBox');
    var doc = await Firestore.instance
        .collection(box.get('companyId'))
        .document(docRef)
        .get();
    setState(() {
      name = doc.data['name'];
    });
    print(doc.data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName(widget.docRef);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(
          'Add Refractometer Reading',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Color(0xFF1c6b92),
        iconTheme: IconThemeData(color: Colors.white),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name ?? "Invalid Qr Code",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                          labelText: 'Add any notes (Optional)',
                          labelStyle: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
                // Row(
                //   children: [
                //     TextField(
                //       controller: cminController,
                //       decoration: InputDecoration(
                //           border: OutlineInputBorder(),
                //           labelText: 'Add any notes',
                //           labelStyle: TextStyle(fontSize: 15)),
                //     ),
                //     TextField(
                //       controller: cmaxController,
                //       decoration: InputDecoration(
                //           border: OutlineInputBorder(),
                //           labelText: 'Add any notes',
                //           labelStyle: TextStyle(fontSize: 15)),
                //     ),
                //   ],
                // ),
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
                                .collection('history')
                                .document("$time")
                                .setData({"data": "$data", "time": "$time"});
                          }
                          if (notes != null) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.docRef}")
                                .collection("notes")
                                .document("$time")
                                .setData({"note": "$notes", "time": "$time"});
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
