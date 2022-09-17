import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:icar/authentication/appAuthentication.dart';
import 'package:icar/view/auth/choose_sign_in_page.dart';
import './customWidgets/gradientText.dart';
import 'package:icar/view/home/homepage.dart';
import 'dart:io' show Platform;

class StartPage extends StatefulWidget {
  const StartPage({key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  startTimer() {
    Timer(Duration(seconds: 3), () async {
      await Firebase.initializeApp();
      if (FirebaseAuth.instance.currentUser != null) {
        Route route = MaterialPageRoute(builder: (context) => Homepage());
        Navigator.pushReplacement(context, route);
      } else {
        Route route =
            MaterialPageRoute(builder: (context) => ChooseSignInPage());
        Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  //todo: below
  @override
  Widget build(BuildContext context) {
/*    double fonttmp = 60.0;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        fonttmp = 20.0;
      } else {
        fonttmp = 60.0;
      }
    } catch (e) {
      fonttmp = 60.0;
    }*/
    return new Stack(
      children: <Widget>[
        Positioned.fill(
          //
          child: Image(
            image: AssetImage('images/background_lights.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        Container(
            padding: new EdgeInsets.only(top: 100.0),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GradientText(
                  'Ride in and enjoy',
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontFamily: "Lobster",
                  ),
                  gradient: LinearGradient(colors: [
                    Colors.cyanAccent,
                    Colors.cyan,
                    Colors.indigo,
                    Colors.deepPurple
                  ]),
                ),
              ],
            )))
      ],
    );
  }
}
