import 'package:flutter/material.dart';
import 'package:park_me/screens/parking_lots_results_screen.dart';
import '../model/filter_parameters.dart';
import '../config/strings.dart';
import '../config/colors.dart';

class FilterScreen extends StatefulWidget {
  final FilterParameters filterStatus;
  final String wantedLocationAddress;

  const FilterScreen(
      {super.key,
      required this.wantedLocationAddress,
      required this.filterStatus});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const String _appBarTitle = "Find a Parking spot";
  static const String _orderByTitle = "Order by:";
  static const String _applyButton = "Apply";
  static const String _filterByTitle = "Filter by:";
  static const String _walkingDistanceText = "Maximum walking distance:";
  static const String _priceText = "Maximum price per hour:";
  static const String _payingMethodText = "Method of payment:";
  static const String _cashText = "Cash";
  static const String _creditText = "Credit Card";
  static const String _pangoText = "Pango";
  static const double _fontSize = 16;
  static const double _fontSizeTitle = 18;
  double _walkingDisSlider = 25;
  double _priceSlider = 20;

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
  late bool _isCashChecked;
  late bool _isCreditChecked;
  late bool _isPangoChecked = false;

  @override
  void initState() {
    super.initState();
    // Set initial button colors according to the filter status
    _availabilityButtonColor = filterStatus.availability
        ? pressedButtonColor
        : unpressedButtonColor;
    _availabilityTextColor =
        filterStatus.availability ? Colors.white : unpressedTextColor;
    _accessibleButtonColor = filterStatus.accessibility
        ? pressedButtonColor
        : unpressedButtonColor;
    _accessibleTextColor =
        filterStatus.accessibility ? Colors.white : unpressedTextColor;
    _undergroundButtonColor = filterStatus.isUnderground
        ? pressedButtonColor
        : unpressedButtonColor;
    _undergroundTextColor =
        filterStatus.isUnderground ? Colors.white : unpressedTextColor;
    _discountButtonColor = filterStatus.discount
        ? pressedButtonColor
        : unpressedButtonColor;
    _discountTextColor =
        filterStatus.discount ? Colors.white : unpressedTextColor;
    _distanceButtonColor = filterStatus.distance
        ? pressedButtonColor
        : unpressedButtonColor;
    _distanceTextColor =
        filterStatus.distance ? Colors.white : unpressedTextColor;
    _priceButtonColor = filterStatus.fixedPrice
        ? pressedButtonColor
        : unpressedButtonColor;
    _priceTextColor =
        filterStatus.fixedPrice ? Colors.white : unpressedTextColor;
    // Set initial checkboxes according to the filter status
    _isCashChecked = filterStatus.cash ? true : false;
    _isCreditChecked = filterStatus.credit ? true : false;
    _isPangoChecked = filterStatus.pango ? true : false;
    // Set initial sliders according to the filter status values
    if (filterStatus.walkingDistance != null) {
      _walkingDisSlider = filterStatus.walkingDistance!;
    }
    if (filterStatus.price != null) {
      _priceSlider = filterStatus.price!;
    }
  }

