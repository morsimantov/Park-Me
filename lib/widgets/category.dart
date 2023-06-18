import 'package:park_me/screens/favorites_screen.dart';
import 'package:park_me/screens/parking_lots_nearby.dart';

import '../model/filter_parameters.dart';
import '../screens/plan_drive_screen.dart';
import '../screens/search_screen.dart';

class Category {
  String thumbnail;
  String name;
  var function;

  Category({
    required this.name,
    required this.function,
    required this.thumbnail,
  });
}

List<Category> categoryList = [
  Category(
    name: 'Find a Spot Now',
    function: (context) => SearchScreen(
      title: '',
      filterStatus:
          FilterParameters(false, false, false, false, false, false, false),
    ),
    thumbnail: 'assets/images/1.png',
  ),
  Category(
    name: 'Plan a Drive',
    function: (context) => const PlanDriveScreen(
      title: '',
    ),
    thumbnail: 'assets/images/3.png',
  ),
  Category(
    name: 'Favorites\n (Saved Lots)',
    function: (context) => const FavoritesScreen(),
    thumbnail: 'assets/images/2.png',
  ),
  Category(
    name: 'Parking Lots Nearby',
    function: (context) => const ParkingLotsNearbyScreen(),
    thumbnail: 'assets/images/5.png',
  ),
];
