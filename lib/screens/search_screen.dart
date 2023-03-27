import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:park_me/screens/parking_lots_screen.dart';
import '../widgets/search_bar.dart';
import 'filter_screen.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

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
    String kPLACES_API_KEY = "AIzaSyC4VmB_2iR5E6wN_mU3Fqcn19HxHqRGTDo";
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
      backgroundColor: const Color(0xFFDBF8EE),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: TextField(
              onSubmitted: (value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParkingLotsScreen(),
               ));
              },
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search",
                focusColor: Colors.white,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixIcon: const Icon(Icons.search),
                // InkWell(
                //   child: const Icon(
                //     Icons.tune,
                //     color: Color(0xFF626463),
                //   ),
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => const FilterScreen(
                //             title: '',
                //           ),
                //         ));
                //   },
                // ),
                suffixIcon: Container(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          print('add button pressed');
                        },
                        icon:  InkWell(
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          _controller.clear();
                        },
                      ),
                    ],
                  ),
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
                  onTap: () async {
                    List<Location> locations = await locationFromAddress(
                        _placeList[index]['description']);
                    print(locations.last.longitude);
                    print(locations.last.latitude);
                    _controller.value = _controller.value.copyWith(
                      text: _placeList[index]['description'],);
                  },
                  child: ListTile(
                    title: Text(_placeList[index]["description"]),
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
