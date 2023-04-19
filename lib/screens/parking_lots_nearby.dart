import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park_me/screens/search_screen.dart';
import '../model/filter_parameters.dart';
import '../model/parking_lot.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../env.sample.dart';

class ParkingLotsNearbyScreen extends StatefulWidget {
  const ParkingLotsNearbyScreen({Key? key}) : super(key: key);

  @override
  State<ParkingLotsNearbyScreen> createState() =>
      _ParkingLotsNearbyScreenState();
}

class _ParkingLotsNearbyScreenState extends State<ParkingLotsNearbyScreen> {
  Position? _currentUserPosition;
  double? distanceImMeter = 0.0;
  late Future<List<ParkingLot>> allParkingLots;
  final parkinglotListKey = GlobalKey<_ParkingLotsNearbyScreenState>();
  Map<ParkingLot, Location> parkingLotsLocations = {};
  late List<ParkingLot> parkingLotsObjects = [];

  @override
  void initState() {
    super.initState();
    allParkingLots = getParkingLotList();
    getLotsLocations();
    _getTheDistance();
  }

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

  Future _getTheDistance() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('current User Position: ');
    print(_currentUserPosition);

    parkingLotsLocations.forEach((key, value) async {
      double parkingLotLat = value.latitude;
      double parkingLotLng = value.longitude;

      distanceImMeter = await Geolocator.distanceBetween(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
        parkingLotLat,
        parkingLotLng,
      );
      var distance = distanceImMeter?.round().toInt();
      key.distance = (distance! / 1000);
      setState(() {});
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(
                title: '',
                filterStatus:
                    FilterParameters(false, false, false, false, false),
              ),
            ));
      }
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

  @override
  Widget build(BuildContext context) {
    parkingLotsObjects = parkingLotsLocations.keys.toList();
    parkingLotsObjects.sort((a, b) => a.distance.compareTo(b.distance));
    parkingLotsObjects = parkingLotsObjects.take(8).toList();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF03A295),
        title: const Text("All Parking Lots Near you"),
      ),
      backgroundColor: const Color(0xfff6f7f9),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Center(
          child: (parkingLotsObjects.isEmpty)
              ? const CircularProgressIndicator()
              : GridView.builder(
                  itemCount: parkingLotsObjects.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3 / 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
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
                              borderRadius: const BorderRadiusDirectional.only(
                                topEnd: Radius.circular(8.0),
                                topStart: Radius.circular(8.0),
                              ),
                              child: Image.network(
                                parkingLotsObjects[index].image,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            parkingLotsObjects[index].lot_name,
                            style: const TextStyle(
                              fontSize: 19,
                              color: Color(0xFF626463),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, color: Colors.teal),
                              Text(
                                "${parkingLotsObjects[index].distance.round()} KM Away",
                                style: const TextStyle(
                                  fontFamily: 'MiriamLibre',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF626463),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
        ),
      ),
    );
  }
}
