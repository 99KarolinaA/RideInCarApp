import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:icar/functions.dart';
import 'package:icar/globalVariables.dart';
import 'package:icar/profilePage.dart';
import 'package:icar/utils/config.dart';
import 'package:icar/utils/others_helper.dart';
import 'package:timeago/timeago.dart' as tAgo;

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key key}) : super(key: key);

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final _currentUserReference = FirebaseFirestore.instance.collection('users');
  carMethods carObject = GetIt.instance.get<carMethods>();

  List favCarList = [];

  bool alreadyLoaded = false;

  @override
  void initState() {
    super.initState();
    getFavData();

    print(alreadyLoaded);
  }

  getFavData() async {
    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('uId', isEqualTo: userId)
        .get();

    List favPostArray = user.docs[0]['favouritePosts'];
    print(favPostArray);

    favCarList = [];

    for (int i = 0; i < favPostArray.length; i++) {
      await Firebase.initializeApp();
      final adData = await FirebaseFirestore.instance
          .collection('cars')
          .doc(favPostArray[i])
          .get();

      if (adData.data() != null) {
        favCarList.add(adData);
      } else {}
      alreadyLoaded = true;
      print(adData.id);
    }

    setState(() {});

    print(favCarList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favourites')),
      body: SingleChildScrollView(
          child: Container(
        child: Column(children: [
          alreadyLoaded == true
              ? favCarList.isNotEmpty
                  ? ListView.builder(
                      itemCount: favCarList.length,
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
                                              sellerId:
                                                  favCarList[i].data()['uId'],
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
                                                favCarList[i].data()['imgPro'],
                                              ),
                                              fit: BoxFit.fill),
                                        ),
                                      ),

                                      //username
                                      title: Text(
                                          favCarList[i].data()['userName']),
                                      subtitle: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              favCarList[i]
                                                  .data()['carLocation'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          //edit post icon
                                          // favCarList[i].data()['uId'] == userId
                                          //     ? GestureDetector(
                                          //         // onTap: () {
                                          //         //   if (favCarList[i].data()['uId'] ==
                                          //         //       userId) {
                                          //         //     showDialogForUpdateData(
                                          //         //       favAds.docs[i].id,
                                          //         //       favCarList[i].data()['uId']['userName'],
                                          //         //       favCarList[i].data()['uId']['userNumber'],
                                          //         //       favAds.docs[i]
                                          //         //           .data()['carPrice']
                                          //         //           .toString(),
                                          //         //       favCarList[i].data()['uId']['carModel'],
                                          //         //       favCarList[i].data()['uId']['carColor'],
                                          //         //       favCarList[i].data()['uId']['carLocation'],
                                          //         //       favCarList[i].data()['uId']['description'],
                                          //         //     );
                                          //         //   }
                                          //         // },
                                          //         child: Icon(
                                          //           Icons.edit_outlined,
                                          //         ),
                                          //       )
                                          //     : Container(),
                                          SizedBox(
                                            width: 20,
                                          ),

                                          //delete post icon
                                          // favCarList[i].data()['uId'] == userId
                                          //     ? GestureDetector(
                                          //         onDoubleTap: () {
                                          //           // if (favCarList[i].data()['uId']['uId'] ==
                                          //           //     userId) {
                                          //           //   carObject.deleteData(favAds.docs[i].id);
                                          //           //   Route route = MaterialPageRoute(
                                          //           //       builder: (BuildContext c) =>
                                          //           //           Homepage());
                                          //           //   Navigator.push(context, route);
                                          //           // }
                                          //         },
                                          //         child: Icon(
                                          //             Icons.delete_forever_sharp))
                                          //     : Container(),

                                          //Favourite post icon

                                          StreamBuilder(
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

                                                  return InkWell(
                                                    onTap: () async {
                                                      await carObject
                                                          .favouriteAd(
                                                              favCarList[i].id);
                                                      getFavData();
                                                    },
                                                    child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 15,
                                                                vertical: 15),
                                                        child: Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                        )),
                                                  );
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
                                    imageUrl: favCarList[i].data()['urlImage'],
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
                                    '\$ ' +
                                        favCarList[i]
                                            .data()['carPrice']
                                            .toString(),
                                    style: TextStyle(
                                      fontFamily: "Bebas",
                                      letterSpacing: 2.0,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.directions_car),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Align(
                                              child: Text(favCarList[i]
                                                  .data()['carModel']),
                                              alignment: Alignment.topLeft,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.watch_later_outlined),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Align(
                                              //child: Text(favCarList[i].data()['uId']['time'].toString()),
                                              child: Text(tAgo.format(
                                                  (favCarList[i].data()['time'])
                                                      .toDate())),
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
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.brush_outlined),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Align(
                                              child: Text(favCarList[i]
                                                  .data()['carColor']),
                                              alignment: Alignment.topLeft,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_android),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Align(
                                              //child: Text(favCarList[i].data()['uId']['time'].toString()),
                                              child: Text(favCarList[i]
                                                  .data()['userNumber']),
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
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15.0),
                                  child: Text(
                                    favCarList[i].data()['description'],
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
                    )
                  : Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height - 160,
                      child: Text('You don\'t have any favourites'),
                    )
              : Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height - 160,
                  child: OthersHelper().showLoading(Colors.blue),
                )
          // }
        ]),
      )),
    );
  }
}
