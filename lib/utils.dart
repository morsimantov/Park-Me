import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'env.sample.dart';
import 'model/parking_lot.dart';
import 'package:http/http.dart' as http;

class Utils {
  Map<ParkingLot, Location> parkingLotsLocations = {};
  Position? _currentUserPosition;
  double? distanceImMeter = 0.0;

  Future<List<ParkingLot>> getParkingLotList() async {
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/api"));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    List<ParkingLot> parkingLots = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();

    return parkingLots;
  }


  Map<ParkingLot, Location> getLotsLocations() {
    getParkingLotList().then((allParkingLots) async {
      for (var parkingLotItem in allParkingLots) {
        final address = parkingLotItem.address;
        List<Location> locations = await locationFromAddress(address);
        parkingLotsLocations[parkingLotItem] = locations.first;
      }
    });
    return parkingLotsLocations;
  }

}