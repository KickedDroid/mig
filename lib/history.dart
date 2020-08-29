import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mig/graph.dart';

class HistoryPage extends StatelessWidget {
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
        backgroundColor: Color(0xFF1c6b92),
        title: Text('Coolant Concentration History'),
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
                    Card(
                      elevation: 10,
                      child: ListTile(
                        title: Text(machines['name']),
                        leading: Icon(Icons.show_chart),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MachineGraph(
                                  machines.documentID,
                                  double.parse(machines['c-min']),
                                  double.parse(machines['c-max'])),
                            ),
                          );
                        },
                      ),
                    ),
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
