/*
    This f
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phys/launch.dart';

void main() => runApp(MyApp());

// Entry screen for Flutter app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set status bar color to black on iOS
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black,
    ));

    // Return the basic material app
    return MaterialApp(
        title: 'AP Physics',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeWidget());
  }
}

// Initial screen with the welcome image and button.
// In reality, when the user clicks anywhere it will send them to the launch screen
class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LaunchScreen())),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/welcome.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
        child: null, // There literally isn't any content besides the image
      ),
    );
  }
}
