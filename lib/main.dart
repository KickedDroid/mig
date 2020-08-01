import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:mig/qr.dart';
import './signin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splashscreen/splashscreen.dart';
import './machines.dart';
import './addmachine.dart';
import './useraccount.dart';
import './overview.dart';
import './qr.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:hive_flutter/hive_flutter.dart';

main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new SplashScreen(
        seconds: 3,
        navigateAfterSeconds: _handleWidget(),
        title: new Text(
          'Welcome To 168 Manufacturing',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.asset('assets/168.png'),
        //backgroundGradient: new LinearGradient(colors: [Colors.cyan, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/HomePage': (BuildContext) => WelcomeScreen(),
        '/Machines': (BuildContext) => MachineList(),
        '/Addmachines': (BuildContext) => AddMachineList(),
        '/Useraccount': (BuildContext) => new UserAccount(),
        '/Overview': (BuildContext) => new Overview(),
        '/FAQ': (BuildContext) => WebviewScaffold(
            url: 'https://168mfg.com/system/',
            appBar: AppBar(title: Text('Webview'))),
        '/PPO': (BuildContext) => WebviewScaffold(
            url: 'https://cncdirt.com/privacypolicy/',
            appBar: AppBar(title: Text('Webview'))),
        '/TDC': (BuildContext) => WebviewScaffold(
              url:
                  'https://www.termsfeed.com/blog/sample-terms-and-conditions-template/',
              appBar: AppBar(
                title: Text('Webview'),
              ),
            )
      },
    );
  }
}

void signOut() async {
  FirebaseAuth.instance.signOut();
}

void signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Sign Out");
}

Widget _handleWidget() {
  return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text('Loading'),
          );
        } else {
          if (snapshot.hasData) {
            return WelcomeScreen();
          } else {
            return SignInPage();
            //return WelcomeScreen();
          }
        }
      });
}

class WelcomeScreen extends StatelessWidget {
  final GlobalKey _scaffoldKey = new GlobalKey();

  String result = "Scan a Qr Code to begin";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width * .4,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/logosb.png"),
                              fit: BoxFit.cover)),
                      child: null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ListView(children: [
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text("User Account"),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/Useraccount');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.question_answer),
                      title: Text("FAQ"),
                      onTap: () {
                        Navigator.pushNamed(context, '/FAQ');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text("Privacy Policy"),
                      onTap: () {
                        Navigator.pushNamed(context, '/PPO');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text("Terms & Conditions"),
                      onTap: () {
                        Navigator.pushNamed(context, '/TDC');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: new Text("Settings"),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text("Machine Setup"),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/Addmachines');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.history),
                      title: Text("History"),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("About"),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text("Log Out"),
                      onTap: () {
                        signOutGoogle();
                        signOut();
                      },
                    )
                  ]),
                )
              ],
            ),
          ),
        ),
        appBar: AppBar(
            title: Text('Full Shop - Coolant Overview',
                style: TextStyle(
                  color: Color(0xffFFFFFF),
                  backgroundColor: Colors.lightBlue[600],
                ))),
        bottomNavigationBar: BottomAppBar(
          elevation: 10.0,
          color: Colors.lightBlue[600],
          child: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.grid_on),
                  color: Colors.white,
                  onPressed: () async =>
                      Navigator.pushNamed(context, "/Overview")),
              IconButton(
                  icon: Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: null),
              IconButton(
                  icon: Icon(Icons.create),
                  color: Colors.white,
                  onPressed: () async =>
                      Navigator.pushNamed(context, "/Addmachines")),
              IconButton(
                  icon: Icon(Icons.timeline),
                  color: Colors.white,
                  onPressed: null),
              IconButton(
                  icon: Icon(Icons.list),
                  color: Colors.white,
                  onPressed: () async =>
                      Navigator.pushNamed(context, "/Machines")),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          notchMargin: 5.0,
          shape: CircularNotchedRectangle(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          elevation: 5.0,
          backgroundColor: Colors.lightBlue[600],
          onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 250,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Coolant Concentration',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QrPage(),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [GenerateButton()],
                        )
                      ],
                    ),
                  ),
                );
              }),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[50],
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 50.0),
                    child: Container(
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
                      child: Column(children: <Widget>[
                        ListTile(
                          title: Text(
                            "Latest Entries",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Text("Machine: Mori 3"),
                          subtitle: Text("07/20/20, 10.2% Concentration"),
                          leading: Icon(Icons.assessment),
                          trailing: Icon(Icons.menu),
                        ),
                        ListTile(
                          title: Text("Machine: Mori 3"),
                          subtitle: Text("07/19/20, 9.6% Concentration"),
                          leading: Icon(Icons.assessment),
                          trailing: Icon(Icons.menu),
                        ),
                      ]),
                    ),
                  ),
                  Divider(),
                  StreamBuilder(
                    stream:
                        Firestore.instance.collection("companies").snapshots(),
                    builder: (context, snapshot) {
                      assert(snapshot != null);
                      if (!snapshot.hasData) {
                        return Text('PLease Wait');
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot machines =
                                snapshot.data.documents[index];
                            return ListTile(
                              title: Text(machines['name']),
                              subtitle: Text(
                                  "${machines['last-updated']}, ${machines['coolant-percent']} Concentration"),
                              leading: Icon(Icons.assessment),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            )));
  }
}
