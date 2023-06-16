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
import 'lot_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  FavoritesScreenState createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  late List<ParkingLot> parkingLots;
  Position? _currentUserPosition;
  late double wantedLocationLat;
  late double wantedLocationLong;
  final user = FirebaseAuth.instance.currentUser!;
  late bool _isFavoritesEmpty = false;

  double? distanceInMeter = 0.0;

  final parkinglotListKey = GlobalKey<FavoritesScreenState>();
  int _selectedIndex = 2;

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
                filterStatus:
                    FilterParameters(false, false, false, false, false, false, false),
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
  }

  Future<void> getParkingLotList() async {
    final id = user.uid;
    print(id);
    final response =
        await http.get(Uri.parse("${Env.URL_PREFIX}/favorites/$id"));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    setState(() {
      parkingLots.addAll(parkingLotsTemp);
      if (parkingLots.isEmpty) {
        _isFavoritesEmpty = true;
      }
    });
    _getTheDistance();
  }

  Future<void> addToFavorites(String uid, int lot_id) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String fid = const Uuid().v4();
    await _firestore.collection('favorites').doc(fid).set({
      'fid': fid,
      'uid': uid,
      'parkingLot': lot_id,
    });
  }

  Future<void> removeFromFavorites(String uid, int lot_id) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    parkingLots.removeWhere((item) => item.lot_id == lot_id);
    var snapshot = await _firestore
        .collection("favorites")
        .where('uid', isEqualTo: uid)
        .where('parkingLot', isEqualTo: lot_id)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    if (parkingLots.isEmpty) {
      _isFavoritesEmpty = true;
    }
    setState(() {});
  }

  Future _getTheDistance() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('current User Position: ');
    print(_currentUserPosition);
    wantedLocationLat = _currentUserPosition!.latitude;
    wantedLocationLong = _currentUserPosition!.longitude;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: const Text("Your Favorites"),
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
        // selectedItemColor: const Color(0xFF03A295),
        selectedItemColor: const Color(0xff67686b),
        onTap: _onItemTapped,
      ),
      body:
      (_isFavoritesEmpty) ?

        const Padding(
          padding: EdgeInsets.only(
              top: 25), child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "No parking lots available",
            style: TextStyle(
              fontFamily: 'MiriamLibre',
              fontSize: 17,
              color: Color(0xFF626463),
            ),
          ),
        ),) :

      // By default, show a loading spinner.
          (parkingLots.isEmpty)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              // Render ParkingLot lists
              : Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: parkingLots.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = parkingLots[index];
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
                                        fontFamily: 'MiriamLibre',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
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
                                            child:  Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4, bottom: 3),
                                              child: Align(
                                                alignment:
                                                Alignment.centerRight,
                                                child: Text(
                                                  data.lot_name,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ),),),
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
                                                return Text("");
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
                                                  onPressed: () => snapshot.data
                                                              .docs.length ==
                                                          0
                                                      ? addToFavorites(
                                                          user.uid, data.lot_id)
                                                      : removeFromFavorites(
                                                          user.uid,
                                                          data.lot_id));
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
                                            return "תשלום שעתי וחד פעמי";
                                          } else if (data.hourly_fare == true &&
                                              data.fixed_price == null) {
                                            return "תשלום שעתי בלבד";
                                          } else if (data.hourly_fare != true &&
                                              data.fixed_price != null) {
                                            return "תשלום חד פעמי";
                                          }
                                          return "תשלום בהתאם לשילוט במקום";
                                        })()),
                                      ),
                                      Stack(
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                right: 210,
                                                top: 10),
                                            child: data.availability !=
                                                null
                                                ? CircleAvatar(
                                              radius: 15,
                                              backgroundColor:
                                              data.availability! ==
                                                  1 ? Colors
                                                  .deepOrange : data.availability! == 0.7
                                                  ? Colors
                                                  .orangeAccent
                                                  : Colors
                                                  .green,
                                              child: data.availability! <
                                                  1
                                                  ? const Icon(
                                                  Icons.check,
                                                  color: Colors
                                                      .white)
                                                  : const Icon(
                                                  Icons.close,
                                                  color: Colors
                                                      .white),
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
                                              data.availability! ==
                                                  1 ? "Full" :  data.availability! == 0.7
                                                  ? "Almost Full"
                                                  : "Available!",
                                              style:
                                              const TextStyle(
                                                fontFamily:
                                                'MiriamLibre',
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color: Color(
                                                    0xFF626463),
                                              ),
                                            ),
                                          )
                                              : const Center(),
                                          data.paying_method !=
                                                  ("בהתאם לשילוט במקום")
                                              ? Positioned(
                                                  top: 9,
                                                  left: 145,
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
