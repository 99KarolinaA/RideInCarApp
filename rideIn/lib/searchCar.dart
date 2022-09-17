import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:icar/utils/others_helper.dart';
import 'package:icar/view/home/homepage.dart';
import 'package:icar/profilePage.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'dart:io' show Platform;

class SearchCar extends StatefulWidget {
  const SearchCar({Key key}) : super(key: key);

  @override
  _SearchCarState createState() => _SearchCarState();
}

class _SearchCarState extends State<SearchCar> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";

  FirebaseAuth auth = FirebaseAuth.instance;
  String carModel;
  String carColor;
  QuerySnapshot cars;

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search here...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  updateSearchQuery(String newQuery) {
    setState(() {
      getResults();
      searchQuery = newQuery;
    });
  }

  _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  _buildTitle(BuildContext context) {
    return Text("Search Car");
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () {
        Route newRoute = MaterialPageRoute(builder: (_) => Homepage());
        Navigator.pushReplacement(context, newRoute);
      },
      icon: Icon(Icons.arrow_back, color: Colors.white),
    );
  }

  getResults() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection('cars')
        .where("carModelInLowerCase",
            isGreaterThanOrEqualTo: _searchQueryController.text.toLowerCase())
        .where("carModelInLowerCase",
            isLessThanOrEqualTo:
                _searchQueryController.text.toLowerCase() + '\uf8ff')
        .get()
        .then((results) {
      setState(() {
        cars = results;
        print("This is result :: ");
        print("Result = " + cars.docs[0].data()['carModel']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        _screenWidth = _screenWidth;
      } else {
        _screenWidth = _screenWidth * 0.5;
      }
    } catch (e) {
      _screenWidth = _screenWidth * 0.5;
    }
    Widget showCarsList() {
      if (cars != null) {
        return ListView.builder(
          itemCount: cars.docs.length,
          padding: EdgeInsets.all(8.0),
          itemBuilder: (context, i) {
            return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          Route route = MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                    sellerId: cars.docs[i].data()['uId'],
                                  ));
                          Navigator.pushReplacement(context, route);
                        },
                        child: Container(
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
                      ),
                      title: GestureDetector(
                          onTap: () {
                            Route route = MaterialPageRoute(
                                builder: (_) => ProfilePage(
                                      sellerId: cars.docs[i].data()['uId'],
                                    ));
                            Navigator.pushReplacement(context, route);
                          },
                          child: Text(cars.docs[i].data()['userName'])),
                      subtitle: GestureDetector(
                        onTap: () {
                          Route route = MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                    sellerId: cars.docs[i].data()['uId'],
                                  ));
                          Navigator.pushReplacement(context, route);
                        },
                        child: Row(
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
                            SizedBox(
                              width: 4.0,
                            ),
                            Icon(
                              Icons.location_pin,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.network(
                        cars.docs[i].data()['urlImage'],
                        fit: BoxFit.fitHeight,
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
        if (_isSearching == true) {
          return OthersHelper().showLoading(Colors.blue);
        } else {
          return Container();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: _isSearching ? const BackButton() : _buildBackButton(),
        title: _isSearching ? _buildSearchField() : _buildTitle(context),
        actions: _buildActions(),
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
      ),
      body: Center(
          child: Container(
        width: _screenWidth,
        child: showCarsList(),
      )),
    );
  }
}
