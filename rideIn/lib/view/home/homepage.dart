import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icar/profilePage.dart';
import 'package:icar/searchCar.dart';
import 'package:icar/services/forum_service.dart';
import 'package:icar/services/google_sign_service.dart';
import 'package:icar/services/homepage_service.dart';
import 'package:icar/utils/config.dart';
import 'package:icar/utils/others_helper.dart';
import 'package:icar/view/auth/choose_sign_in_page.dart';
import 'package:icar/view/fav/favourites_page.dart';
import 'package:icar/view/forum/forum_posts_page.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'dart:io' show File, Platform;
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

import '../../functions.dart';
import '../../globalVariables.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String userName;
  String userNumber;
  String carPrice;
  String carModel;
  String carColor;
  String description;

  QuerySnapshot cars;

  final currentLocationController = TextEditingController();

  carMethods carObject = GetIt.instance.get<carMethods>();

  final _currentUserReference = FirebaseFirestore.instance.collection('users');

//Add  Dialogue
  Future<bool> showDialogForAddingData() async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Post a new ad",
              style: TextStyle(
                  fontSize: 20, fontFamily: "Bebas", letterSpacing: 2.0),
            ),
            content: SingleChildScrollView(
                child: Consumer<ForumService>(
              builder: (context, fProvider, child) => Form(
                key: _formKey,
                child: Consumer<HomepageService>(
                  builder: (context, hProvider, child) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: TextFormField(
                          decoration:
                              InputDecoration(hintText: 'Enter your name'),
                          onChanged: (value) {
                            this.userName = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 4.0),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Enter your phone number'),
                        onChanged: (value) {
                          this.userNumber = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.0),
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: 'Enter car price'),
                        onChanged: (value) {
                          this.carPrice = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.0),
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: 'Enter car Model'),
                        onChanged: (value) {
                          this.carModel = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car model';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.0),
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: 'Enter car color'),
                        onChanged: (value) {
                          this.carColor = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car color';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.0),
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: 'Enter car location'),
                        controller: currentLocationController,
                        onChanged: (value) {
                          hProvider.setCurrentLocation(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car location';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.0),
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: 'Enter car description'),
                        onChanged: (value) {
                          this.description = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car description';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 4.0),

                      //show picked image
                      fProvider.pickedImage != null
                          ? Container(
                              margin: EdgeInsets.only(top: 10, bottom: 20),
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

                      ElevatedButton(
                        child: Text(
                          "Pick image",
                        ),
                        onPressed: () {
                          fProvider.pickImage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )),
            actions: [
              Consumer<HomepageService>(
                builder: (context, hProvider, child) => ElevatedButton(
                    onPressed: () async {
                      Position position = await hProvider.determinePosition();
                      hProvider.GetAddressFromLatLong(
                          position, currentLocationController);
                    },
                    child: Text('Current location')),
              ),
              ElevatedButton(
                child: Text(
                  "Cancel",
                ),
                onPressed: () {
                  Navigator.pop(context); //close the alert box
                },
              ),
              Consumer<ForumService>(
                builder: (context, fProvider, child) =>
                    Consumer<HomepageService>(
                  builder: (context, hProvider, child) => ElevatedButton(
                    child: fProvider.isloading == false
                        ? Text(
                            "Add",
                          )
                        : OthersHelper().showLoading(Colors.white),
                    onPressed: () async {
                      if (fProvider.pickedImage == null) {
                        OthersHelper().showToast(
                            'You must select an image', Colors.black);
                        return;
                      }

                      if (fProvider.isloading == true) return;

                      if (_formKey.currentState.validate()) {
                        //upload image
                        var result = await fProvider.uploadImage();

                        if (result == true) {
                          Map<String, dynamic> carData = {
                            'userName':
                                this.userName != null ? this.userName : ' ',
                            'uId': userId,
                            'userNumber':
                                this.userNumber != null ? this.userNumber : ' ',
                            'carPrice': this.carPrice != null
                                ? int.parse(this.carPrice)
                                : 0,
                            'carModel':
                                this.carModel != null ? this.carModel : ' ',
                            'carModelInLowerCase': this.carModel != null
                                ? this.carModel.toLowerCase()
                                : ' ',
                            'carColor':
                                this.carColor != null ? this.carColor : ' ',
                            'carColorInLowerCase': this.carColor != null
                                ? this.carColor.toLowerCase()
                                : ' ',
                            'carLocation': hProvider.currentLocation != null
                                ? hProvider.currentLocation
                                : ' ',
                            'description': this.description != null
                                ? this.description
                                : ' ',
                            'urlImage': fProvider.downloadUrl,
                            'imgPro': userImageUrl,
                            'time': DateTime.now(),
                          };
                          carObject.addData(carData).then((value) {
                            print("Data added successfully.");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Homepage()));
                          }).catchError((onError) {
                            print(onError);
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }

//Update Dialogue
  Future<bool> showDialogForUpdateData(
      selectedDoc,
      String initialName,
      String initialPhone,
      String initialPrice,
      String initialModel,
      String initialColor,
      String initialLocation,
      String initialDesc) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Provider.of<ForumService>(context, listen: false).setDefault();

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Update the ad",
              style: TextStyle(
                  fontSize: 24, fontFamily: "Bebas", letterSpacing: 2.0),
            ),
            content: SingleChildScrollView(child: Consumer<ForumService>(
              builder: (context, fProvider, child) {
                //set initial location
                currentLocationController.text = initialLocation;
                return Form(
                  key: _formKey,
                  child: Consumer<HomepageService>(
                    builder: (context, hProvider, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(hintText: 'Enter your name'),
                              initialValue: initialName,
                              onChanged: (value) {
                                this.userName = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            decoration: InputDecoration(
                                hintText: 'Enter your phone number'),
                            initialValue: initialPhone,
                            onChanged: (value) {
                              this.userNumber = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            decoration:
                                InputDecoration(hintText: 'Enter car price'),
                            initialValue: initialPrice,
                            onChanged: (value) {
                              this.carPrice = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter car price';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            decoration:
                                InputDecoration(hintText: 'Enter car Model'),
                            initialValue: initialModel,
                            onChanged: (value) {
                              this.carModel = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter car model';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            decoration:
                                InputDecoration(hintText: 'Enter car color'),
                            initialValue: initialColor,
                            onChanged: (value) {
                              this.carColor = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter car color';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            decoration:
                                InputDecoration(hintText: 'Enter car location'),
                            controller: currentLocationController,
                            onChanged: (value) {
                              hProvider.setCurrentLocation(value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter car location';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4.0),
                          TextFormField(
                            decoration: InputDecoration(
                                hintText: 'Enter car description'),
                            initialValue: initialDesc,
                            onChanged: (value) {
                              this.description = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter car description';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 4.0),
                          //show picked image
                          fProvider.pickedImage != null
                              ? Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 20),
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

                          //pick image button
                          ElevatedButton(
                            child: Text(
                              "Pick image",
                            ),
                            onPressed: () {
                              fProvider.pickImage();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            )),
            actions: [
              Row(
                children: [
                  Consumer<HomepageService>(
                    builder: (context, hProvider, child) => ElevatedButton(
                        onPressed: () async {
                          Position position =
                              await hProvider.determinePosition();
                          hProvider.GetAddressFromLatLong(
                              position, currentLocationController);
                        },
                        child: Text(
                          'Current location',
                          style: TextStyle(fontSize: 11),
                        )),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  ElevatedButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 11),
                    ),
                    onPressed: () {
                      Navigator.pop(context); //close the alert box
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Consumer<ForumService>(
                    builder: (context, fProvider, child) =>
                        Consumer<HomepageService>(
                      builder: (context, hProvider, child) => ElevatedButton(
                        child: fProvider.isloading == false
                            ? Text(
                                "Update",
                                style: TextStyle(fontSize: 11),
                              )
                            : OthersHelper().showLoading(Colors.white),
                        onPressed: () async {
                          if (fProvider.pickedImage == null) {
                            OthersHelper().showToast(
                                'You must select an image', Colors.black);
                            return;
                          }

                          if (fProvider.isloading == true) return;

                          if (_formKey.currentState.validate()) {
                            //upload image
                            var result = await fProvider.uploadImage();

                            if (result == true) {
                              Map<String, dynamic> carData = {
                                'userName':
                                    this.userName != null ? this.userName : ' ',
                                'userNumber': this.userNumber != null
                                    ? this.userNumber
                                    : ' ',
                                'carPrice': this.carPrice != null
                                    ? int.parse(this.carPrice)
                                    : 0,
                                'carModel':
                                    this.carModel != null ? this.carModel : ' ',
                                'carModelInLowerCase': this.carModel != null
                                    ? this.carModel.toLowerCase()
                                    : ' ',
                                'carColor':
                                    this.carColor != null ? this.carColor : ' ',
                                'carColorInLowerCase': this.carColor != null
                                    ? this.carColor.toLowerCase()
                                    : ' ',
                                'carLocation': hProvider.currentLocation != null
                                    ? hProvider.currentLocation
                                    : ' ',
                                'description': this.description != null
                                    ? this.description
                                    : ' ',
                                'urlImage': fProvider.downloadUrl,
                                'time': DateTime.now(),
                              };
                              carObject
                                  .updateData(selectedDoc, carData)
                                  .then((value) {
                                print("Data updated successfully.");

                                Navigator.pop(context); //close the alert box

                                Route route = MaterialPageRoute(
                                    builder: (BuildContext c) => Homepage());
                                Navigator.push(context, route);
                              }).catchError((onError) {
                                print(onError);
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  } // update dialogue end

  //filter dialogue
  Future<bool> showDialogForFilter(BuildContext context) async {
    String color;
    String minPrice;
    String maxPrice;
    String model;

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Filter",
              style: TextStyle(
                  fontSize: 24, fontFamily: "Bebas", letterSpacing: 2.0),
            ),
            content: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'Car color'),
                  onChanged: (value) {
                    color = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Minimum price'),
                  onChanged: (value) {
                    minPrice = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Maximum price'),
                  onChanged: (value) {
                    maxPrice = value;
                  },
                ),
                SizedBox(height: 5.0),
                TextField(
                  decoration: InputDecoration(hintText: 'Car model'),
                  onChanged: (value) {
                    model = value;
                  },
                ),
                SizedBox(height: 5.0),
              ],
            )),
            actions: [
              ElevatedButton(
                child: Text(
                  "Cancel",
                ),
                onPressed: () {
                  Navigator.pop(context); //close the alert box
                },
              ),
              ElevatedButton(
                child: Text(
                  "Apply filter",
                ),
                onPressed: () {
                  Navigator.pop(context); //close the alert box

                  carObject
                      .getDataByFilter(
                          color != null ? color.toLowerCase() : color,
                          minPrice != null ? int.parse(minPrice) : minPrice,
                          maxPrice != null ? int.parse(maxPrice) : maxPrice,
                          model != null ? model.toLowerCase() : model)
                      .then((value) {
                    setState(() {
                      cars = value;
                    });
                  }).catchError((onError) {
                    print(onError);
                  });
                },
              ),
            ],
          );
        });
  } // filter dialogue end

  getMyData() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((results) {
      setState(() {
        userImageUrl = results.data()['imgPro'];
        getUserName = results.data()['userName'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
    userEmail = FirebaseAuth.instance.currentUser.email;

    carObject.getData().then((results) {
      setState(() {
        cars = results;
      });
    });

    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool centertitle = true;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        width = width;
      } else {
        width = width * 0.5;
      }
    } catch (e) {
      width = width;
    }
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        centertitle = false;
      } else {
        centertitle = true;
      }
    } catch (e) {
      centertitle = true;
    }

    Widget showCarsList() {
      if (cars != null) {
        return ListView.builder(
          itemCount: cars.docs.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(8.0),
          itemBuilder: (context, i) {
            return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Route route = MaterialPageRoute(
                            builder: (_) => ProfilePage(
                                  sellerId: cars.docs[i].data()['uId'],
                                ));
                        Navigator.push(context, route);
                      },
                      child: ListTile(
                          //profile image
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                    cars.docs[i].data()['imgPro'],
                                  ),
                                  fit: BoxFit.fill),
                            ),
                          ),

                          //username
                          title: Text(cars.docs[i].data()['userName']),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  cars.docs[i].data()['carLocation'],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //edit post icon
                              cars.docs[i].data()['uId'] == userId
                                  ? GestureDetector(
                                      onTap: () {
                                        if (cars.docs[i].data()['uId'] ==
                                            userId) {
                                          showDialogForUpdateData(
                                            cars.docs[i].id,
                                            cars.docs[i].data()['userName'],
                                            cars.docs[i].data()['userNumber'],
                                            cars.docs[i]
                                                .data()['carPrice']
                                                .toString(),
                                            cars.docs[i].data()['carModel'],
                                            cars.docs[i].data()['carColor'],
                                            cars.docs[i].data()['carLocation'],
                                            cars.docs[i].data()['description'],
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.edit_outlined,
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                width: 20,
                              ),

                              //delete post icon
                              cars.docs[i].data()['uId'] == userId
                                  ? GestureDetector(
                                      onDoubleTap: () {
                                        if (cars.docs[i].data()['uId'] ==
                                            userId) {
                                          carObject.deleteData(cars.docs[i].id);
                                          Route route = MaterialPageRoute(
                                              builder: (BuildContext c) =>
                                                  Homepage());
                                          Navigator.push(context, route);
                                        }
                                      },
                                      child: Icon(Icons.delete_forever_sharp))
                                  : Container(),

                              //Favourite post icon

                              FutureBuilder(
                                  future: carObject
                                      .checkIfAddedToFavourite(cars.docs[i].id),
                                  builder: (_, favSnap) {
                                    if (favSnap.hasData) {
                                      return GestureDetector(
                                          onTap: () async {
                                            await carObject
                                                .favouriteAd(cars.docs[i].id);
                                          },
                                          child: StreamBuilder(
                                              stream: _currentUserReference
                                                  .snapshots(),
                                              builder: (_,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  List currentUserFavList = [];

                                                  for (int i = 0;
                                                      i <
                                                          snapshot
                                                              .data.docs.length;
                                                      i++) {
                                                    if (snapshot.data.docs[i]
                                                            .data()['uId'] ==
                                                        userId) {
                                                      currentUserFavList =
                                                          snapshot.data.docs[i]
                                                                  .data()[
                                                              'favouritePosts'];
                                                    }
                                                  }

                                                  return Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 15,
                                                              vertical: 15),
                                                      child: Icon(
                                                        Icons.favorite,
                                                        color: currentUserFavList
                                                                .contains(cars
                                                                    .docs[i].id)
                                                            ? Colors.red
                                                            : Colors.grey,
                                                      ));
                                                } else {
                                                  return Container();
                                                }
                                              }));
                                    } else {
                                      return Container();
                                    }
                                  })
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CachedNetworkImage(
                        imageUrl: cars.docs[i].data()['urlImage'],
                        placeholder: (context, url) {
                          return Image.network(placeHolderUrl);
                        },
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        '\$ ' + cars.docs[i].data()['carPrice'].toString(),
                        style: TextStyle(
                          fontFamily: "Bebas",
                          letterSpacing: 2.0,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  child: Text(cars.docs[i].data()['carModel']),
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.watch_later_outlined),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  //child: Text(cars.docs[i].data()['time'].toString()),
                                  child: Text(tAgo.format(
                                      (cars.docs[i].data()['time']).toDate())),
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.brush_outlined),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  child: Text(cars.docs[i].data()['carColor']),
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.phone_android),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  //child: Text(cars.docs[i].data()['time'].toString()),
                                  child:
                                      Text(cars.docs[i].data()['userNumber']),
                                  alignment: Alignment.topRight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Text(
                        cars.docs[i].data()['description'],
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ));
          },
        );
      } else {
        return OthersHelper().showLoading(Colors.blue);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (_) => Homepage());
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Route route = MaterialPageRoute(
                    builder: (_) => ProfilePage(
                          sellerId: userId,
                        ));
                Navigator.pushReplacement(context, route);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.person, color: Colors.white),
              )),
          TextButton(
              onPressed: () {
                Route route = MaterialPageRoute(builder: (_) => SearchCar());
                Navigator.pushReplacement(context, route);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.search, color: Colors.white),
              )),

          //Log out // logout
          TextButton(
              onPressed: () {
                auth.signOut().then((_) {
                  GoogleSignInService().logOutFromGoogleLogin();
                  Route route =
                      MaterialPageRoute(builder: (_) => ChooseSignInPage());
                  Navigator.pushReplacement(context, route);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.login_outlined, color: Colors.white),
              ))
        ],
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  Colors.cyanAccent,
                  Colors.cyan,
                  Colors.indigo,
                  Colors.deepPurple
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 0.2, 0.7, 1.0],
                tileMode: TileMode.clamp),
          ),
        ),
        title: Text(("Home page")),
        centerTitle: centertitle,
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Container(
          width: width,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Filter icon
                    InkWell(
                      onTap: () {
                        showDialogForFilter(context);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 35,
                        ),
                      ),
                    ),

                    //Forum button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavouritesPage()),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          'Favourites',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    //Forum button
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForumPostsPage()),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          'Forum',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              showCarsList(),
            ],
          ),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        child: Container(
          height: 60,
          width: 60,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              gradient: new LinearGradient(
                  colors: [
                    Colors.cyanAccent,
                    Colors.cyan,
                    Colors.indigo,
                    Colors.deepPurple
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 0.2, 0.7, 1.0],
                  tileMode: TileMode.clamp)),
          child: Icon(Icons.add),
        ),
        tooltip: 'Add post',
        onPressed: () {
          showDialogForAddingData();
        },
      ),
    );
  }
}
