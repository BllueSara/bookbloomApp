import 'dart:io';

import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/readbookScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Readingprofile extends StatefulWidget {
  final String authorId; // معرّف الشخص الذي يتم تمريره

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

  bool isUser = false; // متغير للتحقق إذا كان الشخص هو مستخدم أو كاتب

  @override
  void initState() {
    super.initState();
    _checkIfAuthorOrUser(); // التحقق إذا كان كاتبًا أو مستخدمًا
    _fetchAuthorData(); // جلب بيانات الكتب
    _loadProfilePicture();
    _fetchBooksFromShelves(); // استدعاء الكتب من الشيلف
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicture =
          prefs.getString('profilePicture') ?? 'images/avatar1.png';
    });
  }

  // التحقق إذا كان الشخص كاتبًا أو مستخدمًا
  void _checkIfAuthorOrUser() async {
    var authorQuery = await FirebaseFirestore.instance
        .collection('stories')
        .where('author', isEqualTo: widget.authorId) // استخدام المعرف
        .get();

    if (authorQuery.docs.isNotEmpty) {
      setState(() {
        isUser = false; // هذا شخص كاتب
        _fetchAuthorData();
        _fetchUserData(); // جلب بيانات الكاتب
      });
    } else {
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.authorId) // استخدام المعرف
          .get();

      if (userQuery.docs.isNotEmpty) {
        setState(() {
          isUser = true; // هذا شخص مستخدم
          _fetchUserData(); // جلب بيانات المستخدم
        });
      }
    }
  }

  // جلب بيانات الكاتب
  void _fetchAuthorData() async {
    var authorData = await FirebaseFirestore.instance
        .collection('stories')
        .where('author', isEqualTo: widget.authorId)
        .get();

    setState(() {
      storyTitle =
          authorData.docs.map((doc) => doc['title'] as String).toList();
      storyImages =
          authorData.docs.map((doc) => doc['imageUrl'] as String).toList();
      storyOverView =
          authorData.docs.map((doc) => doc['description'] as String).toList();
      storyauthorname =
          authorData.docs.map((doc) => doc['author'] as String).toList();
      publishedBooksCount = authorData.docs.length;
    });
  }

  // جلب بيانات المستخدم
  void _fetchUserData() async {
    var userData = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.authorId)
        .get();

    setState(() {
      var user = userData.docs.first;
      displayName = user['displayName'] ?? 'Unknown User';
      username = user['username'] ?? 'Unknown';

      // تحقق من وجود الحقل readersCount
      readersCount = user.data().containsKey('readersCount')
          ? user['readersCount']
          : 0; // تعيين 0 إذا لم يكن الحقل موجودًا
    });
  }

  // جلب الكتب من الشيلف
  void _fetchBooksFromShelves() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shelves')
          .get();

      List<Map<String, dynamic>> allBooks = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final books = data['books'] as List<dynamic>? ?? [];
        allBooks.addAll(books.map((book) => book as Map<String, dynamic>));
      }

      setState(() {
        storyTitle
            .addAll(allBooks.map((book) => book['title'] as String).toList());
        storyImages.addAll(
            allBooks.map((book) => book['imageUrl'] as String).toList());
        storyOverView.addAll(
            allBooks.map((book) => book['overview'] as String).toList());
        storyauthorname
            .addAll(allBooks.map((book) => book['author'] as String).toList());
        publishedBooksCount += allBooks.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String bookType = isUser
        ? "User Books"
        : "Author Books"; // التغيير بين "User Books" و "Author Books"

    return Scaffold(
      backgroundColor: Colorclass.white,
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
                    Text(
                      bookType, // عرض النص المناسب
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
              child: Text(
                bookType, // تغيير النص بين "author books" و "user books"
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
                            bio: isUser ? 'User Bio' : 'Author Bio',
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
