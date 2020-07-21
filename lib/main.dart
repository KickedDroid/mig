import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mig/qr.dart';
import './signin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splashscreen/splashscreen.dart';
import './machines.dart';
import './qr.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
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
            //return SignInPage();
            return WelcomeScreen();
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
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: MediaQuery.of(context).size.width * .5,
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
                flex: 2,
                child: ListView(children: [
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text("User Account"),
                    onTap: () {
                      Navigator.of(context).pop();
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
                    title: Text("Settings"),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text("Machine Setup"),
                    onTap: () {
                      Navigator.of(context).pop();
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
                    leading: Icon(Icons.exit_to_app),
                    title: Text("Log Out"),
                    onTap: () {
                      signOutGoogle();
                    },
                  )
                ]),
              )
            ],
          ),
        ),
        appBar: AppBar(
            title: Text('Full Shop - Coolant Log',
                style: TextStyle(
                  color: Color(0xffFFFFFF),
                  backgroundColor: Colors.lightBlue[600],
                ))),
        bottomNavigationBar: BottomAppBar(
          elevation: 10.0,
          color: Colors.lightBlue[600],
          child: Row(
            children: [
              IconButton(icon: Icon(Icons.cloud), onPressed: () {}),
              IconButton(icon: Icon(Icons.settings), onPressed: null),
              IconButton(icon: Icon(Icons.create), onPressed: null),
              IconButton(icon: Icon(Icons.history), onPressed: null),
              IconButton(
                  icon: Icon(Icons.list),
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
          backgroundColor: Colors.white,
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
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        body: Text("Fix"));
  }
}
