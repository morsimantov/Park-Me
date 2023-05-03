import 'package:flutter/material.dart';
import 'package:park_me/screens/parking_lots_results_screen.dart';
import 'package:park_me/screens/parking_lots_screen.dart';
import 'dart:math';
import '../model/filter_parameters.dart';

class FilterScreen extends StatefulWidget {
  final FilterParameters filterStatus;
  final String wantedLocationAddress;
  const FilterScreen({super.key, required this.wantedLocationAddress, required this.filterStatus});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}


class _FilterScreenState extends State<FilterScreen> {
  late FilterParameters filterStatus = widget.filterStatus;
  late Color _availabilityButtonColor;
  late Color _availabilityTextColor;
  late Color _accessibleButtonColor;
  late Color _accessibleTextColor;
  late Color _undergroundButtonColor;
  late Color _undergroundTextColor;
  late Color _priceButtonColor;
  late Color _priceTextColor;
  late bool isCashChecked;
  late bool isCreditChecked;
  late bool isPangoChecked = false;
  double _walkingDisSlider = 20;
  double _priceSlider = 20;
  bool isHover=false;

  @override
  void initState() {
    super.initState();
    _availabilityButtonColor = filterStatus.availability ? const Color(0xFF55C0B3) : const Color(0xFFD6E7E2);
    _availabilityTextColor = filterStatus.availability ? Colors.white : const Color(0xFF868D8C);
    _accessibleButtonColor = filterStatus.accessibility ? const Color(0xFF55C0B3) : const Color(0xFFD6E7E2);
    _accessibleTextColor = filterStatus.accessibility ? Colors.white : const Color(0xFF868D8C);
    _undergroundButtonColor = filterStatus.isUnderground ?  const Color(0xFF55C0B3): const Color(0xFFD6E7E2);
    _undergroundTextColor = filterStatus.isUnderground ? Colors.white : const Color(0xFF868D8C);
    _priceButtonColor = filterStatus.fixedPrice ?  const Color(0xFF55C0B3) : const Color(0xFFD6E7E2);
    _priceTextColor = filterStatus.fixedPrice ? Colors.white : const Color(0xFF868D8C);
    isCashChecked = filterStatus.cash ? true : false;
    isCreditChecked = filterStatus.credit ? true : false;
    isPangoChecked = filterStatus.pango ? true : false;
    if (filterStatus.walkingDistance != null) {
      _walkingDisSlider = filterStatus.walkingDistance!;
    }
    if (filterStatus.price != null) {
      _priceSlider = filterStatus.price!;
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return const Color(0xFF55C0B3);
    } else {
      return const Color(0xFF55C0B3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a Parking spot"),
        backgroundColor: const Color(0xFF03A295),
      ),
      backgroundColor: const Color(0xfff5f6fa),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Order by:',
                          style: TextStyle(
                            fontFamily: 'MiriamLibre',
                            color: Color(0xFF474948),
                            fontSize: 20,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _availabilityButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          if (_availabilityButtonColor ==
                              const Color(0xFFD6E7E2)) {
                            setState(() {
                              _availabilityButtonColor =
                              const Color(0xFF55C0B3);
                              _availabilityTextColor = Colors.white;
                              filterStatus.availability = true;
                            });
                          } else {
                            setState(() {
                              _availabilityButtonColor =
                                  const Color(0xFFD6E7E2);
                              _availabilityTextColor = const Color(0xFF868D8C);
                              filterStatus.availability = false;
                            });
                          }
                        },
                        child: Text(
                          'Availability',
                          style: TextStyle(
                            color: _availabilityTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _undergroundButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () {
                          if (_undergroundButtonColor ==
                              const Color(0xFFD6E7E2)) {
                            setState(() {
                              _undergroundButtonColor = const Color(0xFF55C0B3);
                              _undergroundTextColor = Colors.white;
                              filterStatus.isUnderground = true;
                            });
                          } else {
                            setState(() {
                              _undergroundButtonColor = const Color(0xFFD6E7E2);
                              _undergroundTextColor = const Color(0xFF868D8C);
                              filterStatus.isUnderground = false;
                            });
                          }
                        },
                        child: Text(
                          'Underground',
                          style: TextStyle(
                            color: _undergroundTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accessibleButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 11),
                        ),
                        onPressed: () {
                          if (_accessibleButtonColor ==
                              const Color(0xFFD6E7E2)) {
                            setState(() {
                              _accessibleButtonColor = const Color(0xFF55C0B3);
                              _accessibleTextColor = Colors.white;
                              filterStatus.accessibility = true;
                            });
                          } else {
                            setState(() {
                              _accessibleButtonColor = const Color(0xFFD6E7E2);
                              _accessibleTextColor = const Color(0xFF868D8C);
                              filterStatus.accessibility = false;
                            });
                          }
                        },
                        child: Text(
                          'Accessible',
                          style: TextStyle(
                            color: _accessibleTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Maximum walking distance:',
                          style: TextStyle(
                            fontFamily: 'MiriamLibre',
                            color: Color(0xFF474948),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 185),
                  child: Slider(
                    value: _walkingDisSlider,
                    max: 30,
                    divisions: 6,
                    label: _walkingDisSlider.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _walkingDisSlider = value;
                        filterStatus.walkingDistance = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Maximum price per hour:',
                          style: TextStyle(
                            fontFamily: 'MiriamLibre',
                            color: Color(0xFF474948),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 265),
                  child: Slider(
                    value: _priceSlider,
                    max: 120,
                    divisions: 12,
                    label: _priceSlider.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _priceSlider = value;
                        filterStatus.price = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 315),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _priceButtonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      if (_priceButtonColor == const Color(0xFFD6E7E2)) {
                        setState(() {
                          _priceButtonColor = const Color(0xFF55C0B3);
                          _priceTextColor = Colors.white;
                          filterStatus.fixedPrice = true;
                        });
                      } else {
                        setState(() {
                          _priceButtonColor = const Color(0xFFD6E7E2);
                          _priceTextColor = const Color(0xFF868D8C);
                          filterStatus.fixedPrice = false;
                        });
                      }
                    },
                    child: Text(
                      'Fixed price',
                      style: TextStyle(
                        color: _priceTextColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 383),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Method of payment:',
                          style: TextStyle(
                            fontFamily: 'MiriamLibre',
                            color: Color(0xFF474948),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 400),
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: isCashChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isCashChecked = value!;
                        filterStatus.cash = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 415),
                  child: Text(
                    'Cash',
                    style: TextStyle(
                      fontFamily: 'MiriamLibre',
                      color: Color(0xFF474948),
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 430),
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: isCreditChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isCreditChecked = value!;
                        filterStatus.credit = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 445),
                  child: Text(
                    'Credit card',
                    style: TextStyle(
                      fontFamily: 'MiriamLibre',
                      color: Color(0xFF474948),
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 460),
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: isPangoChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isPangoChecked = value!;
                        filterStatus.pango = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 475),
                  child: Text(
                    'Pango',
                    style: TextStyle(
                      fontFamily: 'MiriamLibre',
                      color: Color(0xFF474948),
                      fontSize: 16,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 525),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EB4AD),
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ParkingLotsResultsScreen(
                                wantedLocationAddress: widget.wantedLocationAddress,
                                filterStatus: filterStatus,
                              ),
                            ));
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
