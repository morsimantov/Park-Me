import 'package:flutter/material.dart';
import 'home_screen.dart';

const List<String> list = <String>[
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday'
];

class PlanDriveScreen extends StatefulWidget {
  const PlanDriveScreen({super.key, required this.title});

  final String title;

  @override
  State<PlanDriveScreen> createState() => _PlanDriveScreenState();
}

class _PlanDriveScreenState extends State<PlanDriveScreen> {
  int _selectedIndex = 0;
  String dropdownValue = list.first;

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
    });
  }

  // create TimeOfDay variable
  TimeOfDay _timeOfDay = const TimeOfDay(hour: 8, minute: 30);

  // show time picker method
  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((value) {
      setState(() {
        _timeOfDay = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF03A295),
        title: const Text("Plan a Drive in Advance"),
      ),
      backgroundColor: const Color(0xfff6f7f9),
      // bottomNavigationBar: Container(
      //   height: 80,
      //   width: double.infinity,
      //   padding: const EdgeInsets.all(10),
      //   color: Colors.teal,
      //   child: const Padding(
      //     padding: EdgeInsets.only(bottom: 10),
      //   ),
      //
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
        selectedItemColor: const Color(0xFF03A295),
        onTap: _onItemTapped,
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  // Positioned(
                  //   left: 8,
                  //   top: 35,
                  //   child: Image.asset(
                  //     'assets/images/logo_parkme.png',
                  //     height: 60,
                  //     width: 60,
                  //     fit: BoxFit.fitWidth,
                  //   ),
                  // ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 88, vertical: 80),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Find a parking lot in advance:',
                        style: TextStyle(
                          color: Color(0xFF474948),
                          fontSize: 18,
                          // fontFamily:'MiriamLibre',
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 165),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a destination',
                      ),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 270),
                    child: Text(
                      'Choose a day:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF474948),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 150, vertical: 250),
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.black,
                      ),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      items: list.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 340),
                    child: Text(
                      'Choose an hour:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF474948),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 160, vertical: 325),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF55C0B3),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      onPressed: _showTimePicker,
                      child: Text(
                        _timeOfDay.format(context).toString(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 450),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03A295),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 12),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Plan a Drive',
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
