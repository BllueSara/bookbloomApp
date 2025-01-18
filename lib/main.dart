import 'package:bookbloom/HomeScreen.dart';
import 'package:bookbloom/SplachScreen.dart';
import 'package:bookbloom/WriteStoryScreen.dart';
import 'package:bookbloom/mainpage.dart';
import 'package:bookbloom/profile.dart';
import 'package:bookbloom/readingprofile.dart';
import 'package:bookbloom/resetpassword.dart';
import 'package:bookbloom/searchscreen.dart';
import 'package:bookbloom/shelfbook.dart';
import 'package:bookbloom/writeingspaceScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splachscreen()
    );
  }
}
