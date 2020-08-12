import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BatchQrCodes(
                    name: batchName,
                    numOf: numOf,
                  ),
                ),
              );
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

class BatchQrCodes extends StatefulWidget {
  final String name;
  final int numOf;

  BatchQrCodes({Key key, this.name, this.numOf}) : super(key: key);

  @override
  _BatchQrCodesState createState() => _BatchQrCodesState();
}

class _BatchQrCodesState extends State<BatchQrCodes> {
  GlobalKey globalKey = new GlobalKey();

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.file('Share Qr Codes', '${widget.name}.png', pngBytes,
          '${widget.name}/png');
    } catch (e) {
      print(e.toString());
    }
  }

  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.share),
            onPressed: () {
              _captureAndSharePng();
            }),
        body: Container(
          child: StreamBuilder(
            stream:
                Firestore.instance.collection(box.get('companyId')).snapshots(),
            builder: (context, snapshot) {
              assert(snapshot != null);
              if (!snapshot.hasData) {
                return Text('Please Wait');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot machines = snapshot.data.documents[index];
                    return QrItem(
                      docRef: machines.documentID,
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class QrItem extends StatelessWidget {
  final docRef;
  const QrItem({Key key, this.docRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        child: Column(
          children: [
            Text(
              docRef,
              style: TextStyle(fontSize: 18.0),
            ),
            QrImage(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                data: docRef),
          ],
        ),
      ),
    );
  }
}
