import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:park_me/model/filter_parameters.dart';
import 'package:park_me/model/parking_lot.dart';
import 'package:park_me/screens/search_screen.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../env.sample.dart';
import 'home_screen.dart';

class ParkingLotsResultsScreen extends StatefulWidget {
  final String wantedLocationAddress;
  final FilterParameters filterStatus;

  const ParkingLotsResultsScreen(
      {super.key,
      required this.wantedLocationAddress,
      required this.filterStatus});

  @override
  ParkingLotsResultsScreenState createState() =>
      ParkingLotsResultsScreenState();
}

class ParkingLotsResultsScreenState extends State<ParkingLotsResultsScreen> {
  late List<ParkingLot> parkingLots;
  Position? _currentUserPosition;
  late double wantedLocationLat;
  late double wantedLocationLong;

  double? distanceInMeter = 0.0;

  final parkinglotListKey = GlobalKey<ParkingLotsResultsScreenState>();
  int _selectedIndex = 0;
  late FilterParameters filterStatus = widget.filterStatus;
  late Color _availabilityButtonColor;
  late Color _availabilityTextColor;
  late Color _accessibilityButtonColor;
  late Color _accessibilityTextColor;
  late Color _undergroundButtonColor;
  late Color _undergroundTextColor;
  late Color _priceButtonColor;
  late Color _priceTextColor;

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
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(
                title: '',
                filterStatus: filterStatus,
              ),
            ));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    parkingLots = [];
    getParkingLotList();
    _availabilityButtonColor = filterStatus.availability
        ? const Color(0xFF55C0B3)
        : const Color(0xfff6f7f9);
    _availabilityTextColor =
        filterStatus.availability ? Colors.white : Colors.teal;
    _undergroundButtonColor = filterStatus.isUnderground
        ? const Color(0xFF55C0B3)
        : const Color(0xfff6f7f9);
    _undergroundTextColor =
        filterStatus.isUnderground ? Colors.white : Colors.teal;
    _accessibilityButtonColor = filterStatus.accessibility
        ? const Color(0xFF55C0B3)
        : const Color(0xfff6f7f9);
    _accessibilityTextColor =
        filterStatus.accessibility ? Colors.white : Colors.teal;
    _priceButtonColor = filterStatus.fixedPrice
        ? const Color(0xFF55C0B3)
        : const Color(0xfff6f7f9);
    _priceTextColor = filterStatus.fixedPrice ? Colors.white : Colors.teal;
  }

  Future<void> getParkingLotList() async {
    final response = await http.get(Uri.parse(Env.URL_PREFIX));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    setState(() {
      parkingLots.addAll(parkingLotsTemp);
    });
    _getTheDistance();
  }

  Future<void> addToFavorites(String uid, int lot_id) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String fid = const Uuid().v4();
    await _firestore.collection('favorites').doc(fid).set({'fid': fid,
                                'uid': uid,
                                'parkingLot': lot_id,});
  }

  Future<void> removeFromFavorites(String uid, int lot_id) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var snapshot = await _firestore.collection("favorites").where('uid', isEqualTo: uid).where('parkingLot', isEqualTo: lot_id).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future _getTheDistance() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    print(widget.wantedLocationAddress);
    if (widget.wantedLocationAddress == "current location") {
      _currentUserPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('current User Position: ');
      print(_currentUserPosition);
      wantedLocationLat = _currentUserPosition!.latitude;
      wantedLocationLong = _currentUserPosition!.longitude;
    } else {
      List<Location> locations =
          await locationFromAddress(widget.wantedLocationAddress);
      wantedLocationLat = locations.first.latitude;
      wantedLocationLong = locations.first.longitude;
    }
    for (var parkingLotItem in parkingLots) {
      final address = parkingLotItem.address;
      List<Location> locations = await locationFromAddress(address);
      Location lotLocation = locations.first;
      double parkingLotLat = lotLocation.latitude;
      double parkingLotLng = lotLocation.longitude;
      distanceInMeter = await Geolocator.distanceBetween(
        wantedLocationLat,
        wantedLocationLong,
        parkingLotLat,
        parkingLotLng,
      );
      var distance = distanceInMeter?.round().toInt();
      parkingLotItem.distance = (distance! / 1000);
      setState(() {});
    }
  }

  void orderParkingLotList() {
    // parkingLots.sort((a, b) => a.availability.compareTo(b.availability));
    if (filterStatus.availability) {
      for (var parkingLot in parkingLots) {
        if (parkingLot.availability != 1) {
          parkingLots.remove(parkingLot);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: const Text("Find a Parking spot"),
        backgroundColor: const Color(0xFF03A295),
      ),
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
      body: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            height: 50,
            child: Padding(
                padding: const EdgeInsets.only(top: 7.0),
                child: ListView(scrollDirection: Axis.horizontal, children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 7.0, horizontal: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    if (_availabilityButtonColor == const Color(0xfff6f7f9)) {
                      setState(() {
                        _availabilityButtonColor = const Color(0xFF55C0B3);
                        _availabilityTextColor = Colors.white;
                        filterStatus.availability = true;
                      });
                    } else {
                      setState(() {
                        _availabilityButtonColor = const Color(0xfff6f7f9);
                        _availabilityTextColor = Colors.teal;
                        filterStatus.availability = false;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _availabilityButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Availability',
                    style: TextStyle(
                      color: _availabilityTextColor,
                    ),
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    if (_undergroundButtonColor == const Color(0xfff6f7f9)) {
                      setState(() {
                        _undergroundButtonColor = const Color(0xFF55C0B3);
                        _undergroundTextColor = Colors.white;
                        filterStatus.isUnderground = true;
                      });
                    } else {
                      setState(() {
                        _undergroundButtonColor = const Color(0xfff6f7f9);
                        _undergroundTextColor = Colors.teal;
                        filterStatus.isUnderground = false;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _undergroundButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Underground',
                    style: TextStyle(
                      color: _undergroundTextColor,
                    ),
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    if (_accessibilityButtonColor == const Color(0xfff6f7f9)) {
                      setState(() {
                        _accessibilityButtonColor = const Color(0xFF55C0B3);
                        _accessibilityTextColor = Colors.white;
                        filterStatus.accessibility = true;
                      });
                    } else {
                      setState(() {
                        _accessibilityButtonColor = const Color(0xfff6f7f9);
                        _accessibilityTextColor = Colors.teal;
                        filterStatus.accessibility = false;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _accessibilityButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Accessibility',
                    style: TextStyle(
                      color: _accessibilityTextColor,
                    ),
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    if (_priceButtonColor == const Color(0xfff6f7f9)) {
                      setState(() {
                        _priceButtonColor = const Color(0xFF55C0B3);
                        _priceTextColor = Colors.white;
                        filterStatus.fixedPrice = true;
                      });
                    } else {
                      setState(() {
                        _priceButtonColor = const Color(0xfff6f7f9);
                        _priceTextColor = Colors.teal;
                        filterStatus.fixedPrice = false;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _priceButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'Fixed Price',
                    style: TextStyle(
                      color: _priceTextColor,
                    ),
                  ),
                ),
              ),
            ])),
          ),
          Center(
            child:
                // By default, show a loading spinner.
                (parkingLots.isEmpty)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    // Render ParkingLot lists
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: parkingLots.length,
                        itemBuilder: (BuildContext context, int index) {
                          var data = parkingLots[index];
                          return Container(
                            height: 164,
                            margin: const EdgeInsets.symmetric(
                                vertical: 2.5, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0xFFCCC8C8),
                                    blurRadius: 7,
                                    spreadRadius: 1,
                                    offset: Offset(3, 3))
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.network(
                                              data.image,
                                              fit: BoxFit.cover,
                                              width: 90,
                                              height: 70,
                                            ),
                                          )),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${data.distance.round()} KM Away",
                                        style: const TextStyle(
                                          fontFamily: 'MiriamLibre',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF626463),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0, top: 5.0),
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 177,
                                                    child: Text(
                                                      data.lot_name,
                                                      style: const TextStyle(
                                                          fontSize: 25),
                                                    ),
                                                  ),
                                                )),
                                            StreamBuilder(
                                              stream: FirebaseFirestore.instance.collection("favorites").where('uid', isEqualTo: user.uid).where('parkingLot', isEqualTo: data.lot_id).snapshots(),
                                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                                if (snapshot.data == null) {
                                                  return Text("");
                                                }
                                                return IconButton(icon: snapshot.data.docs.length == 0 ? const Icon(Icons.star_border_outlined, color: Colors.black,)
                                                    : const Icon(Icons.star, color: Colors.yellow,),
                                                    onPressed: () => snapshot.data.docs.length == 0 ? addToFavorites(user.uid, data.lot_id) : removeFromFavorites(user.uid, data.lot_id));
                                                }),
                                          ]),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 28, top: 0),
                                        child: Text(data.address),
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 25,
                                        ),
                                        child: Text((() {
                                          if (data.hourly_fare == 1) {
                                            return "תשלום שעתי";
                                          }
                                          return "תשלום חד פעמי";
                                        })()),
                                      ),
                                      Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 210, top: 10),
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                                  (data.availability == 1)
                                                      ? Colors.green
                                                      : Colors.deepOrange,
                                              child: data.availability == 1
                                                  ? const Icon(Icons.check)
                                                  : const Icon(Icons.close),
                                            ),
                                          ),
                                          Positioned(
                                            left: 37,
                                            top: 18,
                                            child: Text(
                                              data.availability == 1
                                                  ? "Available!"
                                                  : "Full",
                                              style: const TextStyle(
                                                fontFamily: 'MiriamLibre',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF626463),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              top: 9,
                                              left: 135,
                                              child: data.is_accessible == 1
                                                  ? Image.asset(
                                                      'assets/images/disability.png',
                                                      height: 29,
                                                      width: 29,
                                                      fit: BoxFit.fitWidth,
                                                    )
                                                  : const SizedBox(width: 8)),
                                          Positioned(
                                              top: 7,
                                              left: 185,
                                              child: data.paying_method
                                                      .contains("מזומן")
                                                  ? Image.asset(
                                                      'assets/images/cash_credit.png',
                                                      height: 33,
                                                      width: 33,
                                                      fit: BoxFit.fitWidth,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/credit_only.png',
                                                      height: 39,
                                                      width: 39,
                                                      fit: BoxFit.fitWidth,
                                                    )),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
