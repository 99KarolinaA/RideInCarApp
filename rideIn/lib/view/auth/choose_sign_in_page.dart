import 'package:flutter/material.dart';
import 'package:icar/authentication/appAuthentication.dart';
import 'package:icar/services/google_sign_service.dart';
import 'package:provider/provider.dart';

class ChooseSignInPage extends StatelessWidget {
  const ChooseSignInPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Login with email
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppAuthentication()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.center,
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      'Login or register with email',
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            //Sign in with google
            Consumer<GoogleSignInService>(
              builder: (context, gProvider, child) => InkWell(
                onTap: () {
                  gProvider.googleLogin(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6)),
                  alignment: Alignment.center,
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.g_mobiledata_outlined,
                        size: 40,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        'Login or register with google',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
