import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:mig/batch.dart';
import 'package:mig/graph.dart';
import 'package:mig/history.dart';
import 'package:mig/initialpage.dart';
import 'package:mig/latestentries.dart';
import 'package:mig/diluted.dart';
import 'package:mig/strongcoolant.dart';
import 'package:mig/qr.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import './signin.dart';
import 'package:splashscreen/splashscreen.dart';
import './machines.dart';
import './addmachine.dart';
import './notes.dart';
import './useraccount.dart';
import './overview.dart';
import './qr.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'graph.dart';
import 'package:flutter/services.dart';

main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setPreferredOrientations([
    // DeviceOrientation.portraitUp,
    // ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        image: new Image.asset('assets/168.png'),
        //backgroundGradient: new LinearGradient(colors: [Colors.cyan, Colors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Flutter Egypt"),
        loaderColor: Color(0xFF1c6b92),
      ),
      routes: <String, WidgetBuilder>{
        '/Machines': (BuildContext context) => MachineList(),
        '/Addmachines': (BuildContext context) => AddMachineList(),
        '/Notes': (BuildContext context) => NotesPage(),
        '/BatchQrCodes': (BuildContext context) => BatchQrCodes(),
        '/Useraccount': (BuildContext context) => new UserAccount(),
        '/Overview': (BuildContext context) => new Overview(),
        '/History': (BuildContext context) => HistoryPage(),
        '/FAQ': (BuildContext context) => WebviewScaffold(
            url: 'https://168mfg.com/system/',
            appBar: AppBar(title: Text('Webview'))),
        '/PPO': (BuildContext context) => WebviewScaffold(
            url: 'https://cncdirt.com/privacypolicy/',
            appBar: AppBar(title: Text('Webview'))),
        '/TDC': (BuildContext context) => WebviewScaffold(
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
  final GoogleSignIn googleSignIn = GoogleSignIn();
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
            return InitialPage();
            //return WelcomeScreen();
          }
        }
      });
}

class WelcomeScreen extends StatelessWidget {
  final GlobalKey _scaffoldKey = new GlobalKey();

