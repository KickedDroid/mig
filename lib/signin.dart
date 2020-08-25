import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:mig/reset.dart';
import 'createcompany.dart';
import 'extensions.dart';
import 'package:toast/toast.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
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

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  TextEditingController email;

  TextEditingController pass;

  TextEditingController company;

  String passData;
  String emailData;

  String companyId;
  bool _showPassword = true;

  showToast() {
    Toast.show("Enter Valid Email", context, duration: Toast.LENGTH_LONG);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            new Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
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
                    padding:
                        const EdgeInsets.fromLTRB(60.0, 10.0, 60.0, 20.0),
                    child: Container(
                        height: MediaQuery.of(context).size.height * .2,
                        child: Image.asset('assets/logosb.png')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * .07,
                      decoration: BoxDecoration(),
                      width: 300,
                      child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              emailData = value;
                            });
                          },
                          controller: email,
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'SFUIDisplay', fontSize: 15),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.person_outline),
                              labelStyle: TextStyle(fontSize: 15))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(
                          ),
                      height: MediaQuery.of(context).size.height * .07,
                      width: 300,
                      child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              passData = value;
                            });
                          },
                          controller: pass,
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'SFUIDisplay', fontSize: 15),
                          obscureText: !this._showPassword,
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
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(
                          ),
                      height: MediaQuery.of(context).size.height * .07,
                      width: 300,
                      child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              companyId = value;
                            });
                          },
                          controller: pass,
                          style: TextStyle(
                              color: Colors.black, fontFamily: 'SFUIDisplay', fontSize: 15),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              labelText: 'CompanyID',
                              prefixIcon: Icon(Icons.edit),
                              labelStyle: TextStyle(fontSize: 15))),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (emailData.contains("@")) {
                        signIn(emailData, passData);
                        var box = Hive.box('myBox');
                        box.put('userId', emailData);
                        box.put('companyId', companyId);
                      } else {
                        showToast();
                      }
                    },
                    onLongPress: () => {},
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      child: Container(
                          height: MediaQuery.of(context).size.height * .07,
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
                      if (company != null) {
                        signUp(emailData, passData);
                        var box = Hive.box('myBox');
                        box.put('companyId', companyId);
                        box.put('admin', false);
                      } else {
                        showToast();
                      }
                    },
                    onLongPress: () => {},
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                          height: MediaQuery.of(context).size.height * .07,
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
                  // GestureDetector(
                  //   onTap: () {
                  //     if (companyId != null) {
                  //       signInWithGoogle();
                  //       var box = Hive.box('myBox');
                  //       box.put('companyId', companyId);
                  //     } else {
                  //       Toast.show("Enter a Company ID", context,
                  //           duration: 4);
                  //     }
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(12.0),
                  //     child: Text("Sign in with Google"),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () {
                      resetPassword(emailData);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Forgot Password"),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateCompanyPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Create Company"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleError(e) {
    Toast.show(e.toString(), context, duration: Toast.LENGTH_LONG);
  }
}
