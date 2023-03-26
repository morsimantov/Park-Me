import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import 'filter_screen.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.title});

  final String title;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 0;

  Color _availabilityButtonColor =  const Color(0xFFD6E7E2);
  Color _availabilityTextColor = const Color(0xFF868D8C);

  Color _undergroundButtonColor =  const Color(0xFFD6E7E2);
  Color _undergroundTextColor = const Color(0xFF868D8C);

  Color _accessibleButtonColor =  const Color(0xFFD6E7E2);
  Color _accessibleTextColor = const Color(0xFF868D8C);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(title: '',),
            ));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      // backgroundColor: const Color(0xFFB8E3D6),
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
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBEEFE0), Color(0xFFD7F3EA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 22,
                  child: Image.asset('assets/images/logo_parkme.png', height: 60,
                    width: 60, fit: BoxFit.fitWidth,),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 88, vertical: 105),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Enter your destination:',
                          style: TextStyle(
                            color: Color(0xFF474948),
                            fontSize: 20,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                    ],
                  ),
                ),
                const SearchBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 216),
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
                      const Spacer(),
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
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accessibleButtonColor,
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
                      const Spacer(),
                      InkWell(
                        child: const Icon(
                          Icons.tune,
                          color: Color(0xFF626463),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FilterScreen(title: '',),
                              ));
                        },
                      ),
                    ],
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