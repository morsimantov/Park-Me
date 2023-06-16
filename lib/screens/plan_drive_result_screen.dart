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
import 'package:park_me/screens/parking_lots_results_screen.dart';
import 'package:park_me/screens/search_screen.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../env.sample.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'lot_details_screen.dart';

class PlanDriveResultScreen extends StatefulWidget {
  final String wantedLocationAddress;
  final String day;
  final String timeOfDay;

  const PlanDriveResultScreen({
    super.key,
    required this.wantedLocationAddress,
    required this.day,
    required this.timeOfDay,
  });

  @override
  PlanDriveResultScreenState createState() => PlanDriveResultScreenState();
}

class PlanDriveResultScreenState extends State<PlanDriveResultScreen> {
  // late List<ParkingLot> parkingLots;
  // Position? _currentUserPosition;
  Map<ParkingLot, num> lotsDict = {};
  late double wantedLocationLat = 0;
  late double wantedLocationLong = 0;
  final user = FirebaseAuth.instance.currentUser!;
  late bool _isResultEmpty = false;

  double? distanceInMeter = 0.0;

  final parkinglotListKey = GlobalKey<PlanDriveResultScreenState>();
  int _selectedIndex = 0;

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
                filterStatus: FilterParameters(
                    false, false, false, false, false, false, false),
              ),
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
  void initState() {
    super.initState();
    getParkingLotList();
  }

  Future<void> getParkingLotList() async {
    print(widget.wantedLocationAddress);
    print(widget.timeOfDay);
    print(widget.day);

    final id = user.uid;
    print(id);
    final response = await http.get(Uri.parse(
        "${Env.URL_PREFIX}/closest5lots/${widget.wantedLocationAddress}"
        "/${widget.day}/${widget.timeOfDay}"));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    if (decodedResponse == '[]') {
      setState(() {
        _isResultEmpty = true;
      });
      print("empty response");
      return;
    }
    var decodedResponseJson =
        json.decode(decodedResponse).cast<Map<String, dynamic>>();
    print(decodedResponse);
    // Iterate through the response list
    for (var item in decodedResponseJson) {
      // Extract the ParkingLot object from the "lot" key
      ParkingLot parkingLot = ParkingLot.fromJson(item['lot']);

      // Extract the status value
      num status = item['status'];

      // Add the key-value pair to the dictionary
      lotsDict[parkingLot] = status;
    }
    await _getTheDistance();
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
    var snapshot = await _firestore
        .collection("favorites")
        .where('uid', isEqualTo: uid)
        .where('parkingLot', isEqualTo: lot_id)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    setState(() {});
  }

  Future _getTheDistance() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    List<Location> locations =
        await locationFromAddress(widget.wantedLocationAddress);
    wantedLocationLat = locations.first.latitude;
    wantedLocationLong = locations.first.longitude;
    for (var parkingLotItem in lotsDict.keys) {
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
        title: const Text("Plan a Drive in Advance"),
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
        selectedItemColor: const Color(0xff67686b),
        onTap: _onItemTapped,
      ),
      body: SingleChildScrollView(
        child: (_isResultEmpty)
            ? Column(children: [
                // const Padding(
                //   padding: EdgeInsets.only(top: 25, right: 16, left: 20),
                //   child: Text(
                //     "Unfortunately, We didn't find available parking lots",
                //     style: TextStyle(
                //       fontFamily: 'MiriamLibre',
                //       fontSize: 17,
                //       color: Color(0xFF626463),
                //     ),
                //   ),
                // ),
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'Address: ',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'MiriamLibre',
                        ),
                      ),
                      TextSpan(
                        text: widget.wantedLocationAddress,
                        style: const TextStyle(
                          color: Color(0xFF03A295),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MiriamLibre',
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18), // Add a space of 10 pixels between lines
                const Text(
                  'Unfortunately, We didn\'t find available',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'MiriamLibre',
                  ),
                ),
                const SizedBox(height: 5), // Add a space of 10 pixels between lines
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'parking lots On ',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'MiriamLibre',
                        ),
                      ),
                      TextSpan(
                        text: widget.day,
                        style: const TextStyle(
                          color: Color(0xFF03A295),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MiriamLibre',
                          fontSize: 17,
                        ),
                      ),
                      const TextSpan(
                        text: ' at ',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'MiriamLibre',
                        ),
                      ),
                      TextSpan(
                        text: widget.timeOfDay,
                        style: const TextStyle(
                          color: Color(0xFF03A295),
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MiriamLibre',
                          fontSize: 17,
                        ),
                      ),
                      const TextSpan(
                        text: '.',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'MiriamLibre',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ])
            : // By default, show a loading spinner.
            (_isResultEmpty == false && lotsDict.isEmpty)
                ? SizedBox(
                    height: MediaQuery.of(context).size.height / 1.2,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 23, left: 30, right: 16),
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Address: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'MiriamLibre',
                                  ),
                                ),
                                TextSpan(
                                  text: widget.wantedLocationAddress,
                                  style: const TextStyle(
                                    color: Color(0xFF03A295),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 18,
                                    fontFamily: 'MiriamLibre',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 30, right: 16),
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Most likely to be available on ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'MiriamLibre',
                                  ),
                                ),
                                TextSpan(
                                  text: widget.day,
                                  style: const TextStyle(
                                    color: Color(0xFF03A295),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 18,
                                    fontFamily: 'MiriamLibre',
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' at ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'MiriamLibre',
                                  ),
                                ),
                                TextSpan(
                                  text: widget.timeOfDay,
                                  style: const TextStyle(
                                    color: Color(0xFF03A295),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'MiriamLibre',
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(
                                  text: ':',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'MiriamLibre',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Render ParkingLot lists
                        Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: lotsDict.keys.length,
                            itemBuilder: (BuildContext context, int index) {
                              List<ParkingLot> sortedList =
                                  lotsDict.keys.toList();
                              sortedList
                                  .sort((a, b) => a.availability != 0 ? 1 : 0);
                              var data = (sortedList)[index];
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Column(
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
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
                                              "${data.distance.toStringAsFixed(1)} KM Away",
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Row(children: [
                                                Expanded(
                                                  child: Directionality(
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4,
                                                              bottom: 3),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          data.lot_name,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 20),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                StreamBuilder(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection("favorites")
                                                        .where('uid',
                                                            isEqualTo: user.uid)
                                                        .where('parkingLot',
                                                            isEqualTo:
                                                                data.lot_id)
                                                        .snapshots(),
                                                    builder:
                                                        (BuildContext context,
                                                            AsyncSnapshot
                                                                snapshot) {
                                                      if (snapshot.data ==
                                                          null) {
                                                        return Text("");
                                                      }
                                                      return IconButton(
                                                          icon: snapshot
                                                                      .data
                                                                      .docs
                                                                      .length ==
                                                                  0
                                                              ? const Icon(
                                                                  Icons
                                                                      .star_border_outlined,
                                                                  color: Colors
                                                                      .black,
                                                                )
                                                              : const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .yellow,
                                                                ),
                                                          onPressed: () => snapshot
                                                                      .data
                                                                      .docs
                                                                      .length ==
                                                                  0
                                                              ? addToFavorites(
                                                                  user.uid,
                                                                  data.lot_id)
                                                              : removeFromFavorites(
                                                                  user.uid,
                                                                  data.lot_id));
                                                    }),
                                              ]),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 19),
                                                child: Text(
                                                  data.address,
                                                  style: const TextStyle(
                                                      textBaseline: TextBaseline
                                                          .ideographic),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 19),
                                                child: Text((() {
                                                  if (data.hourly_fare ==
                                                          true &&
                                                      data.fixed_price !=
                                                          null) {
                                                    return "תשלום שעתי וחד פעמי";
                                                  } else if (data.hourly_fare ==
                                                          true &&
                                                      data.fixed_price ==
                                                          null) {
                                                    return "תשלום שעתי בלבד";
                                                  } else if (data.hourly_fare !=
                                                          true &&
                                                      data.fixed_price !=
                                                          null) {
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
                                                    child: CircleAvatar(
                                                      radius: 15,
                                                      backgroundColor: lotsDict[
                                                                  data] ==
                                                              0
                                                          ? Colors.green
                                                          : lotsDict[data] ==
                                                                  0.7
                                                              ? Colors
                                                                  .orangeAccent
                                                              : Colors
                                                                  .deepOrange,
                                                      child: lotsDict[data] == 0
                                                          ? const Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white)
                                                          : const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 37,
                                                    top: 18,
                                                    child: Text(
                                                      lotsDict[data] == 0
                                                          ? 'Available'
                                                          : lotsDict[data] ==
                                                                  0.7
                                                              ? 'Almost Full'
                                                              : 'Full',
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'MiriamLibre',
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF626463),
                                                      ),
                                                    ),
                                                  ),
                                                  data.paying_method !=
                                                          ("בהתאם לשילוט במקום")
                                                      ? Positioned(
                                                          top: 9,
                                                          left: 145,
                                                          child: data
                                                                  .paying_method
                                                                  .contains(
                                                                      "מזומן")
                                                              ? Image.asset(
                                                                  'assets/images/cash_credit.png',
                                                                  height: 33,
                                                                  width: 33,
                                                                  fit: BoxFit
                                                                      .fitWidth,
                                                                )
                                                              : Image.asset(
                                                                  'assets/images/credit_only.png',
                                                                  height: 39,
                                                                  width: 39,
                                                                  fit: BoxFit
                                                                      .fitWidth,
                                                                ))
                                                      : const Center(),
                                                  Positioned(
                                                      top: 11,
                                                      left: 195,
                                                      child:
                                                          data.is_accessible ==
                                                                  true
                                                              ? Image.asset(
                                                                  'assets/images/disability.png',
                                                                  height: 29,
                                                                  width: 29,
                                                                  fit: BoxFit
                                                                      .fitWidth,
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
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 18,
                            bottom: 18,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ParkingLotsResultsScreen(
                                        wantedLocationAddress:
                                            widget.wantedLocationAddress,
                                        filterStatus: FilterParameters(
                                            false,
                                            false,
                                            false,
                                            false,
                                            false,
                                            false,
                                            false),
                                      ),
                                    ));
                                // Respond to button press
                              },
                              icon: Icon(Icons.commute, size: 18),
                              label: Text('More Lots In The Area'),
                            ),
                          ),
                        ),
                      ]),
      ),
    );
  }
}
