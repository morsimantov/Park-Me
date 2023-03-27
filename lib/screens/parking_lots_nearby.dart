import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park_me/screens/search_screen.dart';
import '../data/dummy_parking_lots.dart';
import 'home_screen.dart';

class ParkingLotsNearbyScreen extends StatefulWidget {
  const ParkingLotsNearbyScreen({Key? key}) : super(key: key);

  @override
  State<ParkingLotsNearbyScreen> createState() => _ParkingLotsNearbyScreenState();
}

class _ParkingLotsNearbyScreenState extends State<ParkingLotsNearbyScreen> {
  Position? _currentUserPosition;
  double? distanceImMeter = 0.0;
  Data data = Data();

  Future _getTheDistance() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    _currentUserPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('current User Position: ');
    print(_currentUserPosition);

    for (int i = 0; i < data.allParkingLots.length; i++) {
      double parkingLotLat = data.allParkingLots[i]['lat'];
      double parkingLotLng = data.allParkingLots[i]['lng'];

      distanceImMeter = await Geolocator.distanceBetween(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
        parkingLotLat,
        parkingLotLng,
      );
      var distance = distanceImMeter?.round().toInt();

      data.allParkingLots[i]['distance'] = (distance! / 1000);
      setState(() {});
    }
  }

  @override
  void initState() {
    _getTheDistance();
    super.initState();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SearchScreen(title: '',),
            ));
      }
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
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        title: const Text("All Parking Lots Near you"),
      ),
      backgroundColor: const Color(0xFFB8E3D6),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: GridView.builder(

            itemCount: data.allParkingLots.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemBuilder: (context, index) {
              return Container(
                height: height * 0.9,
                width: width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xffd6e7e2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      blurRadius: 1.0,
                      spreadRadius: .1,
                    ), //BoxShadow
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: height * 0.15,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.teal,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            blurRadius: 6.0,
                            spreadRadius: .1,
                          ), //BoxShadow
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadiusDirectional.only(topEnd: Radius.circular(8.0), topStart: Radius.circular(8.0), ),
                        child: Image.network(
                          data.allParkingLots[index]['image'],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      data.allParkingLots[index]['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF626463),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                        color:Colors.teal),
                        Text(
                          "${data.allParkingLots[index]['distance'].round()} KM Away",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF626463),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
