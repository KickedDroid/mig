import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StrongPage extends StatefulWidget {
  StrongPage({Key key}) : super(key: key);

  @override
  _StrongPageState createState() => _StrongPageState();
}

class _StrongPageState extends State<StrongPage> {
  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        notchMargin: 0.0,
        shape: CircularNotchedRectangle(),
      ),

      appBar: AppBar(
        title: Text('Highest Concentrations'),
        backgroundColor: Color(0xFF1c6b92)),
      body: ListView(
        children: [
          ListTile(
            //dense: true,
            title: Text(
              "Highest Coolant % Shop Wide",
              style: TextStyle(
                  color: Color(0xFF3c6172),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text("Account: ${box.get('companyId')}"),
          ),
          StreamBuilder(
                        stream: Firestore.instance
                            .collection(box.get('companyId'))
                            .orderBy('coolant-percent', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          assert(snapshot != null);
                          if (!snapshot.hasData) {
                            return Text('Please Wait');
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot machines =
                                    snapshot.data.documents[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(machines['name'] != null
                                      ? machines['name'] + " (" + "${machines['c-min']}" + "%-" + "${machines['c-max']}" + "%)"
                                      : "No Data"),
                                  leading: Icon(Icons.trending_up),
                                  trailing: Text(machines['coolant-percent'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: double.parse(machines[
                                                          'coolant-percent']) <
                                                      double.parse(
                                                          machines['c-max']) &&
                                                  double.parse(machines[
                                                          'coolant-percent']) >
                                                      double.parse(
                                                          machines['c-min'])
                                              ? Colors.greenAccent[700]
                                              : Colors.red),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
