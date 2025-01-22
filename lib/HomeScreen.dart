import 'dart:io';

import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/profile.dart';
import 'package:bookbloom/readbookScreen.dart';
import 'package:bookbloom/searchscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? profilePicture; // لتخزين مسار الصورة
  String selectedCategory = 'Novel'; // الفئة الافتراضية

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicture =
          prefs.getString('profilePicture') ?? 'images/avatar1.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: Colorclass.gbrown,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Profile(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage:
                            profilePicture != null && profilePicture!.isNotEmpty
                                ? (profilePicture!.startsWith('images/')
                                    ? AssetImage(profilePicture!)
                                    : FileImage(File(profilePicture!)))
                                : const AssetImage('images/avatar1.png')
                                    as ImageProvider,
                        radius: 20,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      Textclass.WhatDo,
                      style:
                          TextStyles.Bold30.copyWith(color: Colorclass.brown),
                    ),
                    const SizedBox(height: 20),
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
                              border: Border.all(color: Colors.black),
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
                    TabBar(
                      labelColor: Colorclass.brown,
                      unselectedLabelColor: Colorclass.brown,
                      isScrollable: true,
                      indicatorColor: Colorclass.brown,
                      dividerColor: Colorclass.white,
                      indicatorWeight: 3.0,
                      indicatorPadding: const EdgeInsets.only(bottom: 15),
                      tabs: const [
                        Tab(text: 'Novel'),
                        Tab(text: 'Self-love'),
                        Tab(text: 'Science'),
                        Tab(text: 'Romance'),
                        Tab(text: 'Tragedy'),
                        Tab(text: 'Other'),
                      ],
                      onTap: (index) {
                        setState(() {
                          selectedCategory = [
                            'Novel',
                            'Self-love',
                            'Science',
                            'Romance',
                            'Tragedy',
                            'Other'
                          ][index];
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Body
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('stories')
                        .where('selectedCategories',
                            arrayContains: selectedCategory)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No stories found'));
                      }

                      final stories = snapshot.data!.docs;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2 / 3,
                        ),
                        itemCount: stories.length,
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return GestureDetector(
                            onTap: () async {
                              final authorUsername =
                                  story['author']; // الـ username للمؤلف

                              // استرجاع الـ bio باستخدام الـ username
                              QuerySnapshot authorQuery =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .where('username',
                                          isEqualTo: authorUsername)
                                      .limit(1)
                                      .get();

                              if (authorQuery.docs.isNotEmpty) {
                                // نحصل على الـ bio من أول مستند في النتيجة
                                String bio = authorQuery.docs.first['bio'] ??
                                    'Bio not available';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadBookScreen(
                                      title: story['title'] ??
                                          'No Title Available',
                                      imageUrl: story['imageUrl'] ??
                                          'default_image_url',
                                      overview: story['description'] ??
                                          'No description available',
                                      author:
                                          story['author'] ?? 'Unknown Author',
                                      bio: bio,
                                    ),
                                  ),
                                );
                              } else {
                                // في حالة عدم وجود الـ username في users
                                String bio = 'Bio not available';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadBookScreen(
                                      title: story['title'] ??
                                          'No Title Available',
                                      imageUrl: story['imageUrl'] ??
                                          'default_image_url',
                                      overview: story['description'] ??
                                          'No description available',
                                      author:
                                          story['author'] ?? 'Unknown Author',
                                      bio: bio,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(story['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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