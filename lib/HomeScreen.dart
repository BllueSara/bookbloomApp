import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/profile.dart';
import 'package:bookbloom/readbookScreen.dart';
import 'package:bookbloom/searchscreen.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colorclass.gbrown,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colorclass.white,
              height: 320,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 30, bottom: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // الانتقال إلى صفحة البروفايل عند الضغط
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const Profile(), // صفحة البروفايل
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage('images/avatar1.png'), // صورة البروفايل
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      Textclass.WhatDo,
                      style:
                          TextStyles.Bold30.copyWith(color: Colorclass.brown),
                    ),
                    const SizedBox(height: 20),
                    // مربع البحث
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 30),
                      child: Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return const SearchScreen();
                              },
                            ));
                          },
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 30,
                              maxHeight: 32,
                            ),
                            decoration: BoxDecoration(
                              color: Colorclass.grey,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.black), // حدود شفافة
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.search,
                                      color: Colorclass.brown),
                                ),
                                Expanded(
                                  child: Text(
                                    Textclass.author,
                                    style: TextStyles.normal16
                                        .copyWith(color: Colorclass.brown),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.close,
                                      color: Colorclass.brown),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TabBar(
                      labelColor: Colorclass.brown,
                      unselectedLabelColor: Colorclass.brown,
                      isScrollable: true,
                      indicatorColor: Colorclass.brown,
                      dividerColor: Colorclass.white,
                      indicatorWeight: 3.0,
                      indicatorPadding: EdgeInsets.only(bottom: 15),
                      tabs: [
                        Tab(text: 'Novel'),
                        Tab(text: 'Self-love'),
                        Tab(text: 'Science'),
                        Tab(text: 'Romance'),
                        Tab(text: 'Tragedy'),
                        Tab(text: 'Other'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: Colorclass.white,
                    height: 50,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colorclass.gbrown,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 80),
                  ),
                  // محتوى GridView
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 20.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // انتقال إلى صفحة قراءة الكتاب
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReadBookScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image:
                                    AssetImage('images/book${index + 1}.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
