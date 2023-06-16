import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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
  bool _showSuggestionsAddress =
      false; // Flag to track suggestion list visibility
  late List<ParkingLot> parkingLots = [];
  late List<String> parkingLotsNames = [];
  String _inputString = '';
  final _searchControllerAddress = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  void _onChangedAddress() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_searchControllerAddress.text);
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

  void createLotsSuggestions() async {
    String type = '(regions)';
    try {
      final response = await http.get(Uri.parse(Env.URL_PREFIX));
      // final response =
      // await http.get(Uri.parse("${Env.URL_PREFIX}/lots"));
      print("response");
      final decodedResponse = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
        List<ParkingLot> parkingLotsTemp = items.map<ParkingLot>((json) {
          return ParkingLot.fromJson(json);
        }).toList();
        setState(() {
          parkingLots.addAll(parkingLotsTemp);
          for (var lot in parkingLots) {
            parkingLotsNames.add(lot.lot_name);
          }
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  Future<bool> validateAddress(String address) async {
    try {
      // Perform geocoding with the provided address
      List<Location> locations = await locationFromAddress(address);

      // If the geocoding is successful and returns at least one location,
      // consider the address as valid
      return locations.isNotEmpty;
    } catch (e) {
      // Error occurred during geocoding, so the address is considered invalid
      return false;
    }
  }

  bool validateLot(String lot) {
    if (parkingLotsNames.contains(lot)) {
      return true;
    }
    return false;
  }

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
  void initState() {
    super.initState();
    createLotsSuggestions();
    _searchControllerAddress.addListener(() {
      _onChangedAddress();
    });
    // _searchControllerLot.addListener(() {
    //   _onChangedLot();
    // });
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
                  text: 'BY ADDRESS',
                ),
                Tab(
                  text: 'BY PARKING LOT',
                ),
              ],
            ),
            backgroundColor: const Color(0xFF03A295),
            title: const Text("Plan a Drive in Advance"),
          ),
          backgroundColor: const Color(0xfff6f7f9),
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
            selectedItemColor: const Color(0xff67686b),
            onTap: _onItemTapped,
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Stack(
                  children: [
                    // const Align(
                    //     alignment: Alignment.centerLeft,
                    //     child:
                    //     Padding(
                    //       padding: EdgeInsets.only(left: 30, top: 57),
                    //       child: Text(
                    //         'Find a parking lot in advance:',
                    //         style: TextStyle(
                    //           color: Color(0xFF474948),
                    //           fontSize: 18,
                    //           // fontFamily: 'MiriamLibre',
                    //         ),
                    //       ),
                    //     )
                    // ),

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
                              fillColor: Color(0xe4f5f5f8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: 'Enter a destination',
                              hintStyle: const TextStyle(
                                fontFamily: 'MiriamLibre',
                              ),
                              prefixIcon: IconButton(
                                icon: Icon(Icons.cancel),
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
                        'Choose a day:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF474948),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 185),
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(
                            color: Colors.black, fontFamily: 'MiriamLibre'),
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
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
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
                        'Choose a time:',
                        style: TextStyle(
                          fontSize: 16,
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
                                title: 'Address Not Found',
                                text: 'Please enter a valid address',
                                confirmBtnColor: const Color(0xFF03A295),
                              );
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlanDriveResultScreen(
                                      wantedLocationAddress: address,
                                      day: dropdownValue,
                                      timeOfDay:
                                          _timeOfDay.format(context).toString(),
                                    ),
                                  ));
                            }
                          },
                          child: const Text(
                            'Find Parking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
                                    offset: Offset(0, 2),
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
                          : SizedBox(), // Empty SizedBox when the suggestion list is hidden
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
                                matches.addAll(parkingLotsNames);
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
                                        offset: Offset(0, 2),
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
                                    hintText: 'Enter a parking lot name',
                                      hintStyle: const TextStyle(
                                        fontFamily: 'MiriamLibre',
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
                        'Choose a day:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF474948),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 185),
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(
                            color: Colors.black, fontFamily: 'MiriamLibre'),
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
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
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
                        'Choose a time:',
                        style: TextStyle(
                          fontSize: 16,
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
                                title: 'Parking Lot Not Found',
                                text: 'Please enter a valid parking lot name',
                                confirmBtnColor: const Color(0xFF03A295),
                              );
                            } else {
                              ParkingLot selectedLot = parkingLots
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
                                      day: dropdownValue,
                                      timeOfDay: _timeOfDay.format(context).toString(),
                                    ),
                                  ));
                            }
                          },
                          child: const Text(
                            'Find Parking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
