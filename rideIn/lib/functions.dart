import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:icar/globalVariables.dart';

class carMethods {
  Future<bool> isLoggedIn() async {
    await Firebase.initializeApp();
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(carData) async {
    await Firebase.initializeApp();
    if (isLoggedIn() != null) {
      FirebaseFirestore.instance
          .collection('cars')
          .add(carData)
          .catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }

  getData() async {
    await Firebase.initializeApp();
    return await FirebaseFirestore.instance
        .collection('cars')
        .orderBy("time", descending: true)
        .get();
  }

  getDataByFilter(color, minPrice, maxPrice, model) async {
    await Firebase.initializeApp();
    return await FirebaseFirestore.instance
        .collection('cars')
        .where('carColorInLowerCase', isEqualTo: color)
        .where('carPrice', isGreaterThanOrEqualTo: minPrice)
        .where('carPrice', isLessThanOrEqualTo: maxPrice)
        .where('carModelInLowerCase', isEqualTo: model)
        .get();
  }

  updateData(selectedDoc, newValue) async {
    await Firebase.initializeApp();
    return await FirebaseFirestore.instance
        .collection('cars')
        .doc(selectedDoc)
        .update(newValue)
        .catchError((e) {
      print(e);
    });
  }

  deleteData(docId) async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection('cars')
        .doc(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  //Forum functions ================>

  Future<void> addForumData(forumData) async {
    await Firebase.initializeApp();
    if (isLoggedIn() != null) {
      FirebaseFirestore.instance
          .collection('forum')
          .doc('posts')
          .collection('postContents')
          .add(forumData)
          .catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }

  //add comment
  Future<void> addComment(commentData) async {
    await Firebase.initializeApp();
    if (isLoggedIn() != null) {
      FirebaseFirestore.instance
          .collection('forum')
          .doc('comments')
          .collection('commentsData')
          .add(commentData)
          .catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }

  //get commentor iamge
  Future getCommentorDetails(commentedBy) async {
    await Firebase.initializeApp();

    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('uId', isEqualTo: commentedBy)
        .get();

    // print(user.docs[0]['imgPro']);
    return user.docs[0];
  }

  //Favourite a ad
  Future<bool> favouriteAd(selectedPostId) async {
    print('fav fun ran');
    await Firebase.initializeApp();
    if (isLoggedIn() != null) {
      final currentAuthUser = FirebaseAuth.instance.currentUser;

      print('current auth user $currentAuthUser');
      print('current user id $userId');

      final user = await FirebaseFirestore.instance
          .collection('users')
          .where('uId', isEqualTo: userId)
          .get();

      List favPostArray = user.docs[0]['favouritePosts'];

      bool isAlreadyFavourite = favPostArray.contains(selectedPostId);

      print(isAlreadyFavourite);

      final currentUser =
          await FirebaseFirestore.instance.collection('users').doc(userId);

      if (isAlreadyFavourite) {
        //if already added to favourite then remove it
        favPostArray.remove(selectedPostId);

        currentUser.update({'favouritePosts': favPostArray}).catchError((e) {
          print(e);
        });

        return false;
      } else {
        //add to favourite

        favPostArray.add(selectedPostId);
        currentUser.update({'favouritePosts': favPostArray}).catchError((e) {
          print(e);
        });

        return true;
      }
    } else {
      print('You need to be logged in');
      return false;
    }
  }

  //check if added to favourite
  Future checkIfAddedToFavourite(selectedPostId) async {
    await Firebase.initializeApp();

    if (isLoggedIn() != null) {
      final user = await FirebaseFirestore.instance
          .collection('users')
          .where('uId', isEqualTo: userId)
          .get();

      if (user.docs.isNotEmpty) {
        List favPostArray = user.docs[0]['favouritePosts'];
        bool isAlreadyFavourite = favPostArray.contains(selectedPostId);
        return isAlreadyFavourite;
      } else {
        return [];
      }
    }
  }

  void saveUserData(userEmail, userName, userNumber, image) async {
    final currentAuthUser = FirebaseAuth.instance.currentUser;

    Map<String, dynamic> userData = {
      'userName': userName,
      'uId': currentAuthUser.uid,
      'userNumber': userNumber,
      'imgPro': image,
      'time': DateTime.now(),
      'favouritePosts': []
    };

    userId = currentAuthUser.uid;
    userEmail = userEmail;
    getUserName = userName;

//if it's a new user who logged in then save his data to the database
    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('uId', isEqualTo: currentAuthUser.uid)
        .get();

    print('user is------------ ${user.docs}');

    if (user == null || user.docs.isEmpty) {
      //that means this is a new user
      await Firebase.initializeApp();
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentAuthUser.uid)
          .set(userData);
    } else {
      print('this is old user');
    }
  }
}
