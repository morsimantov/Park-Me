import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:park_me/model/filter_parameters.dart';
import 'package:park_me/model/parking_lot.dart';
import 'package:park_me/screens/lot_details_screen.dart';
import 'package:park_me/screens/search_screen.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../env.sample.dart';
import 'favorites_screen.dart';
import 'filter_screen.dart';
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
  late List<ParkingLot> parkingLots = [];
  late List<ParkingLot> parkingLotsOrigin;
  late List<ParkingLot> parkingLotsFiltered = [];
  Position? _currentUserPosition;
  late String _clickedLast = " ";
  late double wantedLocationLat;
  late double wantedLocationLong;
  bool _isParkingLotsEmpty = false;

  double? distanceInMeter = 0.0;

  final parkinglotListKey = GlobalKey<ParkingLotsResultsScreenState>();
  int _selectedIndex = 0;
  late FilterParameters filterStatus = widget.filterStatus;
  late Color _availabilityButtonColor;
  late Color _availabilityTextColor;
  late Color _distanceButtonColor;
  late Color _distanceTextColor;
  late Color _accessibilityButtonColor;
  late Color _accessibilityTextColor;
  late Color _undergroundButtonColor;
  late Color _undergroundTextColor;
  late Color _priceButtonColor;
  late Color _priceTextColor;
  late Color _discountButtonColor;
  late Color _discountTextColor;

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
    parkingLotsOrigin = [];
    getParkingLotList();
    _availabilityButtonColor = filterStatus.availability
        ? const Color(0xFF55C0B3)
        : const Color(0xfff6f7f9);
    _availabilityTextColor =
        filterStatus.availability ? Colors.white : Colors.teal;
    _distanceButtonColor = filterStatus.distance
        ? const Color(0xFF55C0B3)
        : const Color(0xfff6f7f9);
    _distanceTextColor = filterStatus.distance ? Colors.white : Colors.teal;
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
    _discountButtonColor = filterStatus.discount
        ? const Color(0xFF55C0B3)
        : const Color(0xfff6f7f9);
    _discountTextColor =
    filterStatus.discount ? Colors.white : Colors.teal;
  }

  Future<void> getParkingLotList() async {
    final response = await http.get(Uri.parse(Env.URL_PREFIX));
    // final response =
    // await http.get(Uri.parse("${Env.URL_PREFIX}/lots"));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    setState(() {
      parkingLotsOrigin.addAll(parkingLotsTemp);
    });
    print("number of parking lots: ${parkingLotsOrigin.length}");
    await _getTheDistance();
    parkingLotsOrigin.sort((a, b) => a.distance.compareTo(b.distance));
    parkingLotsOrigin = parkingLotsOrigin.take(20).toList();
    parkingLotsFiltered = List.of(parkingLotsOrigin);
    parkingLots = List.of(parkingLotsOrigin);
    orderParkingLotList();
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
    // print(wantedLocationLat);
    for (var parkingLotItem in parkingLotsOrigin) {
      final address = parkingLotItem.address;
      List<Location> locations = await locationFromAddress(address);
      Location lotLocation = locations.first;
      double parkingLotLat = lotLocation.latitude;
      double parkingLotLng = lotLocation.longitude;
      // print(parkingLotItem.lot_name);
      // print(parkingLotLat);
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
    _isParkingLotsEmpty = false;
    parkingLotsFiltered = List.of(parkingLots);
    List<ParkingLot> toRemove = [];
    parkingLotsFiltered.sort((a, b) => a.distance.compareTo(b.distance));
    orderByDistance();
    orderByDiscount();
    orderByFixedPrice(toRemove);
    orderByPayingMethod(toRemove);
    orderByPrice(toRemove);
    orderByUnderground(toRemove);
    orderByFixedPrice(toRemove);
    orderByWalkingDistance(toRemove);
    orderByAccessibility();
    orderByAvailability();
    parkingLotsFiltered.removeWhere((lot) => toRemove.contains(lot));
    switch (_clickedLast) {
      case 'availability':
        orderByAvailability();
        break;
      case 'accessibility':
        orderByAccessibility();
        break;
      case 'distance':
        orderByDistance();
        break;
      case 'discount':
        orderByDiscount();
        break;
      case 'fixed price':
        orderByFixedPrice(toRemove);
        break;
      case 'underground':
        orderByUnderground(toRemove);
        break;
      default:
        break;
    }
    parkingLots = List.of(parkingLotsFiltered);
    if (parkingLots.isEmpty) {
      _isParkingLotsEmpty = true;
    }
    setState(() {});
  }


  void orderByAvailability() {
    if (filterStatus.availability) {
      parkingLotsFiltered.sort((a, b) => (a.availability ?? 0.8).compareTo(b.availability ?? 0.8));
    }
  }

  void orderByAccessibility() {
    if (filterStatus.accessibility) {
      parkingLotsFiltered.sort((a, b) => a.is_accessible != true ? 1 : 0);
    }
  }

  void orderByDistance() {
    if (filterStatus.distance) {
      parkingLotsFiltered.sort((a, b) => a.distance.compareTo(b.distance));
    }
  }


  void orderByWalkingDistance(List<ParkingLot> toRemove) {
    if (filterStatus.walkingDistance != null) {
      double distanceInKm = convertToKilometers(filterStatus.walkingDistance!);
      for (var parkingLot in parkingLotsFiltered) {
        if (parkingLot.distance > distanceInKm) {
          toRemove.add(parkingLot);
        }
      }
      parkingLotsFiltered.sort((a, b) => a.distance.compareTo(b.distance));
    }
  }
  void orderByUnderground(List<ParkingLot> toRemove) {
    if (filterStatus.isUnderground) {
      parkingLotsFiltered.sort((a, b) => a.is_underground != true ? 1 : 0);
      // for (var parkingLot in parkingLotsFiltered) {
      //   if (parkingLot.is_underground != null &&
      //       parkingLot.is_underground == false) {
      //     toRemove.add(parkingLot);
      //   }
      // }
    }
  }

  void orderByPrice(List<ParkingLot> toRemove) {
    if (filterStatus.price != null) {
      for (var parkingLot in parkingLotsFiltered) {
        if (parkingLot.fixed_price != null) {
          if (parkingLot.fixed_price!.toDouble() > filterStatus.price!) {
            toRemove.add(parkingLot);
          }
        }
        if (parkingLot.hourly_fare != null) {
          if (filterStatus.price! < 16) {
            toRemove.add(parkingLot);
          }
        }
      }
      parkingLotsFiltered.sort((a, b) => a.hourly_fare != true ? 0 : 1);
      parkingLotsFiltered.sort(
              (a, b) => (a.fixed_price ?? 100).compareTo(b.fixed_price ?? 100));
    }
  }
  void orderByFixedPrice(List<ParkingLot> toRemove) {
    if (filterStatus.fixedPrice) {
      for (var parkingLot in parkingLotsFiltered) {
        if (parkingLot.fixed_price == null) {
          toRemove.add(parkingLot);
        }
      }
      parkingLotsFiltered.sort((a, b) => a.hourly_fare != true ? 0 : 1);
      parkingLotsFiltered.sort((a, b) => a.fixed_price == null ? 1 : 0);
    }
  }
  void orderByDiscount() {
    if (filterStatus.discount) {
      parkingLotsFiltered.sort((a, b) => a.resident_discount == null ? 1 : 0);
    }
  }

  void orderByPayingMethod(List<ParkingLot> toRemove) {
    // if the user marked only payment by cash
    if (filterStatus.cash && !filterStatus.credit && !filterStatus.pango) {
      for (var parkingLot in parkingLotsFiltered) {
        if (parkingLot.paying_method == "אשראי ואמצעים דיגיטליים בלבד") {
          toRemove.add(parkingLot);
        }
      }
      parkingLotsFiltered.sort(
              (a, b) =>  a.paying_method == "מזומן + אשראי (חניון ממוכן)" ? 1 : 0);
      parkingLotsFiltered.sort((a, b) => a.paying_method == "מזומן" ? 0 : 1);
    }
    // if the user marked payment by both credit and cash
    else if (filterStatus.cash && filterStatus.credit) {
      parkingLotsFiltered.sort(
              (a, b) => a.paying_method == "בהתאם לשילוט במקום" ? 0 : 1);
      parkingLotsFiltered.sort(
              (a, b) => a.paying_method == "מזומן + אשראי (חניון ממוכן)" ? 0 : 1);
      // if the user marked only payment by credit or by pango
    } else if ((!filterStatus.cash && filterStatus.credit) || (!filterStatus.cash && filterStatus.pango)) {
      for (var parkingLot in parkingLotsFiltered) {
        if (parkingLot.paying_method == "מזומן") {
          toRemove.add(parkingLot);
        }
      }
      parkingLotsFiltered.sort(
              (a, b) => a.paying_method == "מזומן + אשראי (חניון ממוכן)" ? 1 : 0);
      parkingLotsFiltered.sort(
              (a, b) => a.paying_method == "אשראי ואמצעים דיגיטליים בלבד" ? 0 : 1);
    }
  }

  double convertToKilometers(double timeInMinutes) {
    double walkingSpeed = 5.0; // 5 km/h is an average walking speed
    double timeInHours = timeInMinutes / 60;
    double distanceInKm = walkingSpeed * timeInHours;
    return distanceInKm;
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
        selectedItemColor: const Color(0xff67686b),
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 1),
                    child: IconButton(
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
                                      widget.wantedLocationAddress,
                                  filterStatus: widget.filterStatus,
                                ),
                              ));
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        if (_availabilityButtonColor ==
                            const Color(0xfff6f7f9)) {
                          setState(() {
                            _availabilityButtonColor = const Color(0xFF55C0B3);
                            _availabilityTextColor = Colors.white;
                            filterStatus.availability = true;
                            _clickedLast = "availability";
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _availabilityButtonColor = const Color(0xfff6f7f9);
                            _availabilityTextColor = Colors.teal;
                            filterStatus.availability = false;
                            parkingLots = List.of(parkingLotsOrigin);
                          });
                          orderParkingLotList();
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 7.0, horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        if (_distanceButtonColor == const Color(0xfff6f7f9)) {
                          setState(() {
                            _distanceButtonColor = const Color(0xFF55C0B3);
                            _distanceTextColor = Colors.white;
                            filterStatus.distance = true;
                            _clickedLast = "distance";
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _distanceButtonColor = const Color(0xfff6f7f9);
                            _distanceTextColor = Colors.teal;
                            filterStatus.distance = false;
                            parkingLots = List.of(parkingLotsOrigin);
                          });
                          orderParkingLotList();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _distanceButtonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Distance',
                        style: TextStyle(
                          color: _distanceTextColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        if (_undergroundButtonColor ==
                            const Color(0xfff6f7f9)) {
                          setState(() {
                            _undergroundButtonColor = const Color(0xFF55C0B3);
                            _undergroundTextColor = Colors.white;
                            filterStatus.isUnderground = true;
                            _clickedLast = "underground";
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _undergroundButtonColor = const Color(0xfff6f7f9);
                            _undergroundTextColor = Colors.teal;
                            filterStatus.isUnderground = false;
                            parkingLots = List.of(parkingLotsOrigin);
                          });
                          orderParkingLotList();
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        if (_discountButtonColor ==
                            const Color(0xfff6f7f9)) {
                          setState(() {
                            _discountButtonColor = const Color(0xFF55C0B3);
                            _discountTextColor = Colors.white;
                            filterStatus.discount = true;
                            _clickedLast = "discount";
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _discountButtonColor = const Color(0xfff6f7f9);
                            _discountTextColor = Colors.teal;
                            filterStatus.discount = false;
                            parkingLots = List.of(parkingLotsOrigin);
                          });
                          orderParkingLotList();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _discountButtonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Resident Discount',
                        style: TextStyle(
                            color: _discountTextColor,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        if (_priceButtonColor == const Color(0xfff6f7f9)) {
                          setState(() {
                            _priceButtonColor = const Color(0xFF55C0B3);
                            _priceTextColor = Colors.white;
                            filterStatus.fixedPrice = true;
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _priceButtonColor = const Color(0xfff6f7f9);
                            _priceTextColor = Colors.teal;
                            filterStatus.fixedPrice = false;
                          });
                          parkingLots = List.of(parkingLotsOrigin);
                          orderParkingLotList();
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
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        if (_accessibilityButtonColor ==
                            const Color(0xfff6f7f9)) {
                          setState(() {
                            _accessibilityButtonColor = const Color(0xFF55C0B3);
                            _accessibilityTextColor = Colors.white;
                            filterStatus.accessibility = true;
                            parkingLots = List.of(parkingLotsOrigin);
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _accessibilityButtonColor = const Color(0xfff6f7f9);
                            _accessibilityTextColor = Colors.teal;
                            filterStatus.accessibility = false;
                          });
                          orderParkingLotList();
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
                ])),
          ),
          Center(
            child:
                // By default, show a loading spinner.
                (parkingLotsOrigin.isEmpty)
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : (_isParkingLotsEmpty)
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 19),
                              child: Text(
                                "No parking lots available",
                                style: TextStyle(
                                  fontFamily: 'MiriamLibre',
                                  fontSize: 17,
                                  color: Color(0xFF626463),
                                ),
                              ),
                            ),
                          ) : (parkingLots.isEmpty)
                    ? SizedBox(
                  height: MediaQuery.of(context).size.height / 1.4,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                        // Render ParkingLot lists
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
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
                                                          child: (data
                                                              .paying_method == "מזומן + אשראי (חניון ממוכן)")
                                                              ? Image.asset(
                                                                  'assets/images/cash_credit.png',
                                                                  height: 34,
                                                                  width: 34,
                                                                  fit: BoxFit
                                                                      .fitWidth,
                                                                ) : (data
                                                              .paying_method == "מזומן") ?
                                                          Image.asset(
                                                            'assets/images/cash.png',
                                                            height: 32,
                                                            width: 32,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ) : Image.asset(
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
                                                      child: data.is_accessible == true
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
        ],
      ),
    );
  }
}
