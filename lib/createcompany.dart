import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mig/batch.dart';
import 'package:mig/signin.dart';
import 'package:toast/toast.dart';
import 'extensions.dart';
import 'main.dart';

class CreateCompanyPage extends StatefulWidget {
  CreateCompanyPage({Key key}) : super(key: key);

  @override
  _CreateCompanyPageState createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
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
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      'Create Your Company',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(),
                    height: MediaQuery.of(context).size.height * .07,
                    width: 300,
                    child: TextFormField(
                      controller: email,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFUIDisplay',
                          fontSize: 15),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.person_outline),
                          labelStyle: TextStyle(fontSize: 15)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(),
                      height: MediaQuery.of(context).size.height * .07,
                      width: 300,
                      child: TextFormField(
                          controller: pass,
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'SFUIDisplay'),
                          obscureText: true,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              labelStyle: TextStyle(fontSize: 15))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      decoration: BoxDecoration(),
                      height: MediaQuery.of(context).size.height * .07,
                      width: 300,
                      child: TextFormField(
                          controller: company,
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'SFUIDisplay'),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              labelText: 'CompanyID',
                              prefixIcon: Icon(Icons.edit),
                              labelStyle: TextStyle(fontSize: 15))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        getInputData();

                        signUp(emailData, passData);

                        var box = Hive.box('myBox');

                        box.put('companyId', companyId);
                        box.put('userId', emailData);

                        //createCompany(companyId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BatchAddPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * .07,
                          width: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                  colors: [Colors.blue[700], Colors.blue])),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Company',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
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

createCompany(String companyId) async {
  var box = Hive.box('myBox');
  var time = new DateTime.now();
  box.put('isEmpty', true);
  box.put('admin', true);
  await Firestore.instance
      .collection(box.get('companyId'))
      .document("Mori")
      .setData({
    "name": "Mori",
    "coolant-percent": "0.0",
    "last-updated": "$time",
    "last-cleaned": "$time",
    "notes": {"note": "No Notes", "time": "$time"},
    "c-min": "2",
    "c-max": "12"
  });
  await Firestore.instance
      .collection(box.get('companyId'))
      .document("Mori 2")
      .setData({
    "name": "Mori 2",
    "coolant-percent": "0.0",
    "last-updated": "$time",
    "last-cleaned": "$time",
    "notes": {"note": "No Notes", "time": "$time"},
    "c-min": "2",
    "c-max": "12"
  });
}
