import 'package:geocoding/geocoding.dart';
import 'config/strings.dart';
import 'env.sample.dart';
import 'package:http/http.dart' as http;

Future<String> getAddressFromCoordinates(
    double latitude, double longitude) async {
  const String errorMessage = "Address not found";
  try {
    // Retrieve the list of placemarks from the provided coordinates
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latitude, longitude);
    if (placemarks != null && placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      // Extract relevant address components and format the address
      String address =
          '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      return address;
    }
  } catch (e) {
    // Handle any errors that occur during the address retrieval process
    print('Error: $e');
  }
  // Return an error message if the address couldn't be retrieved
  return errorMessage;
}

Future<bool> validateAddress(String address) async {
  try {
    // Perform geocoding with the provided address
    List<Location> locations = await locationFromAddress(address);
    /*
       If the geocoding is successful and returns at least one location,
       consider the address as valid.
       */

    return locations.isNotEmpty;
  } catch (e) {
    // Error occurred during geocoding, so the address is considered invalid
    return false;
  }
}

int convertToWalkingDistance(double distanceInKm) {
  // Assuming an average walking speed of 5 kilometers per hour
  double walkingSpeedKph = 5.0;
  // Convert walking speed from kilometers per hour to kilometers per minute
  double walkingSpeedKpm = walkingSpeedKph / 60.0;
  // Calculate the walking time in minutes
  double walkingTimeMinutes = distanceInKm / walkingSpeedKpm;
  return walkingTimeMinutes.round();
}

double convertToKilometers(double timeInMinutes) {
  double walkingSpeed = 5.0; // 5 km/h is an average walking speed
  double timeInHours = timeInMinutes / 60;
  double distanceInKm = walkingSpeed * timeInHours;
  return distanceInKm;
}

Future<void> addToFavorites(String uid, int lot_id) async {
  // Construct the API endpoint URL
  final url = "${Env.URL_PREFIX}/favorites/add/";
  try {
    // Send a POST request to the API endpoint
    final response = await http.post(
      Uri.parse(url),
      body: {
        'uid': uid,
        'lot_id': lot_id.toString(),
      },
    );
    if (response.statusCode == 200) {
      print(addedSuccessfullyMsg);
    } else {
      print('$addErrorMsg Error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> removeFromFavorites(String uid, int lot_id) async {
  // Construct the API endpoint URL with the user ID and lot ID
  final url = "${Env.URL_PREFIX}/favorites/remove/$uid/$lot_id";
  try {
    // Send a DELETE request to the API endpoint
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      print(removedSuccessfullyMsg);
    } else {
      print('$removeErrorMsg Error: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
