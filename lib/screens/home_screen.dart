import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:park_me/config/strings.dart';
import 'package:park_me/provider/google_sign_in.dart';
import 'package:park_me/screens/sign_up_screen.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../widgets/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _userLoggedText = "User: ";
  static const String _userLogoutText = "Logout";
  static const String _logoutMessage = "Do you want to logout";
  static const String _logoutYes = "Yes";
  static const String _logoutNo = "No";
  static const String _headline = "Find a parking spot";
  static const String _subtitle = "by your own preferences";
  static const String _signInErrorMessage = "Something Went Wrong!";
  static const double _fontSize = 16;
  static const double _fontSizeTitle = 24;
  static const double _fontSizeSubtitle = 18;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  backgroundColor: backgroundColor,
                  body: Center(
                    child: CircularProgressIndicator(),
                  ));
            } else if (snapshot.hasData) {
              final user = FirebaseAuth.instance.currentUser!;
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: backgroundColorAppBar,
                  automaticallyImplyLeading: false,
                  title: Text(_userLoggedText + user.displayName!,
                      style: const TextStyle(
                        fontSize: _fontSize,
                      )),
                  centerTitle: false,
                  actions: [
                    TextButton(
                      child: const Text(
                        _userLogoutText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _fontSize,
                        ),
                      ),
                      onPressed: () {
                        QuickAlert.show(
                            context: context,
                            type: QuickAlertType.confirm,
                            text: _logoutMessage,
                            confirmBtnText: _logoutYes,
                            cancelBtnText: _logoutNo,
                            confirmBtnColor: const Color(0xFF03A295),
                            onConfirmBtnTap: () {

                              final provider =
                                  Provider.of<GoogleSignInProvider>(context,
                                      listen: false);
                              provider.logout();
                            });
                      },
                    ),
                  ],
                ),
                backgroundColor: const Color(0xffebecf3),
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
                                  colors: [
                                    Color(0xffd6e6e6),
                                    Color(0xffaad3cb),
                                  ],
                                  // colors: [Color(0xfff5d7df), Color(0xFFDE79C0)],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 37),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    _headline,
                                    style: TextStyle(
                                      color: Color(0xEC037268),
                                      fontSize: _fontSizeTitle,
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
                                    _subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xEC037268),
                                      fontSize: _fontSizeSubtitle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(
                              top: 124,
                              left: 30,
                              right: 30,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 18,
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
            } else if (snapshot.hasError) {
              return const Center(child: Text(_signInErrorMessage));
            } else {
              return SignUpScreen();
            }
          }),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  static const double _fontSize = 16;

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
          color: const Color(0xddffffff),
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
                  fontSize: _fontSize,
                  fontFamily: fontFamilyMiriam,
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
