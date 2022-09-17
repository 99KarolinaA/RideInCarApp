import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:icar/functions.dart';
import 'package:icar/services/forum_service.dart';
import 'package:icar/utils/others_helper.dart';
import 'package:provider/provider.dart';

class ForumHelper {
  Future<bool> showDialogForAddForumPost(BuildContext context, userId) async {
    carMethods carObject = GetIt.instance.get<carMethods>();
    String title;
    String content;
    String category;

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Write something",
              style: TextStyle(
                  fontSize: 20, fontFamily: "Bebas", letterSpacing: 2.0),
            ),
            content: SingleChildScrollView(
                child: Consumer<ForumService>(
              builder: (context, provider, child) => Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: TextField(
                      decoration: InputDecoration(hintText: 'Title'),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                  ),
                  SizedBox(height: 4.0),
                  TextField(
                    decoration: InputDecoration(hintText: 'Post details'),
                    onChanged: (value) {
                      content = value;
                    },
                  ),
                  SizedBox(height: 4.0),
                  TextField(
                    decoration: InputDecoration(hintText: 'Category'),
                    onChanged: (value) {
                      category = value;
                    },
                  ),
                  SizedBox(height: 4.0),
                  ElevatedButton(
                    child: Text(
                      "Pick image",
                    ),
                    onPressed: () {
                      provider.pickImage();
                    },
                  ),

                  //show picked image
                  provider.pickedImage != null
                      ? Container(
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Image.file(
                            File(provider.pickedImage.path),
                            height: 85,
                            width: 85,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container()
                ],
              ),
            )),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: () {
                      Navigator.pop(context); //close the alert box
                    },
                  ),
                  Consumer<ForumService>(
                    builder: (context, provider, child) => ElevatedButton(
                      child: provider.isloading == false
                          ? Text(
                              "Upload",
                            )
                          : OthersHelper().showLoading(Colors.white),
                      onPressed: () async {
                        if (provider.pickedImage == null) {
                          OthersHelper().showToast(
                              'You must select an image', Colors.black);
                          return;
                        }

                        if (provider.isloading == true) return;

                        //upload image
                        var result = await provider.uploadImage();

                        if (result == true) {
                          Map<String, dynamic> postData = {
                            'postedBy': userId,
                            'title': title != null ? title : ' ',
                            'desc': content != null ? content : ' ',
                            'category': category != null ? category : ' ',
                            'imageUrl': provider.downloadUrl,
                            'time': DateTime.now(),
                          };
                          carObject.addForumData(postData).then((value) {
                            print("Data added successfully.");

                            Navigator.pop(context);
                          }).catchError((onError) {
                            print(onError);
                          });
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
