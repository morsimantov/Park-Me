import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import 'filter_screen.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.title});

  final String title;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 0;

  Color _availabilityButtonColor = const Color(0xFFD6E7E2);
  Color _availabilityTextColor = const Color(0xFF868D8C);

  Color _undergroundButtonColor = const Color(0xFFD6E7E2);
  Color _undergroundTextColor = const Color(0xFF868D8C);

  Color _accessibleButtonColor = const Color(0xFFD6E7E2);
  Color _accessibleTextColor = const Color(0xFF868D8C);

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

  var _controller = TextEditingController();
  var uuid = new Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onChanged();
    });
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY = "your api";
    String type = '(regions)';

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print('mydata');
      print(data);
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find a Parking spot"),
      ),
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
              children: <Widget>[
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 88, vertical: 60),
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
                Container(
                  width: 430,
                  height: 50,
                  margin:
                  const EdgeInsets.symmetric(vertical: 105, horizontal: 30),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(29.5),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search",
                      icon: Icon(Icons.search),
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          _controller.clear();
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _placeList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {},
                        child: ListTile(
                          title: Text(_placeList[index]["description"]),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 162),
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
                            setState(() => _availabilityButtonColor =
                            const Color(0xFF5DD5C7));
                            setState(
                                    () => _availabilityTextColor = Colors.white);
                          } else {
                            setState(() => _availabilityButtonColor =
                            const Color(0xFFD6E7E2));
                            setState(() => _availabilityTextColor =
                            const Color(0xFF868D8C));
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
                          if (_undergroundButtonColor ==
                              const Color(0xFFD6E7E2)) {
                            setState(() => _undergroundButtonColor =
                            const Color(0xFF5DD5C7));
                            setState(
                                    () => _undergroundTextColor = Colors.white);
                          } else {
                            setState(() => _undergroundButtonColor =
                            const Color(0xFFD6E7E2));
                            setState(() => _undergroundTextColor =
                            const Color(0xFF868D8C));
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
                          if (_accessibleButtonColor ==
                              const Color(0xFFD6E7E2)) {
                            setState(() => _accessibleButtonColor =
                            const Color(0xFF5DD5C7));
                            setState(() => _accessibleTextColor = Colors.white);
                          } else {
                            setState(() => _accessibleButtonColor =
                            const Color(0xFFD6E7E2));
                            setState(() =>
                            _accessibleTextColor = const Color(0xFF868D8C));
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
                                builder: (_) => const FilterScreen(
                                  title: '',
                                ),
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
