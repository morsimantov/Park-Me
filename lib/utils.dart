import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'env.sample.dart';
import 'model/parking_lot.dart';
import 'package:http/http.dart' as http;

Future<String> getAddressFromCoordinates(
    double latitude, double longitude) async {
  const String errorMessage = "Address not found";
  try {
    // Retrieve the list of placemarks from the provided coordinates
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      // Extract relevant address components and format the address
      String address =
          '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      return address;
    }
  } catch (e) {
    // Handle any errors that occur during the address retrieval process
    print('Error: $e');
  }
  // Return an error message if the address couldn't be retrieved
  return errorMessage;
}

Future<bool> validateAddress(String address) async {
  try {
    // Perform geocoding with the provided address
    List<Location> locations = await locationFromAddress(address);
    /*
       If the geocoding is successful and returns at least one location,
       consider the address as valid.
       */

    return locations.isNotEmpty;
  } catch (e) {
    // Error occurred during geocoding, so the address is considered invalid
    return false;
  }
}

Future<void> addToFavorites(String uid, int lot_id) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Generate a unique ID for the favorite lot entry
  String fid = const Uuid().v4();
  // Add the favorite lot entry to Firestore
  await _firestore.collection('favorites').doc(fid).set({
    'fid': fid,
    'uid': uid,
    'parkingLot': lot_id,
  });
}

Future<void> removeFromFavorites(String uid, int lot_id) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Query Firestore to find the matching favorite lot entry
  var snapshot = await _firestore
      .collection("favorites")
      .where('uid', isEqualTo: uid)
      .where('parkingLot', isEqualTo: lot_id)
      .get();
  // Delete the matching favorite lot entry
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

int convertToWalkingDistance(double distanceInKm) {
  // Assuming an average walking speed of 5 kilometers per hour
  double walkingSpeedKph = 5.0;
  // Convert walking speed from kilometers per hour to kilometers per minute
  double walkingSpeedKpm = walkingSpeedKph / 60.0;
  // Calculate the walking time in minutes
  double walkingTimeMinutes = distanceInKm / walkingSpeedKpm;
  return walkingTimeMinutes.round();
}

double convertToKilometers(double timeInMinutes) {
  double walkingSpeed = 5.0; // 5 km/h is an average walking speed
  double timeInHours = timeInMinutes / 60;
  double distanceInKm = walkingSpeed * timeInHours;
  return distanceInKm;
}