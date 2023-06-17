import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:park_me/screens/plan_drive_result_screen.dart';
import 'package:park_me/screens/plan_lot_result_screen.dart';
import 'package:park_me/screens/search_screen.dart';
import 'package:uuid/uuid.dart';
import '../env.sample.dart';
import '../model/filter_parameters.dart';
import '../model/parking_lot.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import '../config/strings.dart';
import '../utils.dart';

class PlanDriveScreen extends StatefulWidget {
  const PlanDriveScreen({super.key, required this.title});

  final String title;

  @override
  State<PlanDriveScreen> createState() => _PlanDriveScreenState();
}

class _PlanDriveScreenState extends State<PlanDriveScreen> {
  static const String _appBarTitle = "Plan a Drive in Advance";
  static const String _byAddressTab = "BY ADDRESS";
  static const String _byLotTab = "BY PARKING LOT";
  static const String _hintTextDestination = "Enter a destination";
  static const String _chooseDayText = "Choose a day:";
  static const String _chooseTimeText = "Choose a time:";
  static const String _submitButton = "Find Parking";
  static const String _hintTextLot = "Enter a parking lot name";
  static const String _lotNotFound = "Parking Lot Not Found";
  static const String _lotNotFoundText = "Please enter a valid parking lot name";
  static const double _fontSize = 16;

  int _selectedIndex = 0;
  String _dropdownValue = weekDaysList.first;
  bool _showSuggestionsAddress = false; // Flag to track suggestion list visibility
  late List<ParkingLot> _parkingLots = [];
  late List<String> _parkingLotsNames = [];
  String _inputString = '';
  final _searchControllerAddress = TextEditingController();
  var _uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  // create TimeOfDay variable
  TimeOfDay _timeOfDay = const TimeOfDay(hour: 8, minute: 30);

  @override
  void initState() {
    super.initState();
    createLotsSuggestions();
    _searchControllerAddress.addListener(() {
      onChangedAddress();
    });
  }

