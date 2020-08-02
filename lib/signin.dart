import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

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

  Future<FirebaseUser> signIn(String email, String password) async {
    try {
      FirebaseUser user = (await _auth.signInWithEmailAndPassword(
          email: email, password: password)) as FirebaseUser;
      assert(user != null);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      return user;
    } catch (e) {
      handleError(e);
      return null;
    }
  }

  TextEditingController email;

  TextEditingController pass;

  TextEditingController company;

  String passData;
  String emailData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: ListView(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: new Container(
                      height: 700.0,
                      width: 500.0,
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
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                110.0, 30.0, 110.0, 30.0),
                            child: Image.asset('assets/logosb.png'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey)),
                            width: 300,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  emailData = value;
                                });
                              },
                              controller: email,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'SFUIDisplay'),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person_outline),
                                  labelStyle: TextStyle(fontSize: 15)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.grey)),
                              width: 300,
                              child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      passData = value;
                                    });
                                  },
                                  controller: pass,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'SFUIDisplay'),
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Password',
                                      prefixIcon: Icon(Icons.lock_outline),
                                      labelStyle: TextStyle(fontSize: 15))),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              signIn(emailData, passData);
                              var box = Hive.box('myBox');
                              box.put('companyId', company.toString());
                            },
                            onLongPress: () => {},
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 40.0, 20.0, 10.0),
                              child: Container(
                                  height: 60,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(colors: [
                                        Colors.blueAccent[700],
                                        Colors.blue
                                      ])),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              signUp(emailData, passData);
                              var box = Hive.box('myBox');
                              box.put('companyId', company.text);
                            },
                            onLongPress: () => {},
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                  height: 60,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(colors: [
                                        Colors.orangeAccent,
                                        Colors.orange
                                      ])),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Create an account',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              signInWithGoogle();
                              var box = Hive.box('myBox');
                              box.put('companyId', company.text);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text("Sign in with Google"),
                            ),
                          )
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleError(e) {
    print(e);
  }
}
