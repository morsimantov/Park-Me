import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park_me/screens/search_screen.dart';
import '../model/filter_parameters.dart';
import '../model/parking_lot.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../env.sample.dart';
import 'lot_details_screen.dart';
import '../config/strings.dart';

class ParkingLotsNearbyScreen extends StatefulWidget {
  const ParkingLotsNearbyScreen({Key? key}) : super(key: key);

  @override
  State<ParkingLotsNearbyScreen> createState() =>
      _ParkingLotsNearbyScreenState();
}

class _ParkingLotsNearbyScreenState extends State<ParkingLotsNearbyScreen> {
  static const String _appBarTitle = "All Parking Lots Near you";
  static const double _fontSize = 17;
  static const double _fontSizeTitle = 19;

  int _selectedIndex = 1;
  Position? _currentUserPosition;
  late List<ParkingLot> _parkingLots;
  late List<ParkingLot> _parkingLotsOrigin = [];
  late double _wantedLocationLat;
  late double _wantedLocationLong;

  final parkinglotListKey = GlobalKey<_ParkingLotsNearbyScreenState>();

  @override
  void initState() {
    super.initState();
    _parkingLots = [];
    // Get parking lots list
    getParkingLotList();
  }

  Future<void> getParkingLotList() async {
    // Send a GET request to retrieve the parking lot list from the specified URL
    final response = await http.get(Uri.parse(Env.URL_PREFIX));
    final decodedResponse = utf8.decode(response.bodyBytes);
    // Decode the response and cast it to a list of Map<String, dynamic>
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    // Map the JSON response to a list of ParkingLot objects
    List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    setState(() {
      // Add the parking lots to the _parkingLotsOrigin list
      _parkingLotsOrigin.addAll(parkingLotsTemp);
    });
    // Retrieve the distances for the parking lots
    await getLotDistances();
    // Sort the parking lots based on distance
    _parkingLotsOrigin.sort((a, b) => a.distance.compareTo(b.distance));
    // Take the first 8 closest parking lots from the sorted list
    _parkingLotsOrigin = _parkingLotsOrigin.take(8).toList();
    // Update the parkingLots list with the selected parking lots
    _parkingLots = _parkingLotsOrigin;
  }


  Future getLotDistances() async {
    LocationPermission permission;
    double? distanceInMeter = 0.0;
    // Request location permission
    permission = await Geolocator.requestPermission();
    // Get the current user's position
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _wantedLocationLat = _currentUserPosition!.latitude;
    _wantedLocationLong = _currentUserPosition!.longitude;
    for (var parkingLotItem in _parkingLots) {
      final address = parkingLotItem.address;
      // Get the location coordinates for the parking lot address
      List<Location> locations = await locationFromAddress(address);
      Location lotLocation = locations.first;
      double parkingLotLat = lotLocation.latitude;
      double parkingLotLng = lotLocation.longitude;
      // Calculate the distance between user's location and the parking lot
      distanceInMeter = await Geolocator.distanceBetween(
        _wantedLocationLat,
        _wantedLocationLong,
        parkingLotLat,
        parkingLotLng,
      );
      var distance = distanceInMeter?.round().toInt();
      // Update the distance of each parking lot
      parkingLotItem.distance = (distance! / 1000);
      setState(() {});
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(
                title: '',
                filterStatus: FilterParameters(
                    false, false, false, false, false, false, false),
              ),
            ));
      }
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: const Color(0xFF03A295),
        title: const Text(_appBarTitle),
      ),
      backgroundColor: const Color(0xfff6f7f9),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Center(
          child: (_parkingLots.isEmpty)
              ? const CircularProgressIndicator()
              : GridView.builder(
                  itemCount: _parkingLots.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LotDetailsScreen(
                                lotId: _parkingLots[index].lot_id,
                                distance: _parkingLots[index].distance,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: height * 0.9,
                          width: width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xffd6e6e6),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xFFCCC8C8),
                                  blurRadius: 5,
                                  spreadRadius: 3,
                                  offset: Offset(3, 2)),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: height * 0.15,
                                width: width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.teal,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.1),
                                      blurRadius: 6.0,
                                      spreadRadius: .1,
                                    ), //BoxShadow
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      const BorderRadiusDirectional.only(
                                    topEnd: Radius.circular(8.0),
                                    topStart: Radius.circular(8.0),
                                  ),
                                  child: Image.network(
                                    _parkingLots[index].image,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _parkingLots[index].lot_name,
                                    style: const TextStyle(
                                      fontSize: _fontSizeTitle,
                                      color: Color(0xFF626463),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  (_parkingLots[index].availability != null)
                                      ? CircleAvatar(
                                          radius: 5,
                                          backgroundColor: _parkingLots[index]
                                                      .availability ==
                                                  0
                                              ? Colors.green
                                              : _parkingLots[index]
                                                          .availability ==
                                                      0.7
                                                  ? Colors.orangeAccent
                                                  : Colors.deepOrange,
                                        )
                                      : const Center(),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.teal),
                                  Text(
                                    "${_parkingLots[index].distance.toStringAsFixed(1)} KM Away",
                                    style: const TextStyle(
                                      fontFamily: fontFamilyMiriam,
                                      fontSize: _fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF626463),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                  }),
        ),
      ),
    );
  }
}
