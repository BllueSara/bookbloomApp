import 'dart:io';

import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/readbookScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Readingprofile extends StatefulWidget {
  final String authorId; // معرّف الكاتب الذي يتم تمريره

  const Readingprofile({super.key, required this.authorId});

  @override
  State<Readingprofile> createState() => _ReadingprofileState();
}

class _ReadingprofileState extends State<Readingprofile> {
  List<String> authorLists = [];
  int publishedBooksCount = 0;
  int readersCount = 0;
  String displayName = "Loading...";
  String username = 'Loading...';
  String? profilePicture;
  List<String> storyImages = [];
  List<String> storyTitle = [];
  List<String> storyOverView = [];
  List<String> storyauthorname = [];
  List<String> storybio = [];

  @override
  void initState() {
    super.initState();
    _fetchAuthorIdAndData(); // جلب بيانات الكاتب
    _fetchStoryData(); // جلب بيانات القصص التي كتبها الكاتب
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicture =
          prefs.getString('profilePicture') ?? 'images/avatar1.png';
    });
  }

  // جلب بيانات الكاتب من مجموعة users
  void _fetchAuthorIdAndData() async {
    // البحث عن المؤلف باستخدام الاسم للحصول على authorId
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.authorId) // البحث باستخدام الاسم
        .get();

    if (snapshot.docs.isNotEmpty) {
      // إذا تم العثور على المؤلف
      DocumentSnapshot authorData = snapshot.docs.first;
      setState(() {
        displayName = authorData['displayName'] ?? 'Unknown Author';
        username = authorData['username'] ?? 'Unknown';
        // readersCount = authorData['readersCount'] ?? 0;
      });
    } else {
      setState(() {
        displayName = 'Unknown Author';
        username = 'Unknown';
        readersCount = 0;
      });
      print('No author found with the given name');
    }
  }

  // جلب القصص التي كتبها الكاتب من مجموعة stories
  void _fetchStoryData() async {
    QuerySnapshot storyData = await FirebaseFirestore.instance
        .collection('stories') // جلب البيانات من مجموعة 'stories'
        .where('author', isEqualTo: widget.authorId) // استخدم المعرف الممرر
        .get();

    setState(() {
      storyTitle = storyData.docs.map((doc) => doc['title'] as String).toList();
      storyImages =
          storyData.docs.map((doc) => doc['imageUrl'] as String).toList();
      storyOverView =
          storyData.docs.map((doc) => doc['description'] as String).toList();
      storyauthorname =
          storyData.docs.map((doc) => doc['author'] as String).toList();
      publishedBooksCount = storyData.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          username,
          style: TextStyles.Bold24,
          textAlign: TextAlign.center,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage:
                  profilePicture != null && profilePicture!.isNotEmpty
                      ? (profilePicture!.startsWith('images/')
                          ? AssetImage(profilePicture!)
                          : FileImage(File(profilePicture!)))
                      : const AssetImage('images/avatar1.png') as ImageProvider,
              radius: 40,
            ),
            const SizedBox(height: 20),
            Text(
              displayName,
              style: TextStyles.Bold18,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      publishedBooksCount.toString(),
                      style: TextStyles.Bold18,
                    ),
                    const Text(
                      Textclass.Book,
                      style: TextStyles.normal16,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      readersCount.toString(),
                      style: TextStyles.Bold18,
                    ),
                    const Text(
                      Textclass.Readers,
                      style: TextStyles.normal16,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Transform.translate(
              offset: const Offset(-120, 0),
              child: const Text(
                Textclass.AuthorBooks,
                style: TextStyles.Bold18,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: storyImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ReadBookScreen(
                            title: storyTitle[index],
                            imageUrl: storyImages[index],
                            overview: storyOverView[index],
                            author: storyauthorname[index],
                            bio: index < storybio.length
                                ? storybio[index]
                                : "Bio not available",
                          );
                        },
                      ));
                    },
                    child: Container(
                      width: 120,
                      height: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colorclass.grey,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(storyImages[index]),
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
    );
  }
}