import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:park_me/model/filter_parameters.dart';
import 'package:park_me/screens/parking_lots_results_screen.dart';
import 'package:park_me/screens/favorites_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'filter_screen.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../utils.dart';
import '../config/strings.dart';

class SearchScreen extends StatefulWidget {
  final FilterParameters filterStatus;
  final String title;

  const SearchScreen(
      {super.key, required this.title, required this.filterStatus});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _appBarTitle = "Find a Parking spot";
  static const String _currentLocationStr = "Current Location";
  static const String _loadingMsg = "Loading";

  late Position _currentPosition;
  int _selectedIndex = 0;
  String wantedLocationAddress = "Current Location";
  bool _suggestionSelected = false;
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  // Flag to track suggestion list visibility
  bool _showSuggestions = false;


  late GoogleMapController _mapController;
  final _searchController = TextEditingController();

  static late CameraPosition _initialPosition =
      CameraPosition(target: LatLng(32.0798, 34.7683), zoom: 18.0);

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
    _searchController.addListener(() {
      onChanged();
    });
    SmartDialog.showLoading(
      msg: _loadingMsg,
      maskColor: const Color(0xffebecf3),
    );
    getCurrentPosition();
    SmartDialog.dismiss();
  }

  Future<Position> getCurrentPosition() async {
    LocationPermission permission;
    // Request location permission from the user
    permission = await Geolocator.requestPermission();
    // Get the current position of the user
    Position currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // Store the current position in the _currentPosition variable
    _currentPosition = currentUserPosition;
    // Set the marker at the current position on the map
    setMarker(_currentPosition!.latitude, _currentPosition!.longitude);
    // Set the initial position of the camera on the map
    _initialPosition = CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 18.0);
    // Return the current position
    return currentUserPosition;
  }

  Future<void> setMarker(double lat, double long) async {
    // Clear existing markers
    markers.clear();
    // Add a new marker at the specified latitude and longitude
    markers.add(Marker(
        markerId: const MarkerId(_currentLocationStr),
        position: LatLng(lat, long)));
    // Update the state to reflect the changes in markers
    setState(() {});
  }

  void onChanged() {
    if (_suggestionSelected == false) {
      if (_sessionToken == null) {
        // Generate a new session token if it's null
        setState(() {
          _sessionToken = uuid.v4();
        });
      }
      // Get place suggestions based on the user's input
      getSuggestion(_searchController.text);
    }
  }

  void getSuggestion(String input) async {
    const String errorMessage = "Failed to load predictions";
    // Define the Places API key and type
    String kPLACES_API_KEY = "AIzaSyC4VmB_2iR5E6wN_mU3Fqcn19HxHqRGTDo";
    try {
      // Construct the request URL with the input, API key, and session token
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      // Send a GET request to the Google Places Autocomplete API
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        // If the response status code is 200 (success), update the state with the predictions
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Handle the error
    }
  }

  Future<void> onSubmittedResult(value) async {
    const String alertTitle = "Address Not Found";
    const String alertText = "Please enter a valid address";
    // If the wanted address is empty or null
    if (value == '' || value == null) {
      // Set the wanted location address to the current location address
      wantedLocationAddress = _currentLocationStr;
    } else {
      wantedLocationAddress = value;
    }
    // Validate the address
    bool isValid = await validateAddress(value);
    /*
     If the address is valid or the wanted location address is the current
     location address.
     */

    if (isValid || wantedLocationAddress == _currentLocationStr) {
      // Get the location from the address
      locationFromAddress(wantedLocationAddress);
      /*
       Navigate to the ParkingLotsResultsScreen with the wanted location address
       and filter status,
       */

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ParkingLotsResultsScreen(
              wantedLocationAddress: wantedLocationAddress,
              filterStatus: widget.filterStatus,
            ),
          ));
    } else {
      // Show an error alert
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: alertTitle,
        text: alertText,
        confirmBtnColor: const Color(0xFF03A295),
      );
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ));
      } else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FavoritesScreen(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(_appBarTitle),
          backgroundColor: const Color(0xFF03A295),
        ),
        backgroundColor: const Color(0xfff5f6fa),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xe4e8eaf1),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: searchLabel,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: homeLabel,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: favoritesLabel,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xff67686b),
          onTap: onItemTapped,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 189.0),
          child: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF6EB4AD),
            onPressed: () async {
              setMarker(
                  _currentPosition!.latitude, _currentPosition!.longitude);
              _mapController.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 18)));
              wantedLocationAddress = _currentLocationStr;
              _searchController.clear();
              setState(() {});
            },
            label: const Text(_currentLocationStr),
            icon: const Icon(Icons.location_history),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: markers,
              // zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: (LatLng location) {
                setState(() async {
                  String address = await getAddressFromCoordinates(
                      location.latitude, location.longitude);
                  _searchController.value =
                      _searchController.value.copyWith(text: address);
                  wantedLocationAddress = address;
                  markers.clear();
                  setMarker(location.latitude, location.longitude);
                });
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: TextField(
                    onTap: () {
                      setState(() {
                        _showSuggestions =
                            true; // Show suggestions on text field tap
                      });
                    },
                    onSubmitted: (value) async {
                      onSubmittedResult(value);
                    },
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: _currentLocationStr,
                      hintStyle: const TextStyle(
                        fontFamily: fontFamilyMiriam,
                      ),
                      focusColor: Colors.white,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            setMarker(_currentPosition!.latitude,
                                _currentPosition!.longitude);
                            _mapController.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: LatLng(_currentPosition!.latitude,
                                        _currentPosition!.longitude),
                                    zoom: 18)));
                            wantedLocationAddress = _currentLocationStr;
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
                                onSubmittedResult(_searchController.value.text);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _showSuggestions // Only show suggestion list when the flag is true
                      ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _placeList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _showSuggestions =
                                        false; // Hide suggestion list
                                  });
                                  List<Location> locations =
                                      await locationFromAddress(
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
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                                target:
                                                    LatLng(latitude, longitude),
                                                zoom: 18)));
                                    markers.clear();
                                    setMarker(latitude, longitude);
                                  });
                                },
                                child: Container(
                                  color: Colors.white,
                                  child: ListTile(
                                      tileColor: Colors.white,
                                      title: Text(
                                          _placeList[index]["description"])),
                                ));
                          },
                        )
                      : const SizedBox(), // Empty SizedBox when the suggestion list is hidden
                ),
              ],
            ),
          ],
        ));
  }
}
