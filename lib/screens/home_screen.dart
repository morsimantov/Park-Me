import 'package:flutter/material.dart';
import 'package:park_me/screens/search_screen.dart';
import '../widgets/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required String title}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Transform.rotate(
                  origin: const Offset(30, -60),
                  angle: 2.4,
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 75,
                      top: 40,
                    ),
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft,
                        colors: [Color(0xfff5d7df), Color(0xFFDE79C0)],
                        // colors: [Color(0xfff5d7df), Color(0xFFDE79C0)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 7,
                  top: 18,
                  child: Image.asset(
                    'assets/images/logo_parkme.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 88, vertical: 75),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Find a parking spot',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'by your own preferences',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                    top: 170,
                    left: 30,
                    right: 30,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 18,
                  ),
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      category: categoryList[index],
                    );
                  },
                  itemCount: categoryList.length,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: category.function,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xdfffffff),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 4.0,
              spreadRadius: .05,
            ), //BoxShadow
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                category.thumbnail,
                height: 110.0,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            // Text(
            //   "${category.noOfCourses.toString()} courses",
            //   style: Theme.of(context).textTheme.bodySmall,
            // ),
          ],
        ),
      ),
    );
  }
}
