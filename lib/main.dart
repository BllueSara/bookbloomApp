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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
