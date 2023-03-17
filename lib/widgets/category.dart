class Category {
  String thumbnail;
  String name;
  int noOfCourses;

  Category({
    required this.name,
    required this.noOfCourses,
    required this.thumbnail,
  });
}

List<Category> categoryList = [
  Category(
    name: 'Find a spot now',
    noOfCourses: 55,
    thumbnail: 'assets/images/parking_spot.png',
  ),
  Category(
    name: 'Plan a drive',
    noOfCourses: 20,
    thumbnail: 'assets/images/route.png',
  ),
  Category(
    name: 'Alert me',
    noOfCourses: 16,
    thumbnail: 'assets/images/plan.png',
  ),
  Category(
    name: 'Parking lots nearby',
    noOfCourses: 25,
    thumbnail: 'assets/images/parking_area.png',
  ),
];