import 'package:flutter/material.dart';
import 'package:park_me/screens/parking_lots_results_screen.dart';
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
  late Color _discountButtonColor;
  late Color _discountTextColor;
  late Color _distanceButtonColor;
  late Color _distanceTextColor;
  late Color _priceButtonColor;
  late Color _priceTextColor;
  late bool isCashChecked;
  late bool isCreditChecked;
  late bool isPangoChecked = false;
  double _walkingDisSlider = 25;
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
    _discountButtonColor = filterStatus.discount ?  const Color(0xFF55C0B3): const Color(0xFFD6E7E2);
    _discountTextColor = filterStatus.discount ? Colors.white : const Color(0xFF868D8C);
    _distanceButtonColor = filterStatus.distance ?  const Color(0xFF55C0B3): const Color(0xFFD6E7E2);
    _distanceTextColor = filterStatus.distance ? Colors.white : const Color(0xFF868D8C);
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
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
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
                            fontSize: 18,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 57),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _availabilityButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          backgroundColor: _distanceButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 23),
                        ),
                        onPressed: () {
                          if (_distanceButtonColor ==
                              const Color(0xFFD6E7E2)) {
                            setState(() {
                              _distanceButtonColor =
                              const Color(0xFF55C0B3);
                              _distanceTextColor = Colors.white;
                              filterStatus.distance = true;
                            });
                          } else {
                            setState(() {
                              _distanceButtonColor =
                              const Color(0xFFD6E7E2);
                              _distanceTextColor = const Color(0xFF868D8C);
                              filterStatus.distance = false;
                            });
                          }
                        },
                        child: Text(
                          'Distance',
                          style: TextStyle(
                            color: _distanceTextColor,
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
                          'Accessibility',
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
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 102),
                  child: Row(
                    children: [
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
                          backgroundColor: _discountButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () {
                          if (_discountButtonColor ==
                              const Color(0xFFD6E7E2)) {
                            setState(() {
                              _discountButtonColor = const Color(0xFF55C0B3);
                              _discountTextColor = Colors.white;
                              filterStatus.discount = true;
                            });
                          } else {
                            setState(() {
                              _discountButtonColor = const Color(0xFFD6E7E2);
                              _discountTextColor = const Color(0xFF868D8C);
                              filterStatus.discount = false;
                            });
                          }
                        },
                        child: Text(
                          'Resident Discount',
                          style: TextStyle(
                            color: _discountTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 168),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Filter by:',
                          style: TextStyle(
                            fontFamily: 'MiriamLibre',
                            color: Color(0xFF474948),
                            fontSize: 18,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 205),
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 220),
                  child: Slider(
                    value: _walkingDisSlider,
                    max: 60,
                    divisions: 12,
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
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 260),
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 275),
                  child: Slider(
                    value: _priceSlider,
                    max: 50,
                    divisions: 5,
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
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 318),
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
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 385),
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 402),
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
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 417),
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 432),
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
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 447),
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 462),
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
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 477),
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
