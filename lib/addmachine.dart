import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:mig/batch.dart';
import 'package:mig/machines.dart';
import 'package:mig/qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toast/toast.dart';
import 'extensions.dart';
import 'generateQr.dart';
import 'namechange.dart';

const greenPercent = Color(0xff14c4f7);

class AddMachineList extends StatefulWidget {
  @override
  _AddMachineListState createState() => _AddMachineListState();
}

class _AddMachineListState extends State<AddMachineList> {
  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
          backgroundColor: Color(0xFF1c6b92),
          title: Text('Setup & Add Machines',
              style: TextStyle(
                color: Color(0xffFFFFFF),
              ))),
      body: MachineList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1c6b92),
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 250,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Machine',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => _handleWidget()));
                          },
                          onLongPress: () => {},
                          child: Container(
                              height: 50,
                              width: 300,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Colors.lightBlue,
                                    Colors.lightBlueAccent
                                  ])),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings_applications,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    ' Add Machine',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                        ),
                      ).padding(),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        _handleWidgetBatch()));
                          },
                          onLongPress: () => {},
                          child: Container(
                              height: 50,
                              width: 300,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Colors.blue,
                                    Colors.blueAccent
                                  ])),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ' Batch Add',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                        ),
                      ).padding(),
                    ],
                  ).padding(),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddMachinePage extends StatefulWidget {
  AddMachinePage({Key key}) : super(key: key);

  @override
  _AddMachinePageState createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  var time = new DateTime.now();

  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();

  String name;

  TextEditingController controller;
  String cmin;
  String cmax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            var box = Hive.box('myBox');
            if (cmin != null && cmax != null) {
              Firestore.instance
                  .collection(box.get('companyId'))
                  .document("$name")
                  .setData({
                "name": "$name",
                "coolant-percent": "0.0",
                "last-updated": "$time",
                "last-cleaned": "$time",
                "c-min": "$cmin",
                "c-max": "$cmax"
              });
              Firestore.instance
                  .collection(box.get('companyId'))
                  .document("$name")
                  .collection('notes')
                  .document("$time")
                  .setData({"note": "No Notes", "time": "$time"});
              Firestore.instance
                  .collection(box.get('companyId'))
                  .document("$name")
                  .collection('history')
                  .document("$time")
                  .setData({"data": "0.0", "time": "$time"});
              Navigator.pop(context);
            } else {
              Toast.show('Enter Input Data', context,
                  duration: Toast.LENGTH_LONG);
            }
          }),
      appBar: AppBar(
        title: Text('Add a Machine'),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1c6b92),
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
      decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                Colors.white,
                Colors.blue[50],
                Colors.lightBlue[100],
                Colors.lightBlue[50],
              ],
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(00.0),
            // the box shawdow property allows for fine tuning as aposed to shadowColor
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start ,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Text(
              "Add a Machine",
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w400),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height *.35,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                      controller: controller,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          labelText: 'Add Machine Name',
                          labelStyle: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          cmin = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          labelText: 'Enter Min Coolant %',
                          labelStyle: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          cmax = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                      controller: controller,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          labelText: 'Enter Max Coolant %',
                          labelStyle: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ).padding(),
          ),
        ],
      ),
    );
  }
}

Widget _handleWidget() {
  return ValueListenableBuilder(
    valueListenable: Hive.box('myBox').listenable(),
    builder: (BuildContext context, box, Widget child) {
      var isAdmin = box.get('admin');
      if (isAdmin == false) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF1c6b92),
            ),
            body: Center(
                child: Text("Denied: Must be an Administrator",
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ))));
      } else {
        return AddMachinePage();
      }
    },
  );
}

Widget _handleWidgetBatch() {
  return ValueListenableBuilder(
    valueListenable: Hive.box('myBox').listenable(),
    builder: (BuildContext context, box, Widget child) {
      var isAdmin = box.get('admin');
      if (isAdmin == false) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF1c6b92),
            ),
            body: Center(
                child: Text("Denied: Must be an Administrator",
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ))));
      } else {
        return BatchAddPage();
      }
    },
  );
}
