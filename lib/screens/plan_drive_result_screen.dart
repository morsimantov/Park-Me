import 'dart:async';
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
import 'dart:convert';
import '../env.sample.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'lot_details_screen.dart';
import '../utils.dart';
import '../config/strings.dart';

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
  static const String _appBarTitle = "Plan a Drive in Advance";
  static const String _textTitle = "Most likely to be available on ";
  static const String _atStr = " at ";
  static const String _moreLotsTextButton = "More Lots In The Area";
  static const String _addressStr = "Address: ";
  static const String _notFoundLots1 =
      "Unfortunately, We didn\'t find available";
  static const String _notFoundLots2 = "parking lots On ";
  static const double _fontSize = 16;
  static const double _fontSizeTitle = 17;

  Map<ParkingLot, num> _lotsDict = {};
  late double _wantedLocationLat = 0;
  late double _wantedLocationLong = 0;
  late bool _isResultEmpty = false;
  final user = FirebaseAuth.instance.currentUser!;

  final parkinglotListKey = GlobalKey<PlanDriveResultScreenState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getParkingLotList();
  }

  Future<void> getParkingLotList() async {
    print(widget.wantedLocationAddress);
    print(widget.timeOfDay);
    print(widget.day);
    // Send a GET request to retrieve parking lots based on location, day, and time
    final response = await http.get(Uri.parse(
        "${Env.URL_PREFIX}/closest5lots/${widget.wantedLocationAddress}"
            "/${widget.day}/${widget.timeOfDay}"));
    final decodedResponse = utf8.decode(response.bodyBytes);
    // Check if the response is empty
    if (decodedResponse == '[]') {
      setState(() {
        _isResultEmpty = true;
      });
      return;
    }
    // Decode the response and cast it to a list of Map<String, dynamic>
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
      _lotsDict[parkingLot] = status;
    }
    // Calculate the distances between the wanted location and the parking lots
    await getLotDistances();
  }

  Future<void> getLotDistances() async {
    double? distanceInMeter = 0.0;
    // Request location permission
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    // Retrieve the location coordinates for the wanted location address
    List<Location> locations =
    await locationFromAddress(widget.wantedLocationAddress);
    _wantedLocationLat = locations.first.latitude;
    _wantedLocationLong = locations.first.longitude;
    for (var parkingLotItem in _lotsDict.keys) {
      final address = parkingLotItem.address;
      // Get the location coordinates for the parking lot address
      List<Location> locations = await locationFromAddress(address);
      Location lotLocation = locations.first;
      double parkingLotLat = lotLocation.latitude;
      double parkingLotLng = lotLocation.longitude;
      // Calculate the distance between the wanted location and the parking lot
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
        selectedItemColor: const Color(0xff67686b),
        onTap: onItemTapped,
      ),
      body: SingleChildScrollView(
        child: (_isResultEmpty)
            ? Column(children: [
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
                              text: _addressStr,
                              style: TextStyle(
                                fontSize: _fontSizeTitle,
                                fontFamily: fontFamilyMiriam,
                              ),
                            ),
                            TextSpan(
                              text: widget.wantedLocationAddress,
                              style: const TextStyle(
                                color: Color(0xFF03A295),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamilyMiriam,
                                fontSize: _fontSizeTitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Add a space of 10 pixels between lines
                      const Text(
                        _notFoundLots1,
                        style: TextStyle(
                          fontSize: _fontSizeTitle,
                          fontFamily: fontFamilyMiriam,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Add a space of 10 pixels between lines
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(
                              text: _notFoundLots2,
                              style: TextStyle(
                                fontSize: _fontSizeTitle,
                                fontFamily: fontFamilyMiriam,
                              ),
                            ),
                            TextSpan(
                              text: widget.day,
                              style: const TextStyle(
                                color: Color(0xFF03A295),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamilyMiriam,
                                fontSize: _fontSizeTitle,
                              ),
                            ),
                            const TextSpan(
                              text: _atStr,
                              style: TextStyle(
                                fontSize: _fontSizeTitle,
                                fontFamily: fontFamilyMiriam,
                              ),
                            ),
                            TextSpan(
                              text: widget.timeOfDay,
                              style: const TextStyle(
                                color: Color(0xFF03A295),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamilyMiriam,
                                fontSize: _fontSizeTitle,
                              ),
                            ),
                            const TextSpan(
                              text: '.',
                              style: TextStyle(
                                fontSize: _fontSizeTitle,
                                fontFamily: fontFamilyMiriam,
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
            (_isResultEmpty == false && _lotsDict.isEmpty)
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
                                  text: _addressStr,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    fontFamily: fontFamilyMiriam,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.wantedLocationAddress,
                                  style: const TextStyle(
                                    color: Color(0xFF03A295),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 18,
                                    fontFamily: fontFamilyMiriam,
                                    fontSize: _fontSize,
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
                                  text: _textTitle,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    fontFamily: fontFamilyMiriam,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.day,
                                  style: const TextStyle(
                                    color: Color(0xFF03A295),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 18,
                                    fontFamily: fontFamilyMiriam,
                                    fontSize: _fontSize,
                                  ),
                                ),
                                const TextSpan(
                                  text: _atStr,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    fontFamily: fontFamilyMiriam,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.timeOfDay,
                                  style: const TextStyle(
                                    color: Color(0xFF03A295),
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamilyMiriam,
                                    fontSize: _fontSize,
                                  ),
                                ),
                                const TextSpan(
                                  text: ':',
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    fontFamily: fontFamilyMiriam,
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
                            itemCount: _lotsDict.keys.length,
                            itemBuilder: (BuildContext context, int index) {
                              List<ParkingLot> sortedList =
                                  _lotsDict.keys.toList();
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
                                                fontFamily: fontFamilyMiriam,
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
                                                        return const Text("");
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
                                                    return fixedAnHourlyPrice;
                                                  } else if (data.hourly_fare ==
                                                          true &&
                                                      data.fixed_price ==
                                                          null) {
                                                    return hourlyPrice;
                                                  } else if (data.hourly_fare !=
                                                          true &&
                                                      data.fixed_price !=
                                                          null) {
                                                    return fixedPrice;
                                                  }
                                                  return unknownPaying;
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
                                                      backgroundColor: _lotsDict[
                                                                  data] ==
                                                              0
                                                          ? Colors.green
                                                          : _lotsDict[data] ==
                                                                  0.7
                                                              ? Colors
                                                                  .orangeAccent
                                                              : Colors
                                                                  .deepOrange,
                                                      child: _lotsDict[data] ==
                                                              0
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
                                                      _lotsDict[data] == 0
                                                          ? availableStr
                                                          : _lotsDict[data] ==
                                                                  0.7
                                                              ? almostFullStr
                                                              : fullStr,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            fontFamilyMiriam,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF626463),
                                                      ),
                                                    ),
                                                  ),
                                                  data.paying_method !=
                                                          (unknownPayingMethod)
                                                      ? Positioned(
                                                          top: 9,
                                                          left: 145,
                                                          child: data
                                                                  .paying_method
                                                                  .contains(
                                                                      cash)
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
                              icon: const Icon(Icons.commute, size: 18),
                              label: const Text(_moreLotsTextButton),
                            ),
                          ),
                        ),
                      ]),
      ),
    );
  }
}
