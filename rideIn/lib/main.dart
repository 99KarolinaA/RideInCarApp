import 'package:flutter/material.dart';
import 'package:icar/serviceLocator.dart';
import 'package:icar/services/forum_service.dart';
import 'package:icar/services/google_sign_service.dart';
import 'package:icar/services/homepage_service.dart';
import 'package:icar/startPage.dart';
import 'package:provider/provider.dart';

void main() {
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ForumService()),
        ChangeNotifierProvider(create: (_) => GoogleSignInService()),
        ChangeNotifierProvider(create: (_) => HomepageService()),
      ],
      child: MaterialApp(
        title: 'Ride In',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StartPage(),
      ),
    );
  }
}
