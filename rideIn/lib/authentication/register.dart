import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:icar/functions.dart';
import 'package:icar/services/forum_service.dart';
import 'package:icar/startPage.dart';
import 'package:icar/utils/others_helper.dart';
import 'package:provider/provider.dart';
import '../Dialogs/errorDialog.dart';
import '../customWidgets/customTextField.dart';

import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  final TextEditingController phoneConfirmController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  carMethods carObject = GetIt.instance.get<carMethods>();

  String errorText;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return new SingleChildScrollView(
        child: Consumer<ForumService>(
      builder: (context, fProvider, child) => Container(
          child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: _height * 0.1,
                      child: CustomTextField(
                        iconData: Icons.person,
                        textEditingController: nameController,
                        hint: 'Name',
                        isObscure: false,
                        errorText: errorText,
                        errorContentPaddingTop: 23,
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            errorText = ' '; // that means we have error
                            setState(() {});
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      height: _height * 0.1,
                      child: CustomTextField(
                        iconData: Icons.phone_android_rounded,
                        textEditingController: phoneConfirmController,
                        hint: 'Phone',
                        isObscure: false,
                        errorText: errorText,
                        errorContentPaddingTop: 23,
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            errorText = ' '; // that means we have error
                            setState(() {});
                            return 'Please enter your phone';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      height: _height * 0.1,
                      child: CustomTextField(
                        iconData: Icons.email,
                        textEditingController: emailController,
                        hint: 'Email',
                        isObscure: false,
                        errorText: errorText,
                        errorContentPaddingTop: 23,
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            errorText = ' '; // that means we have error
                            setState(() {});
                            return 'Please enter your email';
                          } else if (!value.contains('@')) {
                            errorText = ' '; // that means we have error
                            setState(() {});
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      height: _height * 0.1,
                      child: CustomTextField(
                        iconData: Icons.lock,
                        textEditingController: passwordController,
                        hint: 'Password',
                        isObscure: true,
                        errorText: errorText,
                        errorContentPaddingTop: 23,
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            errorText = ' '; // that means we have error
                            setState(() {});
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      height: _height * 0.1,
                      child: CustomTextField(
                        iconData: Icons.lock,
                        textEditingController: passwordConfirmController,
                        hint: ''
                            'Confirm passsword',
                        isObscure: true,
                        errorText: errorText,
                        errorContentPaddingTop: 23,
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            errorText = ' '; // that means we have error
                            setState(() {});
                            return 'Please enter password again';
                          } else if (passwordController.text !=
                              passwordConfirmController.text) {
                            errorText = ' '; // that means we have error
                            setState(() {});
                            return 'Password did not match';
                          }
                          return null;
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),

              //pick image
              Column(
                children: [
                  //show picked image
                  fProvider.pickedImage != null
                      ? Container(
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Image.file(
                            File(fProvider.pickedImage.path),
                            height: 85,
                            width: 85,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 25),
                        child: ElevatedButton(
                            onPressed: () {
                              fProvider.pickImage();
                            },
                            child: Container(
                              padding: new EdgeInsets.all(15.0),
                              child: Text(
                                'Choose image',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ),

                      SizedBox(
                        width: 10,
                      ),
                      //choose from camera
                      Container(
                        margin: EdgeInsets.only(right: 25),
                        child: ElevatedButton(
                            onPressed: () {
                              fProvider.pickImageFromCamera();
                            },
                            child: Container(
                              padding: new EdgeInsets.all(15.0),
                              child: Text(
                                'Take a photo',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        //make error text null
                        setState(() {
                          errorText = null;
                        });

                        if (fProvider.pickedImage == null) {
                          OthersHelper().showSnackBar(
                              context, 'Please choose an image', Colors.red);
                          return;
                        }

                        if (fProvider.isloading == false) {
                          var result = await fProvider.uploadImage();

                          if (result == true) {
                            _register(fProvider.downloadUrl);
                          } else {
                            OthersHelper().showSnackBar(
                                context, 'Error uploading image', Colors.red);
                          }
                        }
                      }
                    },
                    child: Container(
                      padding: new EdgeInsets.all(15.0),
                      child: fProvider.isloading == false
                          ? Text(
                              'Sign up',
                              style: TextStyle(color: Colors.white),
                            )
                          : OthersHelper().showLoading(Colors.white),
                    )),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ])),
    ));
  }

  void _register(imageUrl) async {
    User currentUser;

    await _auth
        .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user;

      carObject.saveUserData(currentUser.email, nameController.text.trim(),
          phoneConfirmController.text.trim(), imageUrl);
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (con) {
            return ErrorDialog(
              errorMessage: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      Route route = MaterialPageRoute(builder: (context) => StartPage());
      Navigator.pushReplacement(context, route);
    }
  }
}
