import 'package:flutter/material.dart';
import 'package:park_me/screens/parking_lots_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, required this.title});
  final String title;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  Color _availabilityButtonColor =  const Color(0xFFD6E7E2);
  Color _availabilityTextColor = const Color(0xFF868D8C);

  Color _undergroundButtonColor =  const Color(0xFFD6E7E2);
  Color _undergroundTextColor = const Color(0xFF868D8C);

  Color _accessibleButtonColor =  const Color(0xFFD6E7E2);
  Color _accessibleTextColor = const Color(0xFF868D8C);

  Color _priceButtonColor =  const Color(0xFFD6E7E2);
  Color _priceTextColor = const Color(0xFF868D8C);

  double _currentSlider1Value = 20;
  double _currentSlider2Value = 20;

  bool isCashChecked = false;
  bool isCreditChecked = false;
  bool isPangoChecked = false;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.cyan;
    } else {
      return Colors.cyan;
    }
  }

  // final labels = ['0,', '5', '10', '15', '20', '25', '30'];

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a Parking spot"),
      ),
      backgroundColor: const Color(0xFFDBF8EE),
      // bottomNavigationBar: Container(
      //   height: 80,
      //   width: double.infinity,
      //   padding: EdgeInsets.all(10),
      //   color: Colors.teal,
      //   child: Padding(
      //     padding: const EdgeInsets.only(bottom: 10),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _availabilityButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          if (_availabilityButtonColor == const Color(0xFFD6E7E2)) {
                            setState(() => _availabilityButtonColor = const Color(0xFF5DD5C7));
                            setState(() => _availabilityTextColor = Colors.white);
                          } else {
                            setState(() => _availabilityButtonColor = const Color(0xFFD6E7E2));
                            setState(() => _availabilityTextColor = const Color(0xFF868D8C));
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
                          if (_undergroundButtonColor == const Color(0xFFD6E7E2)) {
                            setState(() => _undergroundButtonColor = const Color(0xFF5DD5C7));
                            setState(() => _undergroundTextColor = Colors.white);
                          } else {
                            setState(() => _undergroundButtonColor = const Color(0xFFD6E7E2));
                            setState(() => _undergroundTextColor = const Color(0xFF868D8C));
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
                          if (_accessibleButtonColor == const Color(0xFFD6E7E2)) {
                            setState(() => _accessibleButtonColor = const Color(0xFF5DD5C7));
                            setState(() => _accessibleTextColor = Colors.white);
                          } else {
                            setState(() => _accessibleButtonColor = const Color(0xFFD6E7E2));
                            setState(() => _accessibleTextColor = const Color(0xFF868D8C));
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Maximum walking distance:',
                          style: TextStyle(
                            color: Color(0xFF474948),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 185),
                  child: Slider(
                    value: _currentSlider1Value,
                    max: 30,
                    divisions: 6,
                    label: _currentSlider1Value.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSlider1Value = value;
                      });
                    },
                ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Maximum price per hour:',
                          style: TextStyle(
                            color: Color(0xFF474948),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 265),
                  child: Slider(
                    value: _currentSlider2Value,
                    max: 120,
                    divisions: 12,
                    label: _currentSlider2Value.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSlider2Value = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 315),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _priceButtonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {
                      if (_priceButtonColor == const Color(0xFFD6E7E2)) {
                        setState(() => _priceButtonColor = const Color(0xFF5DD5C7));
                        setState(() => _priceTextColor = Colors.white);
                      } else {
                        setState(() => _priceButtonColor = const Color(0xFFD6E7E2));
                        setState(() => _priceTextColor = const Color(0xFF868D8C));
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 390),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Method of payment:',
                          style: TextStyle(
                            color: Color(0xFF474948),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 410),
                    child: Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: isCashChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isCashChecked = value!;
                        });
                      },
                    ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 425),
                        child: Text(
                          'Cash',
                          style: TextStyle(
                            color: Color(0xFF474948),
                            fontSize: 16,
                          ),
                        ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 440),
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: isCreditChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isCreditChecked = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 455),
                  child: Text(
                    'Credit card',
                    style: TextStyle(
                      color: Color(0xFF474948),
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 470),
                  child: Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: isPangoChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isPangoChecked = value!;
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 62, vertical: 485),
                  child: Text(
                    'Pango',
                    style: TextStyle(
                      color: Color(0xFF474948),
                      fontSize: 16,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 580),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF35858),
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ParkingLotsScreen(),
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