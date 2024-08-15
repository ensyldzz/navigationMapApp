import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:map_app/helpers/constant/snack_bar.dart';
import 'package:map_app/helpers/constant/text.dart';

class LocationHelper {
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      snackBar(context, ConstantText.locationDisable);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        snackBar(context, ConstantText.locationReject);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      snackBar(context, ConstantText.locationError);
      return false;
    }
    return true;
  }

  static Stream<LatLng> getPositionStream() {
    return Geolocator.getPositionStream().map((event) {
      return LatLng(event.latitude, event.longitude);
    });
  }
}
