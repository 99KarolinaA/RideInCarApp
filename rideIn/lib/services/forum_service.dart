import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ForumService with ChangeNotifier {
  bool isloading = false;

  formatDate(date) {
    var input = DateFormat.yMMMd().add_jm().format(date);
    return input;
  }

  setDefault() {
    pickedImage = null;
    downloadUrl = null;
  }

  final _firebaseStorage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();
  XFile pickedImage;
  var downloadUrl;

  pickImage() async {
    pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  pickImageFromCamera() async {
    pickedImage = await _imagePicker.pickImage(source: ImageSource.camera);
    notifyListeners();
  }

  Future<bool> uploadImage() async {
    isloading = true;
    notifyListeners();

    var file = File(pickedImage.path);

    if (pickedImage != null) {
      //Upload to Firebase
      var snapshot =
          await _firebaseStorage.ref().child('images/imageName').putFile(file);
      downloadUrl = await snapshot.ref.getDownloadURL();
      isloading = false;
      notifyListeners();
      print('download url of image $downloadUrl');

      return true;
    } else {
      print('No Image Path Received');
      return false;
    }
  }
}
