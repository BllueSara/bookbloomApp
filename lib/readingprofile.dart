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
      bool hasValidBook = false;

      // تحقق من أن الكتاب يحتوي على "parts"
      for (var doc in authorQuery.docs) {
        var partsQuery = await FirebaseFirestore.instance
            .collection('stories')
            .doc(doc.id)
            .collection('parts')
            .get();

        if (partsQuery.docs.isNotEmpty) {
          hasValidBook = true; // إذا وجدنا كتابًا يحتوي على "parts"
          break; // إذا وجدنا كتابًا صحيحًا، نوقف البحث
        }
      }

      if (hasValidBook) {
        setState(() {
          isUser = false; // هذا شخص كاتب
          _fetchAuthorData(); // جلب بيانات الكاتب من stories و users
        });
      } else {
        setState(() {
          isUser = true; // هذا شخص مستخدم وليس كاتب
          _fetchUserData(); // جلب بيانات المستخدم
        });
      }
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

  void _fetchAuthorData() async {
    var authorStories = await FirebaseFirestore.instance
        .collection('stories')
        .where('author', isEqualTo: widget.authorId)
        .get();

    if (authorStories.docs.isNotEmpty) {
      List<Map<String, dynamic>> validBooks = [];

      // تحقق من وجود "parts" في الكتب
      for (var doc in authorStories.docs) {
        var partsQuery = await FirebaseFirestore.instance
            .collection('stories')
            .doc(doc.id)
            .collection('parts')
            .get();

        if (partsQuery.docs.isNotEmpty) {
          validBooks.add({
            'title': doc['title'],
            'imageUrl': doc['imageUrl'],
            'description': doc['description'],
            'author': doc['author'],
            'id': doc.id,
          });
        }
      }

      // إذا كانت هناك كتب صالحة، نقوم بتعيين القيم
      if (validBooks.isNotEmpty) {
        setState(() {
          // استخدام map() لاستخراج القيم من validBooks وتحويلها إلى قوائم من النوع الصحيح
          storyTitle =
              validBooks.map((book) => book['title'] as String).toList();
          storyImages =
              validBooks.map((book) => book['imageUrl'] as String).toList();
          storyOverView =
              validBooks.map((book) => book['description'] as String).toList();
          storyauthorname =
              validBooks.map((book) => book['author'] as String).toList();
          storyIds = validBooks.map((book) => book['id'] as String).toList();
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

            // التحقق من readersCount
            readersCount = user.data().containsKey('readersCount')
                ? user['readersCount']
                : readersCount;

            // إضافة bio من users
            storybio = [
              user.data().containsKey('bio') ? user['bio'] : 'No Bio Available'
            ];
          });
        }
      } else {
        setState(() {
          // إذا لم يحتوي أي كتاب على "parts"، يمكن تعيين حالة معينة أو إخفاء المحتوى
          storyTitle = [];
          storyImages = [];
          storyOverView = [];
          storyauthorname = [];
          storyIds = [];
        });
      }
    }
  }

  void _fetchUserData() async {
    try {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.authorId)
          .get();

      if (userData.docs.isNotEmpty) {
        var user = userData.docs.first;

        setState(() {
          displayName = user['displayName'] ?? 'Unknown User';
          username = user['username'] ?? 'Unknown';
          readersCount = user.data().containsKey('readersCount')
              ? user['readersCount']
              : 0;
          storybio = [user.data().containsKey('bio') ? user['bio'] : 'No'];
        });

        var readingData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .collection('reading')
            .get();

        if (readingData.docs.isNotEmpty) {
          List<Map<String, dynamic>> validBooks = [];

          for (var doc in readingData.docs) {
            var partsQuery = await FirebaseFirestore.instance
                .collection('stories')
                .doc(doc.id)
                .collection('parts')
                .get();

            if (partsQuery.docs.isNotEmpty) {
              validBooks.add({
                'title': doc['title'],
                'imageUrl': doc['imageUrl'],
                'author': doc['author'],
                'id': doc.id,
                'overview': doc['overview']
              });
            }
          }

          setState(() {
            if (validBooks.isNotEmpty) {
              storyTitle =
                  validBooks.map((book) => book['title'] as String).toList();
              storyImages =
                  validBooks.map((book) => book['imageUrl'] as String).toList();
              storyOverView =
                  validBooks.map((book) => book['overview'] as String).toList();
              storyauthorname =
                  validBooks.map((book) => book['author'] as String).toList();
              storyIds =
                  validBooks.map((book) => book['id'] as String).toList();
            } else {
              storyTitle = [];
              storyImages = [];
              storyOverView = [];
              storyauthorname = [];
              storyIds = [];
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
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
    String bookType = isUser
        ? "Reader Books"
        : "Author Books"; // التغيير بين "User Books" و "Author Books"
    String listType = isUser
        ? "Reader Lists"
        : "Author Lists"; // التغيير بين "User Books" و "Author Books"

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
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace,
              color: Colorclass.dustyPink, size: 40),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                      Textclass.Book, // عرض النص المناسب
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
              offset: const Offset(-140, 0),
              child: Text(
                bookType, // تغيير النص بين "author books" و "user books"
                style: TextStyles.Bold18,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250, // ارتفاع كافٍ للصور والعناوين
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: storyImages.length, // عدد الكتب الخاصة بالمؤلف
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      // عرض صورة الكتاب
                      GestureDetector(
                        onTap: () {
                          // الانتقال إلى صفحة قراءة الكتاب عند النقر على الصورة
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ReadBookScreen(
                                title: storyTitle[index],
                                imageUrl: storyImages[index],
                                overview: storyOverView[index],
                                author: storyauthorname[index],
                                bio: storybio.isNotEmpty ? storybio.first : '',
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
                              image: NetworkImage(
                                  storyImages[index]), // صورة الكتاب
                              fit: BoxFit.cover, // تغطية كاملة للصورة
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -35), // تحريك العنوان إلى أسفل
                        child: Container(
                          width: 120,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.3), // خلفية نص نصف شفافة
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            storyTitle[index],
                            textAlign: TextAlign.center,
                            style: TextStyles.hint14.copyWith(
                              color: Colors
                                  .white, // لون النص أبيض ليظهر على الخلفية
                            ),
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
                listType, // تغيير النص بين "author books" و "user books"
                style: TextStyles.Bold18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
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
                              color: Colors.black
                                  .withOpacity(0.3), // خلفية نص نصف شفافة
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              book['title'],
                              textAlign: TextAlign.center,
                              style: TextStyles.hint14.copyWith(
                                color: Colors
                                    .white, // لون النص أبيض ليظهر على الخلفية
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