import 'dart:io';

import 'package:bookbloom/readbookScreen.dart';
import 'package:bookbloom/readingprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/colorclass.dart';
import 'package:bookbloom/BaseClasses/textclass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedFilter = Textclass.Both;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  // للحصول على الكتب من Firebase بعد البحث
  Stream<List<Map<String, dynamic>>> _getBooks() async* {
    String searchQuery = searchController.text.trim();
    if (searchQuery.isEmpty) {
      yield [];
      return;
    }

    List<Map<String, dynamic>> results = [];

    // البحث بالاسم فقط (Author)
    if (selectedFilter == Textclass.Author) {
      var authorQuery = await FirebaseFirestore.instance
          .collection('stories')
          .where('author', isGreaterThanOrEqualTo: searchQuery)
          .where('author', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .get();

      if (authorQuery.docs.isNotEmpty) {
        for (var doc in authorQuery.docs) {
          var data = doc.data();
          data['storyId'] = doc.id; // إضافة storyId

          // التحقق من وجود collection "parts" في القصة
          var partsQuery = await FirebaseFirestore.instance
              .collection('stories')
              .doc(doc.id)
              .collection('parts')
              .get();

          // إذا لم يكن هناك "parts" في القصة، نضيف معلومات المستخدم بدلاً من القصة
          if (partsQuery.docs.isEmpty) {
            // جلب الـ bio من مجموعة users باستخدام username
            var userQuery = await FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: data['author'])
                .get();

            if (userQuery.docs.isNotEmpty) {
              var userData = userQuery.docs.first.data();
              userData['userId'] = userQuery.docs.first.id; // إضافة userId
              userData['bio'] =
                  userData['bio'] ?? 'No Bio'; // إضافة bio من users
              results.add(userData);
            }
            continue; // تجاهل إضافة القصة إذا لم تحتوي على "parts"
          }

          // إذا كانت القصة تحتوي على "parts"، نضيف القصة
          // جلب الـ bio من مجموعة users باستخدام username
          var userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: data['author'])
              .get();

          if (userQuery.docs.isNotEmpty) {
            var userData = userQuery.docs.first.data();
            data['bio'] = userData['bio'] ?? 'No Bio'; // إضافة bio من users
          } else {
            data['bio'] = 'No Bio'; // في حال لم يتم العثور على المستخدم
          }

          results.add(data);
        }
      } else {
        // إذا لم تكن هناك قصص للمؤلف، نبحث عن المستخدمين
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: searchQuery)
            .where('username', isLessThanOrEqualTo: '$searchQuery\uf8ff')
            .get();

        if (userQuery.docs.isNotEmpty) {
          for (var doc in userQuery.docs) {
            var userData = doc.data();
            userData['userId'] = doc.id; // إضافة userId
            userData['bio'] =
                userData.containsKey('bio') ? userData['bio'] : 'No Bio';
            results.add(userData);
          }
        }
      }
    }

    // البحث بالعنوان فقط
    if (selectedFilter == Textclass.Title1) {
      var titleQuery = await FirebaseFirestore.instance
          .collection('stories')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .get();

      for (var doc in titleQuery.docs) {
        var data = doc.data();
        data['storyId'] = doc.id; // إضافة storyId

        // التحقق من وجود collection "parts" في القصة
        var partsQuery = await FirebaseFirestore.instance
            .collection('stories')
            .doc(doc.id)
            .collection('parts')
            .get();

        // إذا لم يكن هناك "parts" في القصة، تجاهل القصة
        if (partsQuery.docs.isEmpty) continue;

        // جلب الـ bio من مجموعة users باستخدام author
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: data['author'])
            .get();

        if (userQuery.docs.isNotEmpty) {
          var userData = userQuery.docs.first.data();
          data['bio'] = userData['bio'] ?? 'No Bio'; // إضافة bio من users
        } else {
          data['bio'] = 'No Bio'; // في حال لم يتم العثور على المستخدم
        }

        results.add(data);
      }
    }

    // البحث بالاسم أو العنوان
    if (selectedFilter == Textclass.Both) {
      var authorQuery = await FirebaseFirestore.instance
          .collection('stories')
          .where('author', isGreaterThanOrEqualTo: searchQuery)
          .where('author', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .get();
      var titleQuery = await FirebaseFirestore.instance
          .collection('stories')
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .get();

      // قم بتخزين الـ ids التي تمت إضافتها مسبقًا لتجنب التكرار
      Set<String> addedStoryIds = {};

      for (var doc in authorQuery.docs) {
        var data = doc.data();
        data['storyId'] = doc.id; // إضافة storyId

        // التحقق من وجود collection "parts" في القصة
        var partsQuery = await FirebaseFirestore.instance
            .collection('stories')
            .doc(doc.id)
            .collection('parts')
            .get();

        // إذا لم يكن هناك "parts" في القصة، تجاهل القصة
        if (partsQuery.docs.isEmpty) continue;

        // جلب الـ bio من مجموعة users باستخدام author
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: data['author'])
            .get();

        if (userQuery.docs.isNotEmpty) {
          var userData = userQuery.docs.first.data();
          data['bio'] = userData['bio'] ?? 'No Bio'; // إضافة bio من users
        } else {
          data['bio'] = 'No Bio'; // في حال لم يتم العثور على المستخدم
        }

        // إضافة القصة إذا لم تكن قد أُضيفت مسبقًا
        if (!addedStoryIds.contains(data['storyId'])) {
          results.add(data);
          addedStoryIds.add(data['storyId']);
        }
      }

      for (var doc in titleQuery.docs) {
        var data = doc.data();
        data['storyId'] = doc.id; // إضافة storyId

        // التحقق من وجود collection "parts" في القصة
        var partsQuery = await FirebaseFirestore.instance
            .collection('stories')
            .doc(doc.id)
            .collection('parts')
            .get();

        // إذا لم يكن هناك "parts" في القصة، تجاهل القصة
        if (partsQuery.docs.isEmpty) continue;

        // جلب الـ bio من مجموعة users باستخدام author
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: data['author'])
            .get();

        if (userQuery.docs.isNotEmpty) {
          var userData = userQuery.docs.first.data();
          data['bio'] = userData['bio'] ?? 'No Bio'; // إضافة bio من users
        } else {
          data['bio'] = 'No Bio'; // في حال لم يتم العثور على المستخدم
        }

        // إضافة القصة إذا لم تكن قد أُضيفت مسبقًا
        if (!addedStoryIds.contains(data['storyId'])) {
          results.add(data);
          addedStoryIds.add(data['storyId']);
        }
      }

      // إزالة التكرار بين القصص حسب المؤلف والعنوان
      results = results.toSet().toList();
    }

    yield results;
  }

  String? profilePicture; // لتخزين مسار الصورة

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicture =
          prefs.getString('profilePicture') ?? 'images/avatar1.png';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            // حقل البحث
            Container(
              constraints: const BoxConstraints(
                minHeight: 30,
                maxHeight: 50,
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: Textclass.author,
                  hintStyle:
                      TextStyles.normal16.copyWith(color: Colorclass.brown),
                  prefixIcon: const Icon(Icons.search, color: Colorclass.brown),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colorclass.brown),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  filled: true,
                  fillColor: Colorclass.grey,
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colorclass.brown),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colorclass.brown, width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  setState(() {
                    isSearching = true;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // الفلاتر
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colorclass.grey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _filterButton(Textclass.Both),
                  _filterButton(Textclass.Author),
                  _filterButton(Textclass.Title1),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // إذا كانت نتائج البحث فارغة، يتم إظهار هذه الرسالة فقط
                    if (searchController.text.isNotEmpty) {
                      // إذا كان هناك بحث ولكن لا توجد نتائج
                      return Center(
                        child: LottieBuilder.asset('images/empty_serach.json'),
                      );
                    } else {
                      // إذا لم يتم البحث بعد
                      return const SizedBox.shrink();
                    }
                  }

                  var books = snapshot.data!;
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      var book = books[index];

                      // التحقق إذا كانت البيانات تخص المؤلف أو المستخدم
                      bool isUser = book.containsKey('username');

                      return _bookItem(
                          isUser
                              ? book['imageUrl'] ??
                                  'assets/images/default_image.png'
                              : book['imageUrl'] ??
                                  'assets/images/default_image.png',
                          isUser
                              ? book['displayName'] ?? 'No Display Name'
                              : book['title'] ?? 'No Title',
                          isUser
                              ? book['username'] ?? 'No Username'
                              : book['author'] ?? 'No Author',
                          isUser
                              ? 'User Bio'
                              : book['description'] ?? 'No Overview',
                          isUser ? 'User Bio' : book['bio'] ?? 'No Bio',
                          book);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // زر الفلتر
  Widget _filterButton(String text) {
    bool isActive = selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? Colorclass.white : Colorclass.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyles.normal16.copyWith(
            color: isActive ? Colorclass.brown : Colorclass.lightgray,
          ),
        ),
      ),
    );
  }

  // عنصر الكتاب
  // عنصر الكتاب
  // عنصر الكتاب
  Widget _bookItem(String imagePath, String title, String author,
      String overview, String bio, Map<String, dynamic> book) {
    // التحقق إذا كانت البيانات تخص مستخدم
    bool isUser = book.containsKey(
        'username'); // إذا كان الكتاب يحتوي على 'username' فهو مستخدم
    String docId = isUser ? book['userId'] : book['storyId']; // الحصول على ID

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (isUser) {
                // إذا كانت هذه بيانات مستخدم وليس مؤلف
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Readingprofile(
                      authorId: book['username'], // انتقل إلى صفحة المستخدم
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadBookScreen(
                      title: title,
                      imageUrl: imagePath,
                      overview: overview,
                      author: author,
                      bio: bio,
                      storyId: docId, // انتقل إلى صفحة الكتاب
                    ),
                  ),
                );
              }
            },
            child: isUser
                ? CircleAvatar(
                    backgroundImage:
                        profilePicture != null && profilePicture!.isNotEmpty
                            ? (profilePicture!.startsWith('images/')
                                ? AssetImage(profilePicture!)
                                : FileImage(File(profilePicture!)))
                            : const AssetImage('images/avatar1.png')
                                as ImageProvider,
                    radius: 20,
                  )
                : Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isUser
                    ? book['username']
                    : author, // يعرض 'User' في حالة كانت البيانات تخص المستخدم
                style:
                    TextStyles.normal16.copyWith(color: Colorclass.lightgray),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}