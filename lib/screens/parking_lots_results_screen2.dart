import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:park_me/model/parking_lot.dart';
import 'dart:convert';
import '../env.sample.dart';

class ParkingLotsResultsScreen extends StatefulWidget {
  const ParkingLotsResultsScreen({super.key});

  @override
  ParkingLotsResultsScreenState createState() => ParkingLotsResultsScreenState();
}

class ParkingLotsResultsScreenState extends State<ParkingLotsResultsScreen> {
  late Future<List<ParkingLot>> parkingLots;
  final parkinglotListKey = GlobalKey<ParkingLotsResultsScreenState>();

  @override
  void initState() {
    super.initState();
    parkingLots = getParkingLotList();
  }

  Future<List<ParkingLot>> getParkingLotList() async {
    final response = await http.get(Uri.parse("${Env.URL_PREFIX}/api"));
    print("response");
    final decodedResponse = utf8.decode(response.bodyBytes);
    final items = json.decode(decodedResponse).cast<Map<String, dynamic>>();
    List<ParkingLot> parkingLots = items.map<ParkingLot>((json) {
      return ParkingLot.fromJson(json);
    }).toList();

    return parkingLots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: parkinglotListKey,
      appBar: AppBar(
        title: const Text('Parking lots List'),
      ),
      body: Center(
        child: FutureBuilder<List<ParkingLot>>(
          future: parkingLots,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // By default, show a loading spinner.
            if (!snapshot.hasData) return CircularProgressIndicator();
            // Render ParkingLot lists
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var data = snapshot.data[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.add_business_outlined),
                    title: Text(
                      data.lot_name,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}