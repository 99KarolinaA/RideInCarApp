import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:icar/functions.dart';
import 'package:icar/view/home/homepage.dart';

import '../utils/others_helper.dart';

class GoogleSignInService with ChangeNotifier {
  bool isloading = false;

  setLoadingTrue() {
    isloading = true;
    notifyListeners();
  }

  setLoadingFalse() {
    isloading = false;
    notifyListeners();
  }

  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount _user;
  GoogleSignInAccount get user => _user;

  Future googleLogin(BuildContext context) async {
    final googleUser = await googleSignIn.signIn();

    print(googleUser);
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);

    // try to login with the info

    if (_user != null) {
      print(_user.displayName);
      print(_user.id);

      carMethods carObject = GetIt.instance.get<carMethods>();

      final currentAuthUser = FirebaseAuth.instance.currentUser;

      carObject.saveUserData(currentAuthUser.email, currentAuthUser.displayName,
          currentAuthUser.phoneNumber, currentAuthUser.photoURL);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } else {
      OthersHelper().showToast(
          'Didnt get any user info after google sign in. visit google sign in service file',
          Colors.black);
    }
    notifyListeners();
  }

//Logout from google ====>
  logOutFromGoogleLogin() {
    googleSignIn.signOut();
  }
}
