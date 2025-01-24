import 'dart:io';

import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/readbookScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<String> storyIds = [];
  List<Map<String, dynamic>> _shelfBooks = [];

  bool isUser = false; // متغير للتحقق إذا كان الشخص هو مستخدم أو كاتب

  @override
  void initState() {
    super.initState();
    _checkIfAuthorOrUser(); // التحقق إذا كان كاتبًا أو مستخدمًا
    _fetchAuthorData(); // جلب بيانات الكتب
    _loadProfilePicture();
    _fetchShelvesBooks();
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
        .where('author', isEqualTo: widget.authorId)
        .get();

    if (authorQuery.docs.isNotEmpty) {
      setState(() {
        isUser = false; // هذا شخص كاتب
        _fetchAuthorData(); // جلب بيانات الكاتب من stories و users
      });
    } else {
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.authorId)
          .get();

      if (userQuery.docs.isNotEmpty) {
        setState(() {
          isUser = true; // هذا شخص مستخدم وليس كاتب
          _fetchUserData(); // جلب بيانات المستخدم
        });
      }
    }
  }

  int totalReaderCount = 0;

  // جلب بيانات الكاتب
  void _fetchAuthorData() async {
    // جلب بيانات الكاتب من stories
    var authorStories = await FirebaseFirestore.instance
        .collection('stories')
        .where('author', isEqualTo: widget.authorId)
        .get();

    if (authorStories.docs.isNotEmpty) {
      setState(() {
        // التأكد من أن القيم المحصلة هي من نوع String
        storyTitle =
            authorStories.docs.map((doc) => doc['title'] as String).toList();
        storyImages =
            authorStories.docs.map((doc) => doc['imageUrl'] as String).toList();
        storyOverView = authorStories.docs
            .map((doc) => doc['description'] as String)
            .toList();
        storyauthorname =
            authorStories.docs.map((doc) => doc['author'] as String).toList();
        storyIds = authorStories.docs.map((doc) => doc.id).toList();
        publishedBooksCount = authorStories.docs.length;
      });
      for (var doc in authorStories.docs) {
        var data = doc.data();
        if (data.containsKey('readerCount') && data['readerCount'] != null) {
          totalReaderCount = (data['readerCount'] as num).toInt();
        }
      }
      setState(() {
        readersCount = totalReaderCount;
      });
      // جلب بيانات الكاتب من users
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.authorId)
          .get();

      if (userData.docs.isNotEmpty) {
        setState(() {
          var user = userData.docs.first;
          displayName = user['displayName'] ?? 'Unknown User';
          username = user['username'] ?? 'Unknown';
          readersCount = user.data().containsKey('readersCount')
              ? user['readersCount']
              : readersCount;

          // إضافة bio من users
          storybio = [
            user.data().containsKey('bio') ? user['bio'] : 'No Bio Available'
          ];
        });
      }
    }
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
          : readersCount; // تعيين 0 إذا لم يكن الحقل موجودًا
    });
  }

 void _addBookToReadersBooks(String title, String imageUrl, String author,
    {String overview = ''}) {
  if (!storyIds.contains(title)) {
    setState(() {
      storyTitle.add(title);
      storyImages.add(imageUrl);
      storyauthorname.add(author);
      storyOverView.add(overview);
      storyIds.add(title);
    });
  }
}



  void _fetchShelvesBooks() async {
    // البحث عن الأرفف بناءً على اسم المستخدم
    final username = widget.authorId;
    if (username.isNotEmpty) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userId = userSnapshot.docs.first.id;
        final shelvesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('shelves')
            .get();

        List<Map<String, dynamic>> booksData = [];

        for (var shelfDoc in shelvesSnapshot.docs) {
          final shelfName = shelfDoc.id;
          final shelfBooks = shelfDoc['books'] as List<dynamic>;

          for (var book in shelfBooks) {
            booksData.add({
              'title': book['title'],
              'imageUrl': book['imageUrl'],
              'author': book['author'],
              'shelfName': shelfName,
            });
          }
        }


        setState(() {
          _shelfBooks = booksData;
        });
      }
    }
  }
@override
Widget build(BuildContext context) {
  String bookType = isUser ? "Reader Books" : "Author Books";
  String listType = isUser ? "Reader Lists" : "Author Lists";

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
            offset: const Offset(-130, 0),
            child: Text(
              bookType,
              style: TextStyles.Bold18,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 10),
          // عرض قائمة "Readers Books"
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: storyImages.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // إضافة الكتاب إلى Readers Books عند فتح الشاشة
                        _addBookToReadersBooks(
                          storyTitle[index],
                          storyImages[index],
                          storyauthorname[index],
                          overview: storyOverView[index],
                        );

                        // الانتقال إلى صفحة قراءة الكتاب
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ReadBookScreen(
                              title: storyTitle[index],
                              imageUrl: storyImages[index],
                              overview: storyOverView[index],
                              author: storyauthorname[index],
                              bio: storybio.isNotEmpty
                                  ? storybio.first
                                  : 'No Bio Available',
                              storyId: storyIds[index],
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
                    ),
                    Transform.translate(
                      offset: const Offset(0, -35),
                      child: Text(
                        storyTitle[index],
                        textAlign: TextAlign.center,
                        style: TextStyles.hint14.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Transform.translate(
            offset: const Offset(-140, 0),
            child: Text(
              listType,
              style: TextStyles.Bold18,
            ),
          ),
          const SizedBox(height: 10),
          // عرض قائمة الأرفف (Shelves Books)
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _shelfBooks.length,
              itemBuilder: (context, index) {
                final book = _shelfBooks[index];
                return Column(
                  children: [
                    Container(
                      width: 120,
                      height: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colorclass.grey,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(book['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -35),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            book['title'],
                            textAlign: TextAlign.center,
                            style: TextStyles.hint14.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Text(
                        book['shelfName'],
                        style: TextStyles.normal16.copyWith(
                          color: Colorclass.brown,
                        ),
                      ),
                    ),
                  ],
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