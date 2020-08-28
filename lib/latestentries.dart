import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LatestEntriesPage extends StatefulWidget {
  LatestEntriesPage({Key key}) : super(key: key);

  @override
  _LatestEntriesPageState createState() => _LatestEntriesPageState();
}

class _LatestEntriesPageState extends State<LatestEntriesPage> {
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
          title: Text('Latest Entries'), backgroundColor: Color(0xFF1c6b92)),
      body: ListView(
        children: [
          ListTile(
            //dense: true,
            title: Text(
              "Entries Sorted by date",
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
                .orderBy('last-updated', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              //assert(snapshot != null);
              if (!snapshot.hasData) {
                return Text('Please Wait');
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot machines = snapshot.data.documents[index];
                    return Dismissible(
                      key: Key(machines.documentID),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          machines['name'] != null
                              ? '${machines['name']}:  ${machines['coolant-percent']}%  (${machines['last-updated'].substring(5, 7) + "/" + machines['last-updated'].substring(8, 10) + "/" + machines['last-updated'].substring(2, 4)})'
                              : "No machines yet",
                        ),
                        //subtitle: Text('Date:  ${machines['last-updated'].substring(5,10)}'),
                        leading: Icon(Icons.assessment),
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
