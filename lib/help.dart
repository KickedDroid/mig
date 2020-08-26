import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mig/batch.dart';
import 'package:mig/signin.dart';
import 'package:toast/toast.dart';
import 'extensions.dart';
import 'main.dart';

class HelpPage extends StatefulWidget {
  HelpPage({Key key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String companyId;

  String emailData;

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController company = TextEditingController();
  String passData;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> signUp(email, password) async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
          email: email, password: password)) as FirebaseUser;
      assert(user != null);
      assert(await user.getIdToken() != null);
      return user;
    } catch (e) {
      handleError(e);
      return null;
    }
  }

  void handleError(e) {
    Toast.show(e.toString(), context, duration: Toast.LENGTH_LONG);
  }

  getInputData() {
    setState(() {
      companyId = company.text;
      emailData = email.text;
      passData = pass.text;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 0.5, 0.7, 0.9],
                colors: [
                  Colors.white,
                  Colors.blue[50],
                  Colors.lightBlue[100],
                  Colors.lightBlue[200],
                ],
              ),

              color: Colors.white,

              borderRadius: BorderRadius.circular(00.0),

              // the box shawdow property allows for fine tuning as aposed to shadowColor
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60.0, 20.0, 60.0, 20.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height * .15,
                        child: Image.asset('assets/logosb.png')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Need Some Help?',
                      style: TextStyle(
                          fontSize: 26.0, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                    child: Text(
                      'If your company already has a FullShop account and you know the Company ID, just enter an email address, create a password, and click "Create User Account"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.blueGrey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                    child: Text(
                      'If your company doesn\'t already have a FullShop account, an account can be created by clicking on the "Create Company Account" link on the signup page',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.blueGrey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                    child: Text(
                      'If you and your company already have an account, simply enter your email address, password, and the Company ID to login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
