import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:majascan/majascan.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
          builder: (context) => UpdateMachinePage(result),
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

  UpdateMachinePage(this.docRef);

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
                    '${widget.docRef}',
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
                              "name": "${widget.docRef}",
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
                                .document("${widget.name}")
                                .updateData({
                              "notes": {"time": "$time", "note": "$notes"}
                            });
                          }

                          if (cleaned != false) {
                            Firestore.instance
                                .collection(box.get('companyId'))
                                .document("${widget.name}")
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

class GenerateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actionsIconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.black,
            ),
            onPressed: _captureAndSharePng,
          )
        ],
      ),
      body: _contentWidget(),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.file(_dataString, '$_dataString.png', pngBytes, 'image/png');
    } catch (e) {
      print(e.toString());
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child: Container(
              height: _topSectionHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(color: Colors.blueAccent)),
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: "Enter a machine name",
                          errorText: _inputErrorText,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FlatButton(
                      color: Colors.blueAccent[700],
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          _dataString = _textController.text;
                          _inputErrorText = null;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        10,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RepaintBoundary(
                      key: globalKey,
                      child: QrImage(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        data: _dataString,
                        size: 0.5 * bodyHeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