  Color getColor(Set<MaterialState> states) {
      return pressedButtonColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_appBarTitle),
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
                          _orderByTitle,
                          style: TextStyle(
                            fontFamily: fontFamilyMiriam,
                            color: greyTextColor,
                            fontSize: _fontSizeTitle,
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
                              unpressedButtonColor) {
                            setState(() {
                              _availabilityButtonColor =
                                  pressedButtonColor;
                              _availabilityTextColor = Colors.white;
                              filterStatus.availability = true;
                            });
                          } else {
                            setState(() {
                              _availabilityButtonColor =
                                  unpressedButtonColor;
                              _availabilityTextColor = unpressedTextColor;
                              filterStatus.availability = false;
                            });
                          }
                        },
                        child: Text(
                          availabilityButton,
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
                          if (_distanceButtonColor == unpressedButtonColor) {
                            setState(() {
                              _distanceButtonColor = pressedButtonColor;
                              _distanceTextColor = Colors.white;
                              filterStatus.distance = true;
                            });
                          } else {
                            setState(() {
                              _distanceButtonColor = unpressedButtonColor;
                              _distanceTextColor = unpressedTextColor;
                              filterStatus.distance = false;
                            });
                          }
                        },
                        child: Text(
                          distanceButton,
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
                              unpressedButtonColor) {
                            setState(() {
                              _accessibleButtonColor = pressedButtonColor;
                              _accessibleTextColor = Colors.white;
                              filterStatus.accessibility = true;
                            });
                          } else {
                            setState(() {
                              _accessibleButtonColor = unpressedButtonColor;
                              _accessibleTextColor = unpressedTextColor;
                              filterStatus.accessibility = false;
                            });
                          }
                        },
                        child: Text(
                          accessibilityButton,
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
                              unpressedButtonColor) {
                            setState(() {
                              _undergroundButtonColor = pressedButtonColor;
                              _undergroundTextColor = Colors.white;
                              filterStatus.isUnderground = true;
                            });
                          } else {
                            setState(() {
                              _undergroundButtonColor = unpressedButtonColor;
                              _undergroundTextColor = unpressedTextColor;
                              filterStatus.isUnderground = false;
                            });
                          }
                        },
                        child: Text(
                          undergroundButton,
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
                          if (_discountButtonColor == unpressedButtonColor) {
                            setState(() {
                              _discountButtonColor = pressedButtonColor;
                              _discountTextColor = Colors.white;
                              filterStatus.discount = true;
                            });
                          } else {
                            setState(() {
                              _discountButtonColor = unpressedButtonColor;
                              _discountTextColor = unpressedTextColor;
                              filterStatus.discount = false;
                            });
                          }
                        },
                        child: Text(
                          discountButton,
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
                          _filterByTitle,
                          style: TextStyle(
                            fontFamily: fontFamilyMiriam,
                            color: greyTextColor,
                            fontSize: _fontSizeTitle,
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
                          _walkingDistanceText,
                          style: TextStyle(
                            fontFamily: fontFamilyMiriam,
                            color: greyTextColor,
                            fontSize: _fontSize,
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
                          _priceText,
                          style: TextStyle(
                            fontFamily: fontFamilyMiriam,
                            color: greyTextColor,
                            fontSize: _fontSize,
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
                    max: 45,
                    min: 10,
                    divisions: 7,
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
                      if (_priceButtonColor == unpressedButtonColor) {
                        setState(() {
                          _priceButtonColor = pressedButtonColor;
                          _priceTextColor = Colors.white;
                          filterStatus.fixedPrice = true;
                        });
                      } else {
                        setState(() {
                          _priceButtonColor = unpressedButtonColor;
                          _priceTextColor = unpressedTextColor;
                          filterStatus.fixedPrice = false;
                        });
                      }
                    },
                    child: Text(
                      fixedPriceButton,
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
                          _payingMethodText,
                          style: TextStyle(
                            fontFamily: fontFamilyMiriam,
                            color: greyTextColor,
                            fontSize: _fontSize,
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
                    value: _isCashChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isCashChecked = value!;
                        filterStatus.cash = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 417),
                  child: Text(
                    _cashText,
                    style: TextStyle(
                      fontFamily: fontFamilyMiriam,
                      color: greyTextColor,
                      fontSize: _fontSize,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 432),
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: _isCreditChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isCreditChecked = value!;
                        filterStatus.credit = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 447),
                  child: Text(
                    _creditText,
                    style: TextStyle(
                      fontFamily: fontFamilyMiriam,
                      color: greyTextColor,
                      fontSize: _fontSize,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 462),
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: _isPangoChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPangoChecked = value!;
                        filterStatus.pango = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 477),
                  child: Text(
                    _pangoText,
                    style: TextStyle(
                      fontFamily: fontFamilyMiriam,
                      color: greyTextColor,
                      fontSize: _fontSize,
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
                                wantedLocationAddress:
                                    widget.wantedLocationAddress,
                                filterStatus: filterStatus,
                              ),
                            ));
                      },
                      child: const Text(
                        _applyButton,
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
