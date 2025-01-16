import 'package:flutter/material.dart';

class Colorclass {
  static const Color dustyPink = Color.fromARGB(255, 213, 173, 166);
  static const Color brown = Color.fromARGB(255, 50, 33, 30);
  static const Color lightgray = Color(0xffB2B2B2);

// حق الايقونات ابو لونين
  static const LinearGradient gradient = LinearGradient(
    colors: [dustyPink, brown],
    begin: Alignment.bottomRight,
    end: Alignment.bottomLeft,
  );

  static const gbrown = Color.fromARGB(255, 149, 133, 130);
  static const grey = Color.fromARGB(255, 219, 219, 219);
  static const white = Color.fromARGB(255, 255, 255, 255);

  static const Red = Color.fromARGB(255, 159, 0, 0);

  static const addicon = Color.fromARGB(170, 0, 0, 0);
  static const shelf = Color.fromARGB(112, 0, 0, 0);
  
}