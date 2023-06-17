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

class PlanLotResultScreen extends StatefulWidget {
  final String wantedLotName;
  final int wantedLotId;
  final String day;
  final String timeOfDay;

  const PlanLotResultScreen({
    super.key,
    required this.wantedLotName,
    required this.day,
    required this.timeOfDay,
    required this.wantedLotId,
  });

  @override
  PlanLotResultScreenState createState() => PlanLotResultScreenState();
}

class PlanLotResultScreenState extends State<PlanLotResultScreen> {
  static const String _appBarTitle = "Plan a Drive in Advance";
  static const String _textTitle = " is most likely to be: ";
  static const String _onStr = "On ";
  static const String _atStr = " at ";
  static const String _moreLotsTextButton = "More Lots In The Area";
  static const double _fontSize = 16;

  Position? _currentUserPosition;
  late double _prediction = -1;
  late bool _isResultEmpty = false;
  late ParkingLot _parkingLot;
  int _selectedIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;
  final parkinglotListKey = GlobalKey<PlanLotResultScreenState>();

  @override
  void initState() {
    super.initState();
    // Initialize parking lot instance to default values
    _parkingLot = ParkingLot(
        lot_id: 0,
        lot_name: "",
        address: "",
        opening_hours: "",
        fare: "",
        is_accessible: true,
        paying_method: "",
        image: "",
        distance: 0);
    getParkingLotPrediction();
    getParkingLotDetails();
  }

  Future<void> getParkingLotPrediction() async {
    print(widget.wantedLotName);
    print(widget.timeOfDay);
    print(widget.day);
    // Send a GET request to retrieve the parking lot prediction
    final response = await http.get(Uri.parse(
        "${Env.URL_PREFIX}/lotprediction/${widget.wantedLotName}/${widget.day}/${widget.timeOfDay}"
    ));
    // Decode the response
    final decodedResponse = utf8.decode(response.bodyBytes);
    // Parse the prediction to double variable
    _prediction = double.parse(decodedResponse);
    print(_prediction);
  }

  Future<void> getParkingLotDetails() async {
    final int lot_id = widget.wantedLotId;
    // Send a GET request to retrieve the parking lot details
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/lots/$lot_id"));
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    // Convert the JSON response to a list of ParkingLot objects
    List<ParkingLot> parkingLotTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    // Set the state with the retrieved parking lot
    setState(() {
      _parkingLot = parkingLotTemp.first;
    });
    // Calculate the distance to the parking lot
    await getLotDistance();
  }

  Future getLotDistance() async {
    double? distanceInMeter = 0.0;
    // Request location permission
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    // Retrieve the location coordinates for the current user address
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double currentPositionLat = _currentUserPosition!.latitude;
    double currentPositionLong = _currentUserPosition!.longitude;
    // Get the location coordinates for the parking lot address
    List<Location> locations = await locationFromAddress(_parkingLot.address);
    double wantedLotLat = locations.first.latitude;
    double wantedLotLong = locations.first.longitude;
    // Calculate the distance between the current location and the parking lot
    distanceInMeter = Geolocator.distanceBetween(
      currentPositionLat,
      currentPositionLong,
      wantedLotLat,
      wantedLotLong,
    );
    // Convert the distance from meters to kilometers
    var distance = distanceInMeter?.round().toInt();
    // Update the distance the parking lot
    _parkingLot.distance = (distance! / 1000);
    setState(() {});
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
      body: // By default, show a loading spinner.
          (_parkingLot.lot_id == 0 && _prediction == -1)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 23, left: 30, right: 16),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: widget.wantedLotName,
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
                            text: _textTitle,
                            style: TextStyle(
                              fontSize: _fontSize,
                              fontFamily: fontFamilyMiriam,
                            ),
                          ),
                          TextSpan(
                            text: _prediction == 0
                                ? availableStr
                                : _prediction == 0.7
                                    ? almostFullStr
                                    : fullStr,
                            style: TextStyle(
                              color: _prediction == 0
                                  ? Color(0xFF03A295)
                                  : _prediction == 0.7
                                      ? Colors.orangeAccent
                                      : Colors.deepOrange,
                              // fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              // fontSize: 18,
                              fontFamily: fontFamilyMiriam,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 30, right: 16),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(
                            text: _onStr,
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
                            text: '.',
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
                  (_isResultEmpty)
                      ? const Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              noLotsAvailable,
                              style: TextStyle(
                                fontFamily: fontFamilyMiriam,
                                fontSize: 17,
                                color: Color(0xFF626463),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LotDetailsScreen(
                                    lotId: _parkingLot.lot_id,
                                    distance: _parkingLot.distance,
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
                                                _parkingLot.image,
                                                fit: BoxFit.cover,
                                                width: 90,
                                                height: 70,
                                              ),
                                            )),
                                        const SizedBox(height: 10),
                                        Text(
                                          "${_parkingLot.distance.toStringAsFixed(1)} KM Away",
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
                                                          top: 4, bottom: 3),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      _parkingLot.lot_name,
                                                      style: const TextStyle(
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
                                                        _parkingLot.lot_id)
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
                                                              color:
                                                                  Colors.black,
                                                            )
                                                          : const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.yellow,
                                                            ),
                                                      onPressed: () => snapshot
                                                                  .data
                                                                  .docs
                                                                  .length ==
                                                              0
                                                          ? addToFavorites(
                                                              user.uid,
                                                          _parkingLot.lot_id)
                                                          : removeFromFavorites(
                                                              user.uid,
                                                          _parkingLot
                                                                  .lot_id));
                                                }),
                                          ]),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 19),
                                            child: Text(
                                              _parkingLot.address,
                                              style: const TextStyle(
                                                  textBaseline:
                                                      TextBaseline.ideographic),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 19),
                                            child: Text((() {
                                              if (_parkingLot.hourly_fare ==
                                                      true &&
                                                  _parkingLot.fixed_price !=
                                                      null) {
                                                return fixedAnHourlyPrice;
                                              } else if (_parkingLot
                                                          .hourly_fare ==
                                                      true &&
                                                  _parkingLot.fixed_price ==
                                                      null) {
                                                return hourlyPrice;
                                              } else if (_parkingLot
                                                          .hourly_fare !=
                                                      true &&
                                                  _parkingLot.fixed_price !=
                                                      null) {
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
                                                child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      _prediction == 0
                                                          ? Colors.green
                                                          : _prediction == 0.7
                                                              ? Colors
                                                                  .orangeAccent
                                                              : Colors
                                                                  .deepOrange,
                                                  child: _prediction == 0
                                                      ? const Icon(Icons.check,
                                                          color: Colors.white)
                                                      : const Icon(Icons.close,
                                                          color: Colors.white),
                                                ),
                                              ),
                                              Positioned(
                                                left: 37,
                                                top: 18,
                                                child: Text(
                                                  _prediction == 0
                                                      ? availableStr
                                                      : _prediction == 0.7
                                                          ? almostFullStr
                                                          : fullStr,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        fontFamilyMiriam,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF626463),
                                                  ),
                                                ),
                                              ),
                                              _parkingLot.paying_method !=
                                                      (unknownPayingMethod)
                                                  ? Positioned(
                                                      top: 9,
                                                      left: 145,
                                                      child: _parkingLot
                                                              .paying_method
                                                              .contains(cash)
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
                                                  child: _parkingLot
                                                              .is_accessible ==
                                                          true
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
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ParkingLotsResultsScreen(
                                  wantedLocationAddress: _parkingLot.address,
                                  filterStatus: FilterParameters(false, false,
                                      false, false, false, false, false),
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
    );
  }
}