  void onChangedAddress() {
    // Generate a session token if it doesn't exist
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = _uuid.v4();
      });
    }
    // Get place suggestions based on the input address
    getSuggestion(_searchControllerAddress.text);
  }

  void getSuggestion(String input) async {
    const String errorMessage = "Failed to load predictions";
    // Define the Places API key and type
    String kPLACES_API_KEY = "AIzaSyC4VmB_2iR5E6wN_mU3Fqcn19HxHqRGTDo";
    String type = '(regions)';
    try {
      // Construct the request URL with the input, API key, and session token
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      // Send a GET request to the Google Places Autocomplete API
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        // If the response status code is 200 (success), update the state with the predictions
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        // If the response status code is not 200, throw an exception or handle the error
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Handle the error
    }
  }

  void createLotsSuggestions() async {
    String type = '(regions)';
    try {
      // Send a GET request to retrieve parking lot data from the server
      final response = await http.get(Uri.parse(Env.URL_PREFIX));
      final decodedResponse = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        // Decode the response JSON and cast it to a list of maps
        final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
        // Map the JSON data to ParkingLot objects
        List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
          return ParkingLot.fromJson(json);
        }).toList();
        setState(() {
          // Add the fetched parking lots to the _parkingLots list
          _parkingLots.addAll(parkingLotsTemp);
          // Extract the lot names from the parking lots and add them to the _parkingLotsNames list
          for (var lot in _parkingLots) {
            _parkingLotsNames.add(lot.lot_name);
          }
        });
      } else {
        // If the response status code is not 200, throw an exception or handle the error
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // Handle the error
    }
  }

  bool validateLot(String lot) {
    // If the list of the lots' names contains the name of the lot, return true
    if (_parkingLotsNames.contains(lot)) {
      return true;
    }
    return false;
  }

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

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ));
      }
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(
                title: '',
                filterStatus: FilterParameters(
                    false, false, false, false, false, false, false),
              ),
            ));
      } else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FavoritesScreen(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: _byAddressTab,
                ),
                Tab(
                  text: _byLotTab,
                ),
              ],
            ),
            backgroundColor: const Color(0xFF03A295),
            title: const Text(_appBarTitle),
          ),
          backgroundColor: const Color(0xfff6f7f9),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color(0xe4e8eaf1),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: searchLabel,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: homeLabel,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: favoritesLabel,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xff67686b),
            onTap: onItemTapped,
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 80, left: 30, right: 30),
                          child: TextField(
                            onSubmitted: (value) {
                              setState(() {
                                _showSuggestionsAddress =
                                false; // Show suggestions on text field tap
                              });
                            },
                            onTap: () {
                              setState(() {
                                _showSuggestionsAddress =
                                true; // Show suggestions on text field tap
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xe4f5f5f8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: _hintTextDestination,
                              hintStyle: const TextStyle(
                                fontFamily: fontFamilyMiriam,
                              ),
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  _searchControllerAddress.clear();
                                },
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            controller: _searchControllerAddress,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 205),
                      child: Text(
                        _chooseDayText,
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: Color(0xFF474948),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 185),
                      child: DropdownButton<String>(
                        value: _dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(
                            color: Colors.black, fontFamily: fontFamilyMiriam),
                        underline: Container(
                          height: 2,
                          color: Colors.black,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _dropdownValue = value!;
                          });
                        },
                        items:
                        weekDaysList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 295),
                      child: Text(
                        _chooseTimeText,
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: Color(0xFF474948),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 160, vertical: 280),
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
                        padding: const EdgeInsets.symmetric(vertical: 390,),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF03A295),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 130, vertical: 12),
                          ),
                          onPressed: () async {
                            print(_searchControllerAddress.value.text);
                            String address =
                                _searchControllerAddress.value.text;
                            bool isValid = await validateAddress(address);
                            if (!isValid) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: addressNotFound,
                                text: addressNotFoundText,
                                confirmBtnColor: const Color(0xFF03A295),
                              );
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlanDriveResultScreen(
                                      wantedLocationAddress: address,
                                      day: _dropdownValue,
                                      timeOfDay:
                                      _timeOfDay.format(context).toString(),
                                    ),
                                  ));
                            }
                          },
                          child: const Text(
                            _submitButton,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _fontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 142,
                      left: 32,
                      right: 32,
                      child: _showSuggestionsAddress // Only show suggestion list when the flag is true
                          ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _placeList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showSuggestionsAddress =
                                  false; // Hide suggestion list
                                  // double longitude = locations.last.longitude;
                                  // double latitude = locations.last.latitude;
                                  _searchControllerAddress.value =
                                      _searchControllerAddress.value
                                          .copyWith(
                                        text: _placeList[index]
                                        ['description'],
                                      );
                                });
                              },
                              child: Container(
                                color: const Color(0xe4f5f5f8),
                                child: ListTile(
                                  tileColor: const Color(0xe4f5f5f8),
                                  title: Text(
                                      _placeList[index]["description"]),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                          : const SizedBox(), // Empty SizedBox when the suggestion list is hidden
                    ),
                  ],
                ),
              ),

              // second tab - by parking lot
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 80, left: 30, right: 30),
                          child: Autocomplete(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              setState(() {
                                _inputString = textEditingValue.text;
                              });
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              } else {
                                List<String> matches = <String>[];
                                matches.addAll(_parkingLotsNames);
                                matches.retainWhere((s) {
                                  return s.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase());
                                });
                                return matches.take(5).toList();
                              }
                            },
                            optionsViewBuilder: (BuildContext context, onSelected, Iterable<dynamic> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  width: 350,
                                  decoration: BoxDecoration(
                                    color: const Color(0xe4f5f5f8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final option = options.elementAt(index);
                                      return GestureDetector(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Container(
                                          color: const Color(0xe4f5f5f8),
                                          child: ListTile(
                                            title: Text(
                                              option.toString(),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            onSelected: (String selection) {
                              _inputString = selection;
                              print('You just selected $selection');
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController
                                fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              return TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                decoration: InputDecoration(
                                  prefixIcon: IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      fieldTextEditingController.clear();
                                    },
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xe4f5f5f8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  hintText: _hintTextLot,
                                  hintStyle: const TextStyle(
                                    fontFamily: fontFamilyMiriam,
                                  ),),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 205),
                      child: Text(
                        _chooseDayText,
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: Color(0xFF474948),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 185),
                      child: DropdownButton<String>(
                        value: _dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(
                            color: Colors.black, fontFamily: fontFamilyMiriam),
                        underline: Container(
                          height: 2,
                          color: Colors.black,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            _dropdownValue = value!;
                          });
                        },
                        items:
                        weekDaysList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 295),
                      child: Text(
                        _chooseTimeText,
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: Color(0xFF474948),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 160, vertical: 280),
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
                        padding: const EdgeInsets.symmetric(vertical: 390),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF03A295),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 130, vertical: 12),
                          ),
                          onPressed: () async {
                            bool isValid = validateLot(_inputString);
                            if (!isValid) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: _lotNotFound,
                                text: _lotNotFoundText,
                                confirmBtnColor: const Color(0xFF03A295),
                              );
                            } else {
                              ParkingLot selectedLot = _parkingLots
                                  .where((element) =>
                              element.lot_name == _inputString)
                                  .toList()
                                  .first;
                              int selectedLotId = selectedLot.lot_id;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlanLotResultScreen(
                                      wantedLotName: _inputString,
                                      wantedLotId: selectedLotId,
                                      day: _dropdownValue,
                                      timeOfDay: _timeOfDay.format(context).toString(),
                                    ),
                                  ));
                            }
                          },
                          child: const Text(
                            _submitButton,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _fontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}