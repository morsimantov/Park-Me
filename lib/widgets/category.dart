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
    name: 'Find a spot now',
    function: (context) => const SearchScreen(title: '',),
    thumbnail: 'assets/images/parking_spot.png',
  ),
  Category(
    name: 'Plan a drive',
    function: (context) => const PlanDriveScreen(title: '',),
    thumbnail: 'assets/images/route.png',
  ),
  Category(
    name: 'Alert me',
    function: (context) => const PlanDriveScreen(title: '',),
    thumbnail: 'assets/images/plan.png',
  ),
  Category(
    name: 'Parking lots nearby',
    function: (context) => const SearchScreen(title: '',),
    thumbnail: 'assets/images/parking_area.png',
  ),
];