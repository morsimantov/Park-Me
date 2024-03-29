import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:park_me/config/strings.dart';
import 'package:park_me/model/filter_parameters.dart';
import 'package:park_me/model/parking_lot.dart';
import 'package:park_me/screens/search_screen.dart';
import 'dart:convert';
import '../env.sample.dart';
import 'home_screen.dart';
import 'lot_details_screen.dart';
import '../utils.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  static const String _appBarTitle = "Your Favorites";
  static const String _emptyFavoritesMsg = "Your Favorites list is empty";
  static const double _fontSize = 15;
  static const double _fontSizeTitle = 20;

  late List<ParkingLot> _parkingLots;
  Position? _currentUserPosition;
  late double _wantedLocationLat;
  late double _wantedLocationLong;
  late bool _isFavoritesEmpty = false;
  int _selectedIndex = 2;

  final user = FirebaseAuth.instance.currentUser!;
  final parkinglotListKey = GlobalKey<FavoritesScreenState>();

  @override
  void initState() {
    super.initState();
    _parkingLots = [];
    // Initialize parking lots list
    getParkingLotList();
  }

  Future<void> getParkingLotList() async {
    final id = user.uid;
    // Retrieve favorites lots from the server
    final response =
        await http.get(Uri.parse("${Env.URL_PREFIX}/favorites/$id"));
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    // Convert JSON data to ParkingLot objects
    List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    setState(() {
      // Add fetched parking lots to the existing list
      _parkingLots.addAll(parkingLotsTemp);
      if (_parkingLots.isEmpty) {
        _isFavoritesEmpty = true;
      }
    });
    // Calculate distances to the parking lots
    getLotDistances();
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
      // Convert the distance from meters to kilometers
      var distance = distanceInMeter?.round().toInt();
      // Update the distance of each parking lot
      parkingLotItem.distance = (distance! / 1000);
      setState(() {});
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
      }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: const Text(_appBarTitle),
        backgroundColor: const Color(0xFF03A295),
      ),
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
        // selectedItemColor: const Color(0xFF03A295),
        selectedItemColor: const Color(0xff67686b),
        onTap: onItemTapped,
      ),
      body: (_isFavoritesEmpty)
          ? const Padding(
              padding: EdgeInsets.only(top: 25),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  _emptyFavoritesMsg,
                  style: TextStyle(
                    fontFamily: fontFamilyMiriam,
                    fontSize: 17,
                    color: Color(0xFF626463),
                  ),
                ),
              ),
            )
          // By default, show a loading spinner.
          : (_parkingLots.isEmpty)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              // Render ParkingLot lists
              : Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _parkingLots.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = _parkingLots[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LotDetailsScreen(
                                lotId: data.lot_id,
                                distance: data.distance,
                              ),
                            ),
                          );
                        },
                        child: Container(
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
                                        fontFamily: fontFamilyMiriam,
                                        fontWeight: FontWeight.bold,
                                        fontSize: _fontSize,
                                        color: Color(0xFF626463),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Row(children: [
                                        Expanded(
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4, bottom: 3),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  data.lot_name,
                                                  style: const TextStyle(
                                                      fontSize: _fontSizeTitle),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection("favorites")
                                                .where('uid',
                                                    isEqualTo: user.uid)
                                                .where('parkingLot',
                                                    isEqualTo: data.lot_id)
                                                .snapshots(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              if (snapshot.data == null) {
                                                return const Text("");
                                              }
                                              return IconButton(
                                                  icon: snapshot.data.docs
                                                              .length ==
                                                          0
                                                      ? const Icon(
                                                          Icons
                                                              .star_border_outlined,
                                                          color: Colors.black,
                                                        )
                                                      : const Icon(
                                                          Icons.star,
                                                          color: Colors.yellow,
                                                        ),
                                                  onPressed: () => {
                                                        if (snapshot.data.docs
                                                                .length ==
                                                            0)
                                                          {
                                                            addToFavorites(
                                                                user.uid,
                                                                data.lot_id)
                                                          }
                                                        else
                                                          {
                                                            removeFromFavorites(
                                                                user.uid,
                                                                data.lot_id),
                                                            _parkingLots.removeWhere(
                                                                (item) =>
                                                                    item.lot_id ==
                                                                    data.lot_id),
                                                            // If the list is empty now
                                                            if (_parkingLots
                                                                .isEmpty)
                                                              {
                                                                _isFavoritesEmpty =
                                                                    true,
                                                              },
                                                            setState(() {})
                                                          }
                                                      });
                                            }),
                                      ]),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 19),
                                        child: Text(
                                          data.address,
                                          style: const TextStyle(
                                              textBaseline:
                                                  TextBaseline.ideographic),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 19),
                                        child: Text((() {
                                          if (data.hourly_fare == true &&
                                              data.fixed_price != null) {
                                            return fixedAnHourlyPrice;
                                          } else if (data.hourly_fare == true &&
                                              data.fixed_price == null) {
                                            return hourlyPrice;
                                          } else if (data.hourly_fare != true &&
                                              data.fixed_price != null) {
                                            return fixedPrice;
                                          }
                                          return unknownPaying;
                                        })()),
                                      ),
                                      Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 210, top: 10),
                                            child: data.availability != null
                                                ? CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor: data
                                                                .availability! ==
                                                            1
                                                        ? Colors.deepOrange
                                                        : data.availability! ==
                                                                0.7
                                                            ? Colors
                                                                .orangeAccent
                                                            : Colors.green,
                                                    child: data.availability! <
                                                            1
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.white)
                                                        : const Icon(
                                                            Icons.close,
                                                            color:
                                                                Colors.white),
                                                  )
                                                : const CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Colors.white),
                                          ),
                                          data.availability != null
                                              ? Positioned(
                                                  left: 37,
                                                  top: 18,
                                                  child: Text(
                                                    data.availability! == 1
                                                        ? fullStr
                                                        : data.availability! ==
                                                                0.7
                                                            ? almostFullStr
                                                            : availableStr,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          fontFamilyMiriam,
                                                      fontSize: _fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF626463),
                                                    ),
                                                  ),
                                                )
                                              : const Center(),
                                          data.paying_method !=
                                                  (unknownPayingMethod)
                                              ? Positioned(
                                                  top: 9,
                                                  left: 145,
                                                  child: data.paying_method
                                                          .contains(cash)
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
                                                        ))
                                              : const Center(),
                                          Positioned(
                                              top: 11,
                                              left: 195,
                                              child: data.is_accessible == true
                                                  ? Image.asset(
                                                      'assets/images/disability.png',
                                                      height: 29,
                                                      width: 29,
                                                      fit: BoxFit.fitWidth,
                                                    )
                                                  : const Center()),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
