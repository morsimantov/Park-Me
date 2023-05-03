import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:park_me/model/filter_parameters.dart';
import 'package:park_me/screens/parking_lots_results_screen.dart';
import 'filter_screen.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class SearchScreen extends StatefulWidget {
  final FilterParameters filterStatus;
  final String title;

  const SearchScreen(
      {super.key, required this.title, required this.filterStatus});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 0;
  String wantedLocationAddress = "current location";

  // late FilterParameters filterStatus = FilterParameters(false, false, false, false, false);

  late GoogleMapController _mapController;

  static const CameraPosition initialPosition =
      CameraPosition(target: LatLng(31.8980, 34.8094), zoom: 16.0);

  static const CameraPosition targetPosition = CameraPosition(
      target: LatLng(32.8980, 36.8094), zoom: 16.0, bearing: 192.0, tilt: 60);
  Set<Marker> markers = {};
  late Position _position;
  late Position _currentPosition;

  Future<Position> getCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = currentUserPosition;
    setMarker(_currentPosition!.latitude, _currentPosition!.longitude);
    return currentUserPosition;
  }

  Future<void> setMarker(double lat, double long) async {
    markers.clear();
    markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(lat, long)));
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(
                title: '',
              ),
            ));
      }
    });
  }

  final _searchController = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onChanged();
    });
    SmartDialog.showLoading(
      msg: "loading",
      maskColor: const Color(0xffebecf3),
    );
    getCurrentPosition();
    SmartDialog.dismiss();
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_searchController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyC4VmB_2iR5E6wN_mU3Fqcn19HxHqRGTDo";
    String type = '(regions)';

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print('mydata');
      print(data);
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Find a Parking spot"),
          backgroundColor: const Color(0xFF03A295),
        ),
        backgroundColor: const Color(0xfff5f6fa),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xe4e8eaf1),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Favorites',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF03A295),
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF6EB4AD),
          onPressed: () async {
            setMarker(_currentPosition!.latitude, _currentPosition!.longitude);
            _mapController.animateCamera(
                CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 16)));
            wantedLocationAddress = "currentLocation";
            _searchController.clear();
            setState(() {});
          },
          label: const Text("Current Location"),
          icon: const Icon(Icons.location_history),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initialPosition,
              markers: markers,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: TextField(
                    onSubmitted: (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ParkingLotsResultsScreen(
                              wantedLocationAddress: wantedLocationAddress,
                              filterStatus: widget.filterStatus,
                            ),
                          ));
                    },
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Current location",
                      hintStyle: const TextStyle(
                        fontFamily: 'MiriamLibre',
                      ),
                      focusColor: Colors.white,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            setMarker(_currentPosition!.latitude, _currentPosition!.longitude);
                            _mapController.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                    zoom: 16)));
                            wantedLocationAddress = "currentLocation";
                          });
                        },
                      ),
                      suffixIcon: Container(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: InkWell(
                                child: const Icon(
                                  Icons.tune,
                                  color: Color(0xFF626463),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FilterScreen(
                                          wantedLocationAddress:
                                              wantedLocationAddress,
                                          filterStatus: widget.filterStatus,
                                        ),
                                      ));
                                },
                              ),
                            ),
                            InkWell(
                              child: const Icon(Icons.search),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ParkingLotsResultsScreen(
                                        wantedLocationAddress:
                                            wantedLocationAddress,
                                        filterStatus: widget.filterStatus,
                                      ),
                                    ));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _placeList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          List<Location> locations = await locationFromAddress(
                              _placeList[index]['description']);
                          double longitude = locations.last.longitude;
                          double latitude = locations.last.latitude;
                          _searchController.value =
                              _searchController.value.copyWith(
                            text: _placeList[index]['description'],
                          );
                          setState(() {
                            wantedLocationAddress =
                                _placeList[index]['description'];
                            _mapController.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: LatLng(latitude, longitude),
                                    zoom: 16)));
                            markers.clear();
                            setMarker(latitude, longitude);
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          child: ListTile(
                            tileColor: Colors.white,
                            title: Text(_placeList[index]["description"])
                          ),
                        )
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
