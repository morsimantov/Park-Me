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
import 'package:geocoding/geocoding.dart';

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
  late ParkingLot parkingLot;
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> getParkingLotDetails() async {
    final int lot_id = widget.lotId;
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
      parkingLot.distance = widget.distance;
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
        distance: widget.distance);
    getParkingLotDetails();
  }

  int convertToWalkingDistance(double distanceInKm) {
    // Assuming an average walking speed of 5 kilometers per hour
    double walkingSpeedKph = 5.0;
    // Convert walking speed from kilometers per hour to kilometers per minute
    double walkingSpeedKpm = walkingSpeedKph / 60.0;
    // Calculate the walking time in minutes
    double walkingTimeMinutes = distanceInKm / walkingSpeedKpm;
    return walkingTimeMinutes.round();
  }

  Future<void> launchWaze(double lat, double lng) async {
    final Uri url = Uri.parse(
        'waze://?ll=${lat.toString()},${lng.toString()}');
    final Uri fallbackUrl = Uri.parse(
        'https://waze.com/ul?ll=${lat.toString()},${lng.toString()}&navigate=yes');
    try {
      bool launched = false;
      if (!kIsWeb) {
        launched = await launchUrl(url);
      }
      if (!launched) {
        await launchUrl(fallbackUrl);
      }
    } catch (e) {
      await launchUrl(fallbackUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (parkingLot.lot_id == 0)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: <Widget>[
                LotDetailsAppBar(
                  image: parkingLot.image,
                  lotId: parkingLot.lot_id,
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
                        textDirection: TextDirection.rtl,child: Row(
                            children: [
                              Directionality(
                                textDirection: TextDirection.rtl,child: Padding(
                                padding:
                                const EdgeInsets.only(top: 5,),
                                child: Text(
                                  parkingLot.lot_name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),),
                              Padding(
                                  padding:
                                  const EdgeInsets.only(top: 5, right: 15),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 4),
                                          blurRadius: 4.0,
                                          color: Colors.black.withOpacity(0.25),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.blue, // Button color
                                        child: InkWell(
                                          splashColor: Colors.cyan, // Splash color
                                          onTap: () async {
                                            List<Location> locations =
                                            await locationFromAddress(
                                                parkingLot.address);
                                            launchWaze(
                                                locations.first.latitude,
                                                locations.first.longitude);
                                          },
                                          child: const SizedBox(width: 33, height: 33, child: Icon(FontAwesomeIcons.waze, color: Colors.white,
                                            size: 20,)),
                                        ),
                                      ),
                                    ),
                                  )
                              ),

                            ],
                          ),),
                          const SizedBox(height: 7.0),
                          Row(
                            children: [
                              Text(parkingLot.address),
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
                                  "${parkingLot.distance.toStringAsFixed(1)} KM Away",
                                  style: const TextStyle(
                                    fontFamily: 'MiriamLibre',
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
                                parkingLot.availability != null
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
                                              color:
                                                  parkingLot.availability! ==
                                                      1 ? Colors
                                                      .deepOrange : parkingLot.availability! == 0.7
                                                      ? Colors
                                                      .orangeAccent
                                                      : Colors
                                                      .green,
                                            ),
                                            child: parkingLot.availability! < 1
                                                ? const Icon(Icons.check,
                                                    color: Colors.white)
                                                : const Icon(Icons.close,
                                                    color: Colors.white),
                                          ),
                                          Text(
                                            parkingLot.availability! ==
                                                1 ? "Full" :  parkingLot.availability! == 0.7
                                                ? "Almost Full"
                                                : "Available!",
                                            style: const TextStyle(
                                              fontFamily: 'MiriamLibre',
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
                                          '${convertToWalkingDistance(parkingLot.distance)} min Away',
                                          style: const TextStyle(
                                            fontFamily: 'MiriamLibre',
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

                          parkingLot.availability != null
                              ? Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Row(
                                    children: [
                                      Text(
                                        'True to: ${parkingLot.updated_time?.substring(0, parkingLot.updated_time?.indexOf(":", (parkingLot.updated_time?.indexOf(":") ?? -1) + 1))}',
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
                          (parkingLot.hourly_fare != null &&
                                  parkingLot.hourly_fare == true)
                              ? Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'מחיר שעתי:',
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      parkingLot.fare!,
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
                          (parkingLot.fare != null &&
                                  parkingLot.hourly_fare != true)
                              ? Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text('מחיר:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        parkingLot.fare!,
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
                          parkingLot.fixed_price == null
                              ? const Center()
                              : Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'מחיר קבוע:',
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
                                        "${parkingLot.fixed_price} ש\"ח לשעה",
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${parkingLot.fixed_price_hours}",
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
                            'שעות פעילות:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            parkingLot.opening_hours,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: kSecondaryTextColor),
                          ),
                          const SizedBox(height: 16.0),
                          const Divider(color: kOutlineColor, height: 1.0),
                          const SizedBox(height: 16.0),
                          Text(
                            'פרטים נוספים:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          (parkingLot.is_accessible != true)
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
                                            fontFamily: 'MiriamLibre',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          (parkingLot.is_underground != true)
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
                                          "Underground",
                                          style: TextStyle(
                                            fontFamily: 'MiriamLibre',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          (parkingLot.paying_method == "בהתאם לשילוט במקום")
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
                                          child: (parkingLot.paying_method ==
                                                  "מזומן + אשראי (חניון ממוכן)")
                                              ? Image.asset(
                                                  'assets/images/cash_credit.png',
                                                  height: 20,
                                                  width: 20,
                                                  fit: BoxFit.fitWidth,
                                                )
                                              : (parkingLot.paying_method ==
                                                      "מזומן")
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
                                        (parkingLot.paying_method ==
                                                "בהתאם לשילוט במקום")
                                            ? const Center()
                                            : Text(
                                                (parkingLot.paying_method ==
                                                        "מזומן + אשראי (חניון ממוכן)")
                                                    ? "Cash and Credit"
                                                    : (parkingLot
                                                                .paying_method ==
                                                            "מזומן")
                                                        ? "Payment in Cash"
                                                        : "Credit and Digital only",
                                                style: const TextStyle(
                                                  fontFamily: 'MiriamLibre',
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                          parkingLot.resident_discount != null
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
                                          (parkingLot.resident_discount ==
                                                  "בסך 50% מהתעריף")
                                              ? "50% Resident Discount"
                                              : "70% Resident Discount",
                                          style: const TextStyle(
                                            fontFamily: 'MiriamLibre',
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
                                    "${parkingLot.num_parking_spots} parking spots",
                                    style: const TextStyle(
                                      fontFamily: 'MiriamLibre',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // Text(
                          //   'Steps',
                          //   style: Theme
                          //       .of(context)
                          //       .textTheme
                          //       .titleMedium,
                          // ),
                          // const SizedBox(height: 16.0),
                          // Row(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Container(
                          //       height: 24.0,
                          //       width: 24.0,
                          //       alignment: Alignment.center,
                          //       margin: const EdgeInsets.only(right: 16.0),
                          //       decoration: const BoxDecoration(
                          //         shape: BoxShape.circle,
                          //         color: kMainTextColor,
                          //       ),
                          //       child: Text(
                          //         '1',
                          //         style: Theme
                          //             .of(context)
                          //             .textTheme
                          //             .bodySmall!
                          //             .copyWith(
                          //             color: Colors.white,
                          //             fontWeight: FontWeight.w700),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       child: Column(
                          //         children: [
                          //           Text(
                          //             'Your recipe has been uploaded, you can see it on your profile. Your recipe has been uploaded, you can see it on your',
                          //             style: Theme
                          //                 .of(context)
                          //                 .textTheme
                          //                 .bodyMedium,
                          //           ),
                          //           const SizedBox(height: 16.0),
                          //           ClipRRect(
                          //             borderRadius: BorderRadius.circular(12.0),
                          //             child: Image.network(
                          //               'https://images.unsplash.com/photo-1466637574441-749b8f19452f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=300&q=80',
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 32.0),
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
