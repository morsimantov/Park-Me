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
import 'dart:convert';
import '../env.sample.dart';
import 'favorites_screen.dart';
import 'filter_screen.dart';
import 'home_screen.dart';
import '../utils.dart';
import '../config/strings.dart';
import '../config/colors.dart';

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
  static const String _appBarTitle = "Find a Parking spot";
  static const String _currentLocationStr = "Current Location";
  static const double _fontSize = 15;
  static const double _fontSizeTitle = 20;

  int _selectedIndex = 0;
  late List<ParkingLot> _parkingLots = [];
  late List<ParkingLot> _parkingLotsOrigin = [];
  late List<ParkingLot> _parkingLotsFiltered = [];
  Position? _currentUserPosition;
  late String _clickedLast = " ";
  late double _wantedLocationLat;
  late double _wantedLocationLong;
  bool _isParkingLotsEmpty = false;

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

  final parkinglotListKey = GlobalKey<ParkingLotsResultsScreenState>();
  late FilterParameters filterStatus = widget.filterStatus;
  List<Function> orderByFunctions = [];
  List<Function> filterByFunctions = [];

  void initOrderFunctions() {
    orderByFunctions.addAll([
          orderByDistance,
          orderByDiscount,
          orderByUnderground,
          orderByAccessibility,
          orderByAvailability,
    ]);
    filterByFunctions.addAll([
          (List<ParkingLot> toRemove) => filterByFixedPrice(toRemove),
          (List<ParkingLot> toRemove) => filterByPayingMethod(toRemove),
          (List<ParkingLot> toRemove) => filterByPrice(toRemove),
          (List<ParkingLot> toRemove) => filterByWalkingDistance(toRemove),
    ]);
  }

  @override
  void initState() {
    super.initState();
    // Initialize order and filter functions lists
    initOrderFunctions();
    // Get parking lots list
    getParkingLotList();
    // Set initial button colors according to the filter status
    _availabilityButtonColor =
        filterStatus.availability ? pressedButtonColor : unpressedButtonColor2;
    _availabilityTextColor =
        filterStatus.availability ? Colors.white : Colors.teal;
    _distanceButtonColor =
        filterStatus.distance ? pressedButtonColor : unpressedButtonColor2;
    _distanceTextColor = filterStatus.distance ? Colors.white : Colors.teal;
    _undergroundButtonColor =
        filterStatus.isUnderground ? pressedButtonColor : unpressedButtonColor2;
    _undergroundTextColor =
        filterStatus.isUnderground ? Colors.white : Colors.teal;
    _accessibilityButtonColor =
        filterStatus.accessibility ? pressedButtonColor : unpressedButtonColor2;
    _accessibilityTextColor =
        filterStatus.accessibility ? Colors.white : Colors.teal;
    _priceButtonColor =
        filterStatus.fixedPrice ? pressedButtonColor : unpressedButtonColor2;
    _priceTextColor = filterStatus.fixedPrice ? Colors.white : Colors.teal;
    _discountButtonColor =
        filterStatus.discount ? pressedButtonColor : unpressedButtonColor2;
    _discountTextColor = filterStatus.discount ? Colors.white : Colors.teal;
  }

  Future<void> getParkingLotList() async {
    final response = await http.get(Uri.parse(Env.URL_PREFIX));
    // Decode the response from bytes to String
    final decodedResponse = utf8.decode(response.bodyBytes);
    // Convert the decoded response into a list of maps
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    // Convert each map item into a ParkingLot object and create a list of ParkingLot objects
    List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    // Update the state with the new parking lots
    setState(() {
      _parkingLotsOrigin.addAll(parkingLotsTemp);
    });
    // Get distances for each parking lot
    await getLotDistances();
    // Sort the parking lots by distance
    _parkingLotsOrigin.sort((a, b) => a.distance.compareTo(b.distance));
    // Take the first 20 parking lots
    _parkingLotsOrigin = _parkingLotsOrigin.take(20).toList();
    // Create a list that will contain the lots after being filtered
    _parkingLotsFiltered = List.of(_parkingLotsOrigin);
    // Create a list that will contain the lots that will be presented to the user
    _parkingLots = List.of(_parkingLotsOrigin);
    // Order the parking lot list
    orderParkingLotList();
  }

  Future getLotDistances() async {
    double? distanceInMeter = 0.0;
    LocationPermission permission;
    // Request permission for location access
    permission = await Geolocator.requestPermission();
    // Get current location coordinates or coordinates for the wanted location address
    if (widget.wantedLocationAddress == _currentLocationStr) {
      _currentUserPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _wantedLocationLat = _currentUserPosition!.latitude;
      _wantedLocationLong = _currentUserPosition!.longitude;
    } else {
      List<Location> locations = await locationFromAddress(widget.wantedLocationAddress);
      _wantedLocationLat = locations.first.latitude;
      _wantedLocationLong = locations.first.longitude;
    }
    // Calculate distance for each parking lot
    for (var parkingLotItem in _parkingLotsOrigin) {
      final address = parkingLotItem.address;
      List<Location> locations = await locationFromAddress(address);
      Location lotLocation = locations.first;
      double parkingLotLat = lotLocation.latitude;
      double parkingLotLng = lotLocation.longitude;
      // Calculate the distance between the wanted location and parking lot
      distanceInMeter = await Geolocator.distanceBetween(
        _wantedLocationLat,
        _wantedLocationLong,
        parkingLotLat,
        parkingLotLng,
      );
      // Round the distance and update the parking lot's distance value
      var distance = distanceInMeter?.round().toInt();
      parkingLotItem.distance = (distance! / 1000);
      // Update the state to reflect the new distance value
      setState(() {});
    }
  }

  void orderParkingLotList() {
    _isParkingLotsEmpty = false;
    // Save the list of lots in a list that's going to be filtered and reordered
    _parkingLotsFiltered = List.of(_parkingLots);
    // Create a list of all the lots that going to be removed after filter
    List<ParkingLot> toRemove = [];
    // First, order the list by distance
    _parkingLotsFiltered.sort((a, b) => a.distance.compareTo(b.distance));
    // Execute all order and filter functions according to the filter status
    for (var function in orderByFunctions) {
      function();
    }
    for (var function in filterByFunctions) {
      function(toRemove);
    }
    // Remove all lots that were filtered through the filter functions
    _parkingLotsFiltered.removeWhere((lot) => toRemove.contains(lot));
    /*
    After ordering and filtering the list by the user's choices, order by the
    list according to the user's last choice (last button that he clicked)
     */

    orderByLastClick(_clickedLast, toRemove);
    // Copy the filtered list to the list of parking lots
    _parkingLots = List.of(_parkingLotsFiltered);
    // If the list of parking lots empty after filtered
    if (_parkingLots.isEmpty) {
      _isParkingLotsEmpty = true;
    }
    setState(() {});
  }

  void orderByLastClick(String clickedLast, List<ParkingLot> toRemove) {
    switch (clickedLast) {
      case availabilityButton:
        orderByAvailability();
        break;
      case accessibilityButton:
        orderByAccessibility();
        break;
      case distanceButton:
        orderByDistance();
        break;
      case discountButton:
        orderByDiscount();
        break;
      case fixedPriceButton:
        filterByFixedPrice(toRemove);
        break;
      case undergroundButton:
        orderByUnderground();
        break;
      default:
        break;
    }
  }

  void orderByAvailability() {
    if (filterStatus.availability) {
      // Sort the parking lots by availability, with null values defaulting to 0.8
      _parkingLotsFiltered.sort((a, b) => (a.availability ?? 0.8).compareTo(b.availability ?? 0.8));
    }
  }

  void orderByAccessibility() {
    if (filterStatus.accessibility) {
      // Sort the parking lots by accessibility, with true values coming first
      _parkingLotsFiltered.sort((a, b) => a.is_accessible != true ? 1 : 0);
    }
  }

  void orderByDistance() {
    if (filterStatus.distance) {
      // Sort the parking lots by distance
      _parkingLotsFiltered.sort((a, b) => a.distance.compareTo(b.distance));
    }
  }

  void orderByUnderground() {
    if (filterStatus.isUnderground) {
      // Sort the parking lots by underground status, with true values coming first
      _parkingLotsFiltered.sort((a, b) => a.is_underground != true ? 1 : 0);
    }
  }

  void orderByDiscount() {
    if (filterStatus.discount) {
      // Sort the parking lots by discount availability, with real values coming first
      _parkingLotsFiltered.sort((a, b) => a.resident_discount == null ? 1 : 0);
    }
  }

  void filterByWalkingDistance(List<ParkingLot> toRemove) {
    if (filterStatus.walkingDistance != null) {
      // Convert walking distance from meters to kilometers
      double distanceInKm = convertToKilometers(filterStatus.walkingDistance!);
      // Remove parking lots that exceed the walking distance
      for (var parkingLot in _parkingLotsFiltered) {
        if (parkingLot.distance > distanceInKm) {
          toRemove.add(parkingLot);
        }
      }
      // Sort the parking lots by distance
      _parkingLotsFiltered.sort((a, b) => a.distance.compareTo(b.distance));
    }
  }

  void filterByPrice(List<ParkingLot> toRemove) {
    if (filterStatus.price != null) {
      // Remove parking lots based on price criteria
      for (var parkingLot in _parkingLotsFiltered) {
        if (parkingLot.fixed_price != null) {
          if (parkingLot.fixed_price!.toDouble() > filterStatus.price!) {
            toRemove.add(parkingLot);
          }
        }
        if (parkingLot.hourly_fare != null) {
          // If the parking lot hourly fare is less than 15 per hour (=10 per hour)
          if (filterStatus.price! < 15) {
            toRemove.add(parkingLot);
          }
          // If the parking lot hourly fare is less than 20 per hour (=10/15 per hour)
          if (filterStatus.price! < 20) {
            // If the parking lot hourly fare is 16 per hour (more than the filtered price)
            if (parkingLot.fare?.contains("16") ?? false){
              toRemove.add(parkingLot);
            }
          }
        }
      }
      /*
       Sort the parking lots by price such that fixed prices come first and
       ranked from low to high.
       */

      _parkingLotsFiltered.sort((a, b) => a.hourly_fare != true ? 0 : 1);
      _parkingLotsFiltered.sort((a, b) => (a.fixed_price ?? 100).compareTo(b.fixed_price ?? 100));
    }
  }

  void filterByFixedPrice(List<ParkingLot> toRemove) {
    if (filterStatus.fixedPrice) {
      // Remove parking lots that don't have a fixed price
      for (var parkingLot in _parkingLotsFiltered) {
        if (parkingLot.fixed_price == null) {
          toRemove.add(parkingLot);
        }
      }
      /*
       Sort the parking lots by hourly fare (non true values come first),
       and then by fixed price (non null values come first).
       The outcome would be the fixed prices first and then fixed+hourly fare.
       */

      _parkingLotsFiltered.sort((a, b) => a.hourly_fare != true ? 0 : 1);
      _parkingLotsFiltered.sort((a, b) => a.fixed_price == null ? 1 : 0);
    }

  }

  // Filter parking lots based on payment method criteria
  void filterByPayingMethod(List<ParkingLot> toRemove) {
    // If the user marked only payment by cash
    if (filterStatus.cash && !filterStatus.credit && !filterStatus.pango) {
      for (var parkingLot in _parkingLotsFiltered) {
        if (parkingLot.paying_method == creditOnly) {
          toRemove.add(parkingLot);
        }
      }
      /*
       Sort the parking lots by payment method, with cash prioritized and then
       cash+credit options.
       */

      _parkingLotsFiltered.sort((a, b) => a.paying_method == cashAndCreditH ? 1 : 0);
      _parkingLotsFiltered.sort((a, b) => a.paying_method == cash ? 0 : 1);
    }
    // If the user marked payment by both credit and cash
    else if (filterStatus.cash && filterStatus.credit || filterStatus.cash && filterStatus.pango) {
      // Sort the parking lots by payment method, cash+credit options prioritized
      _parkingLotsFiltered.sort((a, b) => a.paying_method == unknownPayingMethod ? 0 : 1);
      _parkingLotsFiltered.sort((a, b) => a.paying_method == cashAndCreditH ? 0 : 1);
    }
    // If the user marked only payment by credit or by pango
    else if ((!filterStatus.cash && filterStatus.credit) ||
        (!filterStatus.cash && filterStatus.pango)) {
      for (var parkingLot in _parkingLotsFiltered) {
        if (parkingLot.paying_method == cash) {
          toRemove.add(parkingLot);
        }
      }
      /*
       Sort the parking lots by payment method, with credit-only options
       prioritized and then cash+credit.
       */

      _parkingLotsFiltered.sort((a, b) => a.paying_method == cashAndCreditH ? 1 : 0);
      _parkingLotsFiltered.sort((a, b) => a.paying_method == creditOnly ? 0 : 1);
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
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      backgroundColor: unpressedButtonColor2,
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
                        if (_availabilityButtonColor == unpressedButtonColor2) {
                          setState(() {
                            _availabilityButtonColor = pressedButtonColor;
                            _availabilityTextColor = Colors.white;
                            filterStatus.availability = true;
                            _clickedLast = availabilityButton;
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _availabilityButtonColor = unpressedButtonColor2;
                            _availabilityTextColor = Colors.teal;
                            filterStatus.availability = false;
                            _parkingLots = List.of(_parkingLotsOrigin);
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
                        availabilityButton,
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
                        if (_distanceButtonColor == unpressedButtonColor2) {
                          setState(() {
                            _distanceButtonColor = pressedButtonColor;
                            _distanceTextColor = Colors.white;
                            filterStatus.distance = true;
                            _clickedLast = distanceButton;
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _distanceButtonColor = unpressedButtonColor2;
                            _distanceTextColor = Colors.teal;
                            filterStatus.distance = false;
                            _parkingLots = List.of(_parkingLotsOrigin);
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
                        distanceButton,
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
                        if (_undergroundButtonColor == unpressedButtonColor2) {
                          setState(() {
                            _undergroundButtonColor = pressedButtonColor;
                            _undergroundTextColor = Colors.white;
                            filterStatus.isUnderground = true;
                            _clickedLast = undergroundButton;
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _undergroundButtonColor = unpressedButtonColor2;
                            _undergroundTextColor = Colors.teal;
                            filterStatus.isUnderground = false;
                            _parkingLots = List.of(_parkingLotsOrigin);
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
                        undergroundButton,
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
                        if (_discountButtonColor == unpressedButtonColor2) {
                          setState(() {
                            _discountButtonColor = pressedButtonColor;
                            _discountTextColor = Colors.white;
                            filterStatus.discount = true;
                            _clickedLast = discountButton;
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _discountButtonColor = unpressedButtonColor2;
                            _discountTextColor = Colors.teal;
                            filterStatus.discount = false;
                            _parkingLots = List.of(_parkingLotsOrigin);
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
                        discountButton,
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
                        if (_priceButtonColor == unpressedButtonColor2) {
                          setState(() {
                            _priceButtonColor = pressedButtonColor;
                            _priceTextColor = Colors.white;
                            filterStatus.fixedPrice = true;
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _priceButtonColor = unpressedButtonColor2;
                            _priceTextColor = Colors.teal;
                            filterStatus.fixedPrice = false;
                          });
                          _parkingLots = List.of(_parkingLotsOrigin);
                          orderParkingLotList();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _priceButtonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        fixedPriceButton,
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
                            unpressedButtonColor2) {
                          setState(() {
                            _accessibilityButtonColor = pressedButtonColor;
                            _accessibilityTextColor = Colors.white;
                            filterStatus.accessibility = true;
                            _parkingLots = List.of(_parkingLotsOrigin);
                          });
                          orderParkingLotList();
                        } else {
                          setState(() {
                            _accessibilityButtonColor = unpressedButtonColor2;
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
                        accessibilityButton,
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
                (_parkingLotsOrigin.isEmpty)
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
                                noLotsAvailable,
                                style: TextStyle(
                                  fontFamily: fontFamilyMiriam,
                                  fontSize: 17,
                                  color: Color(0xFF626463),
                                ),
                              ),
                            ),
                          )
                        : (_parkingLots.isEmpty)
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 1.4,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            // Render ParkingLot lists
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _parkingLots.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var data = _parkingLots[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LotDetailsScreen(
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Column(
                                              children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
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
                                                    fontFamily:
                                                        fontFamilyMiriam,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: _fontSize,
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
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4,
                                                                  bottom: 3),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Text(
                                                              data.lot_name,
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      _fontSizeTitle),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    StreamBuilder(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "favorites")
                                                            .where('uid',
                                                                isEqualTo:
                                                                    user.uid)
                                                            .where('parkingLot',
                                                                isEqualTo:
                                                                    data.lot_id)
                                                            .snapshots(),
                                                        builder: (BuildContext
                                                                context,
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
                                                                      Icons
                                                                          .star,
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
                                                                      data
                                                                          .lot_id)
                                                                  : removeFromFavorites(
                                                                      user.uid,
                                                                      data.lot_id));
                                                        }),
                                                  ]),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 19),
                                                    child: Text(
                                                      data.address,
                                                      style: const TextStyle(
                                                          textBaseline:
                                                              TextBaseline
                                                                  .ideographic),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 19),
                                                    child: Text((() {
                                                      if (data.hourly_fare ==
                                                              true &&
                                                          data.fixed_price !=
                                                              null) {
                                                        return fixedAnHourlyPrice;
                                                      } else if (data
                                                                  .hourly_fare ==
                                                              true &&
                                                          data.fixed_price ==
                                                              null) {
                                                        return hourlyPrice;
                                                      } else if (data
                                                                  .hourly_fare !=
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
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 210,
                                                                top: 10),
                                                        child: data.availability !=
                                                                null
                                                            ? CircleAvatar(
                                                                radius: 15,
                                                                backgroundColor: data
                                                                            .availability! ==
                                                                        1
                                                                    ? Colors
                                                                        .deepOrange
                                                                    : data.availability! ==
                                                                            0.7
                                                                        ? Colors
                                                                            .orangeAccent
                                                                        : Colors
                                                                            .green,
                                                                child: data.availability! <
                                                                        1
                                                                    ? const Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white)
                                                                    : const Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .white),
                                                              )
                                                            : const CircleAvatar(
                                                                radius: 15,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white),
                                                      ),
                                                      data.availability != null
                                                          ? Positioned(
                                                              left: 37,
                                                              top: 18,
                                                              child: Text(
                                                                data.availability! ==
                                                                        1
                                                                    ? fullStr
                                                                    : data.availability! ==
                                                                            0.7
                                                                        ? almostFullStr
                                                                        : availableStr,
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      fontFamilyMiriam,
                                                                  fontSize:
                                                                      _fontSize,
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
                                                              (unknownPayingMethod)
                                                          ? Positioned(
                                                              top: 9,
                                                              left: 145,
                                                              child: (data.paying_method ==
                                                                      cashAndCreditH)
                                                                  ? Image.asset(
                                                                      'assets/images/cash_credit.png',
                                                                      height:
                                                                          34,
                                                                      width: 34,
                                                                      fit: BoxFit
                                                                          .fitWidth,
                                                                    )
                                                                  : (data.paying_method ==
                                                                          cash)
                                                                      ? Image
                                                                          .asset(
                                                                          'assets/images/cash.png',
                                                                          height:
                                                                              32,
                                                                          width:
                                                                              32,
                                                                          fit: BoxFit
                                                                              .fitWidth,
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          'assets/images/credit_only.png',
                                                                          height:
                                                                              39,
                                                                          width:
                                                                              39,
                                                                          fit: BoxFit
                                                                              .fitWidth,
                                                                        ))
                                                          : const Center(),
                                                      Positioned(
                                                          top: 11,
                                                          left: 195,
                                                          child: data.is_accessible ==
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
        ],
      ),
    );
  }
}
