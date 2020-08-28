import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';

class HistoryLatestEntriesPage extends StatefulWidget {
  final String docRef;
  HistoryLatestEntriesPage(this.docRef);

  @override
  _HistoryLatestEntriesPageState createState() =>
      _HistoryLatestEntriesPageState();
}

class _HistoryLatestEntriesPageState extends State<HistoryLatestEntriesPage> {
  var box = Hive.box('myBox');

  void deleteEntry(String docRef, String entry) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text("Are You Sure You Want To Delete Entry?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Submit'),
            onPressed: () {
              Firestore.instance
                  .collection(box.get('companyId'))
                  .document(docRef)
                  .collection('history')
                  .document(entry)
                  .delete();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

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
                .document(widget.docRef)
                .collection('history')
                .orderBy('time')
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
                    return Slidable(
                      secondaryActions: <Widget>[
                        IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              deleteEntry(widget.docRef, machines.documentID);
                            }),
                      ],
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      child: Card(
                        child: ListTile(
                          title: Text(
                            machines['data'] != null
                                ? '${machines['data']} '
                                : "No Entries Yet",
                          ),
                          subtitle: Text(
                              "(${machines['time'].substring(5, 7) + "/" + machines['time'].substring(8, 10) + "/" + machines['time'].substring(2, 4)})"),
                          //subtitle: Text('Date:  ${machines['last-updated'].substring(5,10)}'),
                          leading: Icon(Icons.assessment),
                        ),
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
