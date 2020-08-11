import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:majascan/majascan.dart';
import 'package:mig/updatemachine.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

import 'generateQr.dart';

class QrPage extends StatefulWidget {
  QrPage({Key key}) : super(key: key);

  @override
  _QrPageState createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  String result = "";

  Future _scanQR() async {
    try {
      String qrResult = await MajaScan.startScan(
          title: "Scan Machine",
          titleColor: Colors.blue,
          qRCornerColor: Colors.blueAccent,
          qRScannerColor: Colors.blue);
      setState(() {
        result = qrResult;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateMachinePageQr(result),
        ),
      );
    } on PlatformException catch (ex) {
      if (ex.code == MajaScan.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => _scanQR(),
        onLongPress: () => _scanQR(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      colors: [Colors.blueAccent[700], Colors.blue])),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  Text(
                    ' Scan Machine QR Code',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

class UpdateMachinePage extends StatefulWidget {
  final String docRef;
  final String name;

  UpdateMachinePage(this.docRef, this.name);

  @override
  _UpdateMachinePageState createState() => _UpdateMachinePageState();
}

class _UpdateMachinePageState extends State<UpdateMachinePage> {
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
                    '${widget.name}',
                    style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
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

class GenerateButton extends StatelessWidget {
  const GenerateButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GenerateScreen()));
        },
        onLongPress: () => {},
        child: Container(
            height: 50,
            width: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                    colors: [Colors.lightBlue, Colors.lightBlueAccent])),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_applications,
                  color: Colors.white,
                ),
                Text(
                  ' Generate QR Code',
                  style: TextStyle(color: Colors.white),
                )
              ],
            )),
      ),
    );
  }
}
