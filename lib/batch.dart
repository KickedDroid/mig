import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:dio/dio.dart';

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
                  builder: (context) => WelcomeScreen(),
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
          if (controllerCmin.text.length == 0) {
            Toast.show("Enter a Min and Max", context,
                duration: Toast.LENGTH_LONG);
          } else {
            show();
          }
        },
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Text(
              'Create Multiple Machines',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ).padding(),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Number of Machines to Add',
                labelStyle: TextStyle(fontSize: 15),
              ),
            ).padding(),
            TextFormField(
              controller: controller2,
              style: TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name of Batch',
                labelStyle: TextStyle(fontSize: 15),
              ),
            ).padding(),
            TextFormField(
              controller: controllerCmin,
              style: TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Min',
                labelStyle: TextStyle(fontSize: 15),
              ),
            ).padding(),
            TextFormField(
              controller: controllerCmax,
              style: TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
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
  String _dataString = "Hello from this QR";

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

      await Share.file(
          _dataString, '${widget.name}.png', pngBytes, '${widget.name}/png');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> createPdf() async {
    final pdf = pw.Document();

    final data = await Firestore.instance
        .collection(box.get('companyId'))
        .getDocuments();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.ListView.builder(
              itemCount: data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot machines = data.documents[index];
                return pw.Column(children: [
                  pw.Text(machines['name']),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: machines.documentID,
                  )
                ]);
              },
            ),
          );
        },
      ),
    );
    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/batch.pdf').create();
    await file.writeAsBytes(pdf.save());
    await Share.file(_dataString, 'batch.pdf', pdf.save(), 'batch/pdf');
  }

  getPermission() async {
    await Permission.photos.request();
    var status = await Permission.photos.status;
    print(status);
  }

  final pdf = pw.Document();

  getQrCodes() async {
    getPermission();
    var docs = await Firestore.instance
        .collection(box.get('companyId'))
        .getDocuments();
    docs.documents.forEach((document) async {
      var response = await Dio().get(
          "https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=${document.documentID}",
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          name: "${document.data['name']}");
      print(result);
    });

    Toast.show('Check Your Photos', context);
  }

  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.share),
            onPressed: () async {
              await getQrCodes();
            }),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 1,
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection(box.get('companyId'))
                        .snapshots(),
                    builder: (context, snapshot) {
                      assert(snapshot != null);
                      if (!snapshot.hasData) {
                        return Text('Please Wait');
                      } else {
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot machines =
                                snapshot.data.documents[index];
                            return QrItem(
                              docRef: machines.documentID,
                            );
                          },
                        );
                      }
                    },
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

class QrItem extends StatelessWidget {
  final docRef;
  const QrItem({Key key, this.docRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            docRef,
            style: TextStyle(fontSize: 12.0),
          ),
          QrImage(
              size: 100,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              data: docRef),
        ],
      ),
    );
  }
}
