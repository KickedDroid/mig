import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import './graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const greenPercent = Color(0xff14c4f7);

class AddMachineList extends StatefulWidget {
  @override
  _AddMachineListState createState() => _AddMachineListState();
}

class _AddMachineListState extends State<AddMachineList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Machine Setup',
              style: TextStyle(
                color: Color(0xffFFFFFF),
                backgroundColor: Colors.lightBlue[600],
              ))),
      
      body: ListView(
        padding: EdgeInsets.all(0),
        children: [
          ListTile(
            selected: true,
            leading: CircleAvatar(
              //backgroundImage: AssetImage('assets/User.png'),
              child: Text("1"),
            ),
            title: Text("M1V1"),
            subtitle: Text("Okuma LB15        8%"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("2"),
            ),
            title: Text("M1V2"),
            subtitle: Text("Haas 2        8%"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("3"),
            ),
            title: Text("M1V3"),
            subtitle: Text("DMG Mori NL2500        8%"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("4"),
            ),
            title: Text("M1V4"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("5"),
            ),
            title: Text("M1V5"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("6"),
            ),
            title: Text("M1V6"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("7"),
            ),
            title: Text("M1V7"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("8"),
            ),
            title: Text("M1V8"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("9"),
            ),
            title: Text("M1V9"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("10"),
            ),
            title: Text("M1V10"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("11"),
            ),
            title: Text("M1V11"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text("12"),
            ),
            title: Text("M1V12"),
            subtitle: Text("You can specify subtitle"),
            trailing: Icon(Icons.more_vert),
            onTap: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
