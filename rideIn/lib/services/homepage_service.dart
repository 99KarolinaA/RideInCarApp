import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomepageService with ChangeNotifier {
  String currentLocation;

  setCurrentLocation(String value) {
    currentLocation = value;
    print('current location $currentLocation');
    notifyListeners();
  }

  Future determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permission = await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return false;
      } else {
        //permission accepted
        return await Geolocator.getCurrentPosition();
      }
    } else {
      //gps is on
      permission = await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return false;
      } else {
        //permission accepted
        return await Geolocator.getCurrentPosition();
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
  }

  Future<void> GetAddressFromLatLong(
      position, TextEditingController locationController) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    // this.carLocation =
    //     '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    var carLocation = '${place.locality}, ${place.subLocality}';

    locationController.text = carLocation;

    setCurrentLocation(carLocation);
  }
}
