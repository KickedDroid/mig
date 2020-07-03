import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mig/qr.dart';
import './signin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:majascan/majascan.dart';
import './machines.dart';
import './qr.dart';

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
        seconds: 14,
        navigateAfterSeconds: new SignInPage(),
        title: new Text(
          'Welcome In SplashScreen',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        image: new Image.asset('assets/168.png'),
        //backgroundGradient: new LinearGradient(colors: [Colors.cyan, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.red,
      ),
      routes: <String, WidgetBuilder>{
        '/HomePage': (BuildContext) => WelcomeScreen(),
        '/Machines': (BuildContext) => MachineList(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final GlobalKey _scaffoldKey = new GlobalKey();

  String result = "Scan a Qr Code to begin";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'FAQ',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 36),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.menu), onPressed: () => {}),
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
        backgroundColor: Colors.white,
        onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 500,
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Info',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      QrPage(),
                      Text(result),
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
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: new Container(
                    height: 500.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      // the box shawdow property allows for fine tuning as aposed to shadowColor
                      boxShadow: [
                        new BoxShadow(
                            color: Colors.black45,
                            // offset, the X,Y coordinates to offset the shadow
                            offset: new Offset(0.0, 10.0),
                            // blurRadius, the higher the number the more smeared look
                            blurRadius: 10.0,
                            spreadRadius: 1.0)
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/168.png'),
                        ),
                        Text(
                          'User ID',
                          style: TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Company ID',
                          style: TextStyle(fontSize: 28.0),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
