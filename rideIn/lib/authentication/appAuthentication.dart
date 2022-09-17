import 'package:flutter/material.dart';
import 'register.dart';

import 'login.dart';

class AppAuthentication extends StatefulWidget {
  const AppAuthentication({Key key}) : super(key: key);

  @override
  _AppAuthenticationState createState() => _AppAuthenticationState();
}

class _AppAuthenticationState extends State<AppAuthentication> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [Colors.cyanAccent, Colors.cyan, Colors.indigo, Colors.deepPurple],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 0.2,0.7, 1.0],
                    tileMode: TileMode.clamp)),
          ),
          title: Text(
            'RideIn',
            style: TextStyle(
                fontSize: 60.0, color: Colors.white, fontFamily: "Lobster"),
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.lock, color: Colors.white), text: "Login"),
              Tab(
                  icon: Icon(Icons.person, color: Colors.white),
                  text: "Register")
            ],
            indicatorColor: Colors.white38,
            indicatorWeight: 5.0,
          ),
        ),
        body: Container(

            child: Stack(children: <Widget>[
              Positioned.fill(  //
                child: Image(
                  image: AssetImage('images/background_lights.jpg'),
                  fit : BoxFit.fill,
                ),
              ),
              TabBarView(children: <Widget>[
                Login(),
                Register(),
              ]),
            ])),
      ),
    );
  }
}
