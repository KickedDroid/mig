import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mig/graph.dart';

class HistoryPage extends StatelessWidget {
  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection(box.get('companyId')).snapshots(),
        builder: (context, snapshot) {
          assert(snapshot != null);
          if (!snapshot.hasData) {
            return Text('Please Wait');
          } else {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot machines = snapshot.data.documents[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(machines['name']),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MachineGraph(machines.documentID),
                          ),
                        );
                      },
                    ),
                    Divider()
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
