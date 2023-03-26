import 'dart:async';
import 'package:flutter/material.dart';
import 'package:park_me/screens/home_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isVisible = false;

  _HomePageState(){

    Timer(const Duration(milliseconds: 3000), (){
      setState(() {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen(title: '',)), (route) => false);
      });
    });

    Timer(
        const Duration(milliseconds: 10),(){
      setState(() {
        _isVisible = true; // Now it is showing fade effect and navigating to Login page
      });
    }
    );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.tealAccent, Colors.white],
            begin: FractionalOffset(0, 0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,

        ),
      ),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 1200),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Center(
                child: SizedBox(
                  height: 140.0,
                  width: 140.0,
                  child: Center(
                    child: ClipOval(
                      child: Image.asset('assets/images/logo_parkme.png'),
                    ),
                  ),
                )
            ),
            // ElevatedButton(
            //   style: const ButtonStyle(
            //     backgroundColor: MaterialStatePropertyAll<Color>(Colors.teal),
            //   ),
            //   child: Text('Begin'),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => SearchPage(),
            //       ),
            //     );
            //   },
            // )
          ],
        )
      ),
    );
  }
}