  String result = "Scan a Qr Code to begin";

  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setPreferredOrientations([
      //DeviceOrientation.portraitUp,
    //]);

    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.0,
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
                    // ListTile(
                    //   leading: Icon(Icons.settings),
                    //   title: new Text("Settings"),
                    //   onTap: () {
                    //     Navigator.of(context).pop();
                    //   },
                    // ),
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
                        Navigator.of(context).pushNamed('/History');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.note),
                      title: Text("Notes"),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/Notes');
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
            backgroundColor: Color(0xFF1c6b92),
            title: Text('Full Shop - Coolant Overview',
                style: TextStyle(
                  color: Color(0xffFFFFFF),
                ))),
        bottomNavigationBar: BottomAppBar(
          elevation: 10.0,
          color: Color(0xFF1c6b92),
          child: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.grid_on),
                  color: Colors.white,
                  onPressed: () async =>
                      Navigator.pushNamed(context, "/Overview")),
              IconButton(
                  icon: Icon(Icons.message),
                  color: Colors.white,
                  onPressed: () async =>
                      Navigator.pushNamed(context, "/Notes")),
              IconButton(
                  icon: Icon(Icons.create),
                  color: Colors.white,
                  onPressed: () async =>
                      Navigator.pushNamed(context, "/Addmachines")),
              IconButton(
                  icon: Icon(Icons.timeline),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryPage(),
                      ),
                    );
                  }),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          notchMargin: 5.0,
          shape: CircularNotchedRectangle(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          elevation: 5.0,
          backgroundColor: Color(0xFF1c6b92),
          onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 170,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Enter Coolant Concentration',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: FlatButton.icon(
                              color: Colors.blue,
                              icon: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QRViewExample(),
                                  ),
                                );
                              },
                              label: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 8),
                                child: Text(
                                  'Scan QR Code',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ).padding(),
                );
              }),
          child: Icon(
            Icons.camera_alt,
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LatestEntriesPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
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
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            //dense: true,
                            title: Text(
                              "Latest Entries",
                              style: TextStyle(
                                  color: Color(0xFF3c6172),
                                  fontSize: 20.0,
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
                                  itemCount: snapshot.data.documents.length ==
                                              1 ||
                                          snapshot.data.documents.length == 0
                                      ? snapshot.data.documents.length
                                      : 2,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot machines =
                                        snapshot.data.documents[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        machines['name'] != null
                                            ? '${machines['name']}:  ${machines['coolant-percent']}%  (${machines['last-updated'].substring(5, 7) + "/" + machines['last-updated'].substring(8, 10) + "/" + machines['last-updated'].substring(2, 4)})'
                                            : "No machines yet",
                                      ),
                                      //subtitle: Text('Date:  ${machines['last-updated'].substring(5,10)}'),
                                      leading: Icon(Icons.assessment),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DilutedPage(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            //dense: true,
                            title: Text(
                              'Diluted',
                              style: TextStyle(
                                  color: Color(0xFF3c6172),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                                "Machines with the lowest coolant concentration"),
                          ),
                          StreamBuilder(
                            stream: Firestore.instance
                                .collection(box.get('companyId'))
                                .orderBy('coolant-percent', descending: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              assert(snapshot != null);
                              if (!snapshot.hasData) {
                                return Text('Please Wait');
                              } else {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.documents.length ==
                                              1 ||
                                          snapshot.data.documents.length == 0
                                      ? snapshot.data.documents.length
                                      : 2,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot machines =
                                        snapshot.data.documents[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(machines['name'] != null
                                          ? machines['name'] +
                                              " (" +
                                              "${machines['c-min']}" +
                                              "%-" +
                                              "${machines['c-max']}" +
                                              "%)"
                                          : "No Data"),
                                      leading: Icon(Icons.trending_down),
                                      trailing: Text(
                                          "${double.parse(machines['coolant-percent'])}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: double.parse(machines[
                                                              'coolant-percent']) <
                                                          double.parse(machines[
                                                              'c-max']) &&
                                                      double.parse(machines[
                                                              'coolant-percent']) >
                                                          double.parse(
                                                              machines['c-min'])
                                                  ? Colors.greenAccent[700]
                                                  : Colors.red)),
                                    );
                                  },
                                ); //subtitle: Text('Date:  ${machines['last-updated'].substring(5,10)}'),
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StrongPage(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            //dense: true,
                            title: Text(
                              'Strong',
                              style: TextStyle(
                                  color: Color(0xFF3c6172),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                                "Machines with the highest coolant concentration"),
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
                                  itemCount: snapshot.data.documents.length ==
                                              1 ||
                                          snapshot.data.documents.length == 0
                                      ? snapshot.data.documents.length
                                      : 2,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot machines =
                                        snapshot.data.documents[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(machines['name'] != null
                                          ? machines['name'] +
                                              " (" +
                                              "${machines['c-min']}" +
                                              "%-" +
                                              "${machines['c-max']}" +
                                              "%)"
                                          : "No Data"),
                                      leading: Icon(Icons.trending_up),
                                      trailing: Text(
                                          machines['coolant-percent'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: double.parse(machines[
                                                              'coolant-percent']) <
                                                          double.parse(machines[
                                                              'c-max']) &&
                                                      double.parse(machines[
                                                              'coolant-percent']) >
                                                          double.parse(
                                                              machines['c-min'])
                                                  ? Colors.greenAccent[700]
                                                  : Colors.red)),
                                    );
                                  },
                                ); //subtitle: Text('Date:  ${machines['last-updated'].substring(5,10)}'),
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ))));
  }
}

extension WidgetModifier on Widget {
  Widget padding([EdgeInsetsGeometry value = const EdgeInsets.all(15)]) {
    return Padding(
      padding: value,
      child: this,
    );
  }
}
