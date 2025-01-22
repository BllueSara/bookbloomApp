import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/HomeScreen.dart';
import 'package:bookbloom/shelfbook.dart';
import 'package:bookbloom/writeingspaceScreen.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final int index; // إضافة المعامل index

  const MainPage({super.key, required this.index});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> pages = [];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;

    pages = [
      const HomePage(),
      const Writeingspacescreen(),
      const ShelfBook(),
    ];
  }

  var _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _currentIndex == 0
        ? Colorclass.gbrown // لون الخلفية للصفحة الرئيسية
        : Colorclass.white; // لون الخلفية للصفحات الأخرى
    return Scaffold(
      backgroundColor: backgroundColor,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colorclass.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colorclass.brown,
          unselectedItemColor: Colorclass.dustyPink,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 40),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories, size: 40),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark, size: 40),
              label: '',
            ),
          ],
          currentIndex: _currentIndex,
          onTap: onTap,
        ),
      ),
    );
  }

  onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}