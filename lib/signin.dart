import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: new Material(
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: new Container(
                        height: 500.0,
                        width: 500.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          // the box shawdow property allows for fine tuning as aposed to shadowColor
                          boxShadow: [
                            new BoxShadow(
                                color: Colors.blue,
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
                              padding: const EdgeInsets.all(30.0),
                              child: Image.asset('assets/168.png'),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black)),
                              width: 300,
                              child: TextField(
                                style: TextStyle(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black)),
                                width: 300,
                                child: TextField(
                                  style: TextStyle(),
                                ),
                              ),
                            ),
                            MaterialButton(
                              child: Text(
                                "Sign In",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.lightBlue,
                              onPressed: () =>
                                  Navigator.pushNamed(context, "/HomePage"),
                            ),
                            MaterialButton(
                                child: Text(
                                  "Register",
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                                color: Colors.lightBlue[50],
                                onPressed: () =>
                                    Navigator.pushNamed(context, "/HomePage")),
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
