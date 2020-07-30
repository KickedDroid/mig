import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/rendering.dart';
import 'package:mig/qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const greenPercent = Color(0xff14c4f7);

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue[600],
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop()),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
          title: Text('Machine Overview',
              style: TextStyle(
                color: Color(0xffFFFFFF),
                backgroundColor: Colors.lightBlue[600],
              ))),
    backgroundColor: Colors.white,
      body: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
          image: new AssetImage("assets/Coolantbg.png"),
          fit: BoxFit.fill,
        ),
      ),
            child: Center(
          child: ListView(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: new Container(
                    height: 590.0,
                    width: 500.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: FittedBox(
                          child: DataTable(
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Coolant %',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Last Entry',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Last Cleaned',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ],
                            rows: <DataRow>[
                              DataRow(cells: [
                                DataCell(Text(
                                  'Mori 1',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '8.0%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '0 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '18 Months',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Mori 2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.2%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '14 Months',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Mori 3',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '10.2%',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '5 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Citizen 2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '6.4%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '3 Days',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Miyano 4',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.6%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Miyano 5',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.1%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '2 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '8 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Citizen 3',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '9.3%',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '4 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Okuma 1',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '8.5%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '5 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Okuma 2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '6.5%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '2 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '12 Months',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Okuma 3',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.9%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '10 Days',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Okuma 4',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.3%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '2 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Haas 1',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.6%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '20 Days',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Haas 2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '9.2%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Haas 3',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '8.5%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '6 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Haas 4',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '2.5%',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '1 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '6 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Matsura 1',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.6%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '4 Days',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '2 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Matsura 2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.6%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '2 Days',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '8 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'Matsura 3',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7.6%',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '5 Days',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                  ),
                                )),
                                DataCell(Text(
                                  '7 Months',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.0,
                                  ),
                                )),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )),
    );
  }
}