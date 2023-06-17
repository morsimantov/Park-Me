import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/colors.dart';
import '../env.sample.dart';
import '../widgets/lot_details_appbar.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:park_me/model/parking_lot.dart';
import '../utils.dart';
import '../config/strings.dart';

class LotDetailsScreen extends StatefulWidget {
  final int lotId;
  final double distance;

  const LotDetailsScreen(
      {Key? key, required this.lotId, required this.distance})
      : super(key: key);

  @override
  LotDetailsScreenState createState() => LotDetailsScreenState();
}

class LotDetailsScreenState extends State<LotDetailsScreen> {
  static const String _openingHoursStr = "שעות פעילות:";
  static const String _priceStr = "מחיר:";
  static const String _fixedPriceStr = "מחיר קבוע:";
  static const String _hourlyPriceStr = "מחיר שעתי:";
  static const String _moreDetailsStr = "פרטים נוספים:";

  // Parking lot instance that will store the current parking lot
  late ParkingLot _parkingLot;
  final user = FirebaseAuth.instance.currentUser!;

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
        distance: widget.distance);
    getParkingLotDetails();
  }

  Future<void> getParkingLotDetails() async {
    // Retrieve the lotId from the widget
    final int lotId = widget.lotId;
    // Send a GET request to retrieve parking lot details based on the lotId
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/lots/$lotId"));
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    // Map the JSON response to a list of ParkingLot objects
    List<ParkingLot> parkingLotTemp = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();
    setState(() {
      // Update the parkingLot instance with the retrieved parking lot details
      _parkingLot = parkingLotTemp.first;
      _parkingLot.distance = widget.distance;
    });
  }

  Future<void> launchWaze(double lat, double lng) async {
    // Construct the Waze URI for launching the navigation
    final Uri url = Uri.parse('waze://?ll=${lat.toString()},${lng.toString()}');
    // Fallback URL in case the Waze app is not installed
    final Uri fallbackUrl = Uri.parse(
        'https://waze.com/ul?ll=${lat.toString()},${lng.toString()}&navigate=yes');
    try {
      bool launched = false;
      if (!kIsWeb) {
        // Attempt to launch the Waze app using the Waze URI
        launched = await launchUrl(url);
      }
      if (!launched) {
        // Launch the fallback URL if the Waze app could not be launched
        await launchUrl(fallbackUrl);
      }
    } catch (e) {
      // Launch the fallback URL in case of any errors
      await launchUrl(fallbackUrl);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_parkingLot.lot_id == 0)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: <Widget>[
                LotDetailsAppBar(
                  image: _parkingLot.image,
                  lotId: _parkingLot.lot_id,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              children: [
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                    ),
                                    child: Text(
                                      _parkingLot.lot_name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, right: 15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 4),
                                            blurRadius: 4.0,
                                            color:
                                                Colors.black.withOpacity(0.25),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.blue, // Button color
                                          child: InkWell(
                                            splashColor:
                                                Colors.cyan, // Splash color
                                            onTap: () async {
                                              List<Location> locations =
                                                  await locationFromAddress(
                                                      _parkingLot.address);
                                              launchWaze(
                                                  locations.first.latitude,
                                                  locations.first.longitude);
                                            },
                                            child: const SizedBox(
                                                width: 33,
                                                height: 33,
                                                child: Icon(
                                                  FontAwesomeIcons.waze,
                                                  color: Colors.white,
                                                  size: 20,
                                                )),
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 7.0),
                          Row(
                            children: [
                              Text(_parkingLot.address),
                              const SizedBox(width: 8.0),
                              Container(
                                height: 5.0,
                                width: 5.0,
                                decoration: const BoxDecoration(
                                  color: kSecondaryTextColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  "${_parkingLot.distance.toStringAsFixed(1)} KM Away",
                                  style: const TextStyle(
                                    fontFamily: fontFamilyMiriam,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _parkingLot.availability != null
                                    ? Row(
                                        children: [
                                          Container(
                                            height: 32.0,
                                            width: 32.0,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                                right: 8.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              // color: kPrimaryColor,
                                              color: _parkingLot
                                                          .availability! ==
                                                      1
                                                  ? Colors.deepOrange
                                                  : _parkingLot.availability! ==
                                                          0.7
                                                      ? Colors.orangeAccent
                                                      : Colors.green,
                                            ),
                                            child: _parkingLot.availability! < 1
                                                ? const Icon(Icons.check,
                                                    color: Colors.white)
                                                : const Icon(Icons.close,
                                                    color: Colors.white),
                                          ),
                                          Text(
                                            _parkingLot.availability! == 1
                                                ? fullStr
                                                : _parkingLot.availability! ==
                                                        0.7
                                                    ? almostFullStr
                                                    : availableStr,
                                            style: const TextStyle(
                                              fontFamily: fontFamilyMiriam,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF626463),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Center(),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 30.0,
                                          width: 30.0,
                                          margin:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Image.asset(
                                            'assets/images/walking.png',
                                            height: 20,
                                            width: 20,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Text(
                                          '${convertToWalkingDistance(_parkingLot.distance)} min Away',
                                          style: const TextStyle(
                                            fontFamily: fontFamilyMiriam,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF626463),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          _parkingLot.availability != null
                              ? Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Row(
                                    children: [
                                      Text(
                                        'True to: ${_parkingLot.updated_time?.substring(0, _parkingLot.updated_time?.indexOf(":", (_parkingLot.updated_time?.indexOf(":") ?? -1) + 1))}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: kSecondaryTextColor),
                                      ),
                                    ],
                                  ),
                                )
                              : const Center(),
                          const SizedBox(height: 16.0),
                          const Divider(color: kOutlineColor, height: 1.0),
                          const SizedBox(height: 16.0),
                          (_parkingLot.hourly_fare != null &&
                                  _parkingLot.hourly_fare == true)
                              ? Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _hourlyPriceStr,
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      _parkingLot.fare!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: kSecondaryTextColor),
                                    ),
                                    const SizedBox(height: 16.0),
                                    const Divider(
                                        color: kOutlineColor, height: 1.0),
                                    const SizedBox(height: 16.0)
                                  ],
                                )
                              : const Center(),
                          (_parkingLot.fare != null &&
                                  _parkingLot.hourly_fare != true)
                              ? Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(_priceStr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _parkingLot.fare!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: kSecondaryTextColor),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    const Divider(
                                        color: kOutlineColor, height: 1.0),
                                    const SizedBox(height: 16.0)
                                  ],
                                )
                              : const Center(),
                          _parkingLot.fixed_price == null
                              ? const Center()
                              : Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _fixedPriceStr,
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${_parkingLot.fixed_price} ש\"ח לשעה",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${_parkingLot.fixed_price_hours}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: kSecondaryTextColor),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    const Divider(
                                        color: kOutlineColor, height: 1.0),
                                    const SizedBox(height: 16.0),
                                  ],
                                ),
                          Text(
                            _openingHoursStr,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            _parkingLot.opening_hours,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: kSecondaryTextColor),
                          ),
                          const SizedBox(height: 16.0),
                          const Divider(color: kOutlineColor, height: 1.0),
                          const SizedBox(height: 16.0),
                          Text(
                            _moreDetailsStr,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          (_parkingLot.is_accessible != true)
                              ? const Center()
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 32.0,
                                          width: 32.0,
                                          alignment: Alignment.center,
                                          margin:
                                              const EdgeInsets.only(right: 8.0),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFE3FFF8),
                                          ),
                                          child: Image.asset(
                                            'assets/images/disability.png',
                                            height: 20,
                                            width: 20,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        const Text(
                                          "Accessible",
                                          style: TextStyle(
                                            fontFamily: fontFamilyMiriam,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          (_parkingLot.is_underground != true)
                              ? const Center()
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 32.0,
                                          width: 32.0,
                                          alignment: Alignment.center,
                                          margin:
                                              const EdgeInsets.only(right: 8.0),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFE3FFF8),
                                          ),
                                          child: Image.asset(
                                            'assets/images/underground.png',
                                            height: 19,
                                            width: 19,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        const Text(
                                          undergroundButton,
                                          style: TextStyle(
                                            fontFamily: fontFamilyMiriam,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          (_parkingLot.paying_method == unknownPayingMethod)
                              ? const Center()
                              : Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 32.0,
                                          width: 32.0,
                                          alignment: Alignment.center,
                                          margin:
                                              const EdgeInsets.only(right: 8.0),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFE3FFF8),
                                          ),
                                          child: (_parkingLot.paying_method ==
                                                  cashAndCreditH)
                                              ? Image.asset(
                                                  'assets/images/cash_credit.png',
                                                  height: 20,
                                                  width: 20,
                                                  fit: BoxFit.fitWidth,
                                                )
                                              : (_parkingLot.paying_method ==
                                                      cash)
                                                  ? Image.asset(
                                                      'assets/images/cash.png',
                                                      height: 23,
                                                      width: 23,
                                                      fit: BoxFit.fitWidth,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/credit_only.png',
                                                      height: 23,
                                                      width: 23,
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                        ),
                                        (_parkingLot.paying_method ==
                                                unknownPayingMethod)
                                            ? const Center()
                                            : Text(
                                                (_parkingLot.paying_method ==
                                                        cashAndCreditH)
                                                    ? cashAndCreditE
                                                    : (_parkingLot
                                                                .paying_method ==
                                                            cash)
                                                        ? cashPayment
                                                        : creditPayment,
                                                style: const TextStyle(
                                                  fontFamily: fontFamilyMiriam,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                          _parkingLot.resident_discount != null
                              ? Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 32.0,
                                          width: 32.0,
                                          alignment: Alignment.center,
                                          margin:
                                              const EdgeInsets.only(right: 8.0),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFE3FFF8),
                                          ),
                                          child: Image.asset(
                                            'assets/images/tag.png',
                                            height: 19,
                                            width: 19,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Text(
                                          (_parkingLot.resident_discount ==
                                                  fiftyDiscountH)
                                              ? fiftyDiscountE
                                              : seventyDiscountE,
                                          style: const TextStyle(
                                            fontFamily: fontFamilyMiriam,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const Center(),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 32.0,
                                    width: 32.0,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFE3FFF8),
                                    ),
                                    child: Image.asset(
                                      'assets/images/car.png',
                                      height: 22,
                                      width: 22,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  Text(
                                    "${_parkingLot.num_parking_spots} parking spots",
                                    style: const TextStyle(
                                      fontFamily: fontFamilyMiriam,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
