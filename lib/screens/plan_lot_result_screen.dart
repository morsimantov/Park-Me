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

class PlanLotResultScreen extends StatefulWidget {
  final String wantedLotName;
  final int wantedLotId;
  final String day;
  final String timeOfDay;


  const PlanLotResultScreen({
    super.key, required this.wantedLotName, required this.day, required this.timeOfDay, required this.wantedLotId,
  });

  @override
  PlanLotResultScreenState createState() => PlanLotResultScreenState();
}

class PlanLotResultScreenState extends State<PlanLotResultScreen> {
  Position? _currentUserPosition;
  late double wantedLocationLat;
  late double prediction = -1;
  late double wantedLocationLong;
  final user = FirebaseAuth.instance.currentUser!;
  late bool _isResultEmpty = false;
  late ParkingLot parkingLot;
  double? distanceInMeter = 0.0;

  final parkinglotListKey = GlobalKey<PlanLotResultScreenState>();
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
                filterStatus: FilterParameters(false, false, false, false, false, false, false),
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
    parkingLot = ParkingLot(
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

    final id = user.uid;
    print(id);
    final response =
    await http.get(Uri.parse("${Env.URL_PREFIX}/lotprediction/${widget.wantedLotName}"
        "/${widget.day}/${widget.timeOfDay}"));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    print(decodedResponse);
    prediction = double.parse(decodedResponse);
    print(prediction);
  }

  Future<void> getParkingLotDetails() async {
    final int lot_id = widget.wantedLotId;
    final response =
    await http.get(Uri.parse("${Env.URL_PREFIX}/lots/$lot_id"));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    List<ParkingLot> parkingLotTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    setState(() {
      parkingLot = parkingLotTemp.first;
    });
    await _getTheDistance();
  }

  Future _getTheDistance() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    _currentUserPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    double currentPositionLat = _currentUserPosition!.latitude;
    double currentPositionLong = _currentUserPosition!.longitude;
    List<Location> locations = await locationFromAddress(parkingLot.address);
    double wantedLotLat = locations.first.latitude;
    double wantedLotLong = locations.first.longitude;
    distanceInMeter = Geolocator.distanceBetween(
      currentPositionLat, currentPositionLong, wantedLotLat, wantedLotLong,);
    var distance = distanceInMeter?.round().toInt();
    parkingLot.distance = (distance! / 1000);
    setState(() {});
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
      body: // By default, show a loading spinner.
      (parkingLot.lot_id == 0 && prediction == -1)
          ? const Center(
        child: CircularProgressIndicator(),
      ) :
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 23, left: 30, right: 16),
              child: RichText(
                text:
                TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: widget.wantedLotName,
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
                      text: ' is most likely to be: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'MiriamLibre',
                      ),
                    ),
                    TextSpan(
                      text: prediction == 0 ? 'Available' : prediction == 0.7 ? 'Almost Full' : 'Full',
                      style: TextStyle(
                        color: prediction == 0 ? Color(0xFF03A295) : prediction == 0.7 ? Colors.orangeAccent : Colors.deepOrange,
                        // fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        // fontSize: 18,
                        fontFamily: 'MiriamLibre',
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),),
            Padding(
            padding: const EdgeInsets.only(top: 16, left: 30, right: 16),
            child: RichText(
              text:
              TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(
                    text: 'On ',
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
                    text: ' at ',  style: TextStyle(
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
                    text: '.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'MiriamLibre',
                    ),
                  ),
                ],
              ),
            ),),
            const SizedBox(height: 8),

            (_isResultEmpty) ?

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

             Padding(
              padding: const EdgeInsets.only(top: 9),
              child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LotDetailsScreen(
                            lotId: parkingLot.lot_id,
                            distance: parkingLot.distance,
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
                                        parkingLot.image,
                                        fit: BoxFit.cover,
                                        width: 90,
                                        height: 70,
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                Text(
                                  "${parkingLot.distance.toStringAsFixed(1)} KM Away",
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
                                              parkingLot.lot_name,
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
                                            isEqualTo: parkingLot.lot_id)
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
                                                  user.uid, parkingLot.lot_id)
                                                  : removeFromFavorites(
                                                  user.uid,
                                                  parkingLot.lot_id));
                                        }),
                                  ]),
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(right: 19),
                                    child: Text(
                                      parkingLot.address,
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
                                      if (parkingLot.hourly_fare == true &&
                                          parkingLot.fixed_price != null) {
                                        return "תשלום שעתי וחד פעמי";
                                      } else if (parkingLot.hourly_fare == true &&
                                          parkingLot.fixed_price == null) {
                                        return "תשלום שעתי בלבד";
                                      } else if (parkingLot.hourly_fare != true &&
                                          parkingLot.fixed_price != null) {
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
                                        child:  CircleAvatar(
                                          radius: 15,
                                          backgroundColor:
                                          prediction == 0 ? Colors.green : prediction == 0.7 ? Colors.orangeAccent : Colors.deepOrange,
                                          child: prediction == 0 ? const Icon(
                                              Icons.check,
                                              color: Colors
                                                  .white) : const Icon(
                                              Icons.close,
                                              color: Colors
                                                  .white),
                                        ),),
                                      Positioned(
                                        left: 37,
                                        top: 18,
                                        child: Text(
                                          prediction == 0 ? 'Available' : prediction == 0.7 ? 'Almost Full' : 'Full',
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
                                      ),
                                      parkingLot.paying_method !=
                                          ("בהתאם לשילוט במקום")
                                          ? Positioned(
                                          top: 9,
                                          left: 145,
                                          child: parkingLot.paying_method
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
                                          child: parkingLot.is_accessible == true
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
                            wantedLocationAddress: parkingLot.address,
                            filterStatus: FilterParameters(false, false, false, false, false, false, false),
                          ),
                        ));
                    // Respond to button press
                  },
                  icon: Icon(Icons.commute, size: 18),
                  label: Text('More Lots In The Area'),
                ),
              ),),
          ]),
    );
  }
}
