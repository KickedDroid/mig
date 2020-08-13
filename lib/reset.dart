import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'extensions.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({Key key}) : super(key: key);

  @override
  _ResetPassPageState createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  @override
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  final TextEditingController controller = TextEditingController();

  String email;

  getTextInputData() {
    setState(() {
      email = controller.text;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            getTextInputData();
            resetPassword(email);
          }),
      body: SafeArea(
        child: Column(
          children: [
            Text('Reset PassWord'),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 15),
              ),
            ).padding(),
          ],
        ),
      ),
    );
  }
}
