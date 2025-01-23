import 'dart:io';

import 'package:bookbloom/readbookScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/EditStoryForm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Writeingspacescreen extends StatefulWidget {
  const Writeingspacescreen({super.key});

  @override
  State<Writeingspacescreen> createState() => _WriteingspacescreenState();
}

class _WriteingspacescreenState extends State<Writeingspacescreen> {
  final List<String> picks = [
    'images/book1.png',
    'images/book2.png',
  ];

  List<String> selectedCategories = [];

  bool isCopyright = false; // متغير لحالة Switch
  bool isMature = false; // متغير لحالة Switch
  bool isCompleted = false; // متغير لحالة Switch
  String selectedLanguage = 'English'; // المتغير لتخزين اللغة المختارة
  String? customCategory; // لتخزين الفئة المخصصة
  String? profilePicture; // لتخزين مسار الصورة
  int publishedBooksCount = 0; // عدد الكتب المنشورة
  int readersCount = 0; // عدد القراء

  String? displayName;

  String? username;
  List<String> storyImages = [];
  List<String> storyTitle = []; // متغير لعنوان القصة
  List<String> storyOverView = []; // متغير لوصف القصة
  List<String> storyauthorname = []; // متغير لوصف القصة
  List<String> storybio = []; // متغير لوصف القصة

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchStoryData();
    _fetchbioData();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicture =
          prefs.getString('profilePicture') ?? 'images/avatar1.png';
    });
  }



  // جلب بيانات المستخدم من Firebase
  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        displayName = userData['displayName'];
        username = '' + userData['username'];
      });
    }
  }

  // جلب صور القصص من Firebase
  void _fetchStoryData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot storyData = await FirebaseFirestore.instance
          .collection('stories')
          .where('authorId', isEqualTo: user.uid)
          .get();

      setState(() {
        storyTitle =
            storyData.docs.map((doc) => doc['title'] as String).toList();
        storyImages =
            storyData.docs.map((doc) => doc['imageUrl'] as String).toList();
        storyOverView =
            storyData.docs.map((doc) => doc['description'] as String).toList();
        storyauthorname =
            storyData.docs.map((doc) => doc['author'] as String).toList();
        publishedBooksCount = storyData.docs.length;
      });

      // حساب عدد القراء
    }
  }

  void _fetchbioData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot storyData = await FirebaseFirestore.instance
          .collection('users')
          .where('bio', isEqualTo: user.uid)
          .get();
      setState(() {
        storybio = storyData.docs.map((doc) => doc['bio'] as String).toList();
      });

      // حساب عدد القراء
    }
  }

  // إظهار نموذج تعديل القصة
  void showEditStoryForm(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colorclass.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return EditStoryForm(
          showCategorySelection: _showCategorySelection,
          showSelectLanguage: _showSelectLanguage,
        

          onMatureChanged: (value) {
            setState(() {
              isMature = value;
            });
          },
          onCompletedChanged: (value) {
            setState(() {
              isCompleted = value;
            });
          },
          selectedLanguage: selectedLanguage,
          isMature: isMature,
          isCompleted: isCompleted,
          selectedCategories: selectedCategories,
        );
      },
    );
  }

  // اختيار اللغة
  void _showSelectLanguage(BuildContext context) {
    DropdownButton<String>(
      dropdownColor: Colorclass.white,
      value: selectedLanguage,
      items: const [
        DropdownMenuItem(
          value: 'English',
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: 'Arabic',
          child: Text('Arabic'),
        ),
      ],
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            selectedLanguage = value;
          });
        }
      },
    );
  }

  // اختيار الفئات
  void _showCategorySelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colorclass.white,
          title: const Text(
            Textclass.Category,
            style: TextStyles.Bold18,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                // إضافة هذه السطر لجعل المحتوى قابلًا للتمرير
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text('Novel'),
                      activeColor: Colorclass.gbrown,
                      value: selectedCategories.contains('Novel'),
                      onChanged: (value) {
                        _toggleCategorySelection('Novel', value);
                        setState(() {});
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Self-love'),
                      activeColor: Colorclass.gbrown,
                      value: selectedCategories.contains('Self-love'),
                      onChanged: (value) {
                        _toggleCategorySelection('Self-love', value);
                        setState(() {});
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Science'),
                      activeColor: Colorclass.gbrown,
                      value: selectedCategories.contains('Science'),
                      onChanged: (value) {
                        _toggleCategorySelection('Science', value);
                        setState(() {});
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Romance'),
                      activeColor: Colorclass.gbrown,
                      value: selectedCategories.contains('Romance'),
                      onChanged: (value) {
                        _toggleCategorySelection('Romance', value);
                        setState(() {});
                      },
                    ),
                    CheckboxListTile(
                      activeColor: Colorclass.gbrown,
                      title: const Text('Tragedy'),
                      value: selectedCategories.contains('Tragedy'),
                      onChanged: (value) {
                        _toggleCategorySelection('Tragedy', value);
                        setState(() {});
                      },
                    ),

                    // "Other" option
                    CheckboxListTile(
                      title: const Text('Other'),
                      activeColor: Colorclass.gbrown,
                      value: selectedCategories.contains('Other'),
                      onChanged: (value) {
                        _toggleCategorySelection('Other', value);
                        setState(() {});
                      },
                    ),

                    // Show input field if "Other" is selected
                    if (selectedCategories.contains('Other'))
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Write Your Category Here',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colorclass
                                    .brown), // تغيير لون الخط عند التركيز
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colorclass.brown), // اللون عند التركيز
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colorclass
                                    .brown), // اللون عند التفاعل دون التركيز
                          ),
                        ),
                        onChanged: (value) {
                          customCategory = value; // حفظ القيمة المدخلة
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (customCategory != null &&
                      customCategory!.isNotEmpty &&
                      !selectedCategories.contains(customCategory)) {
                    selectedCategories.add(customCategory!);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(
                'save',
                style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
              ),
            ),
          ],
        );
      },
    );
  }

  // تحديث اختيار الفئة
  void _toggleCategorySelection(String category, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        selectedCategories.add(category);
      } else {
        selectedCategories.remove(category);
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      appBar: AppBar(
        title: const Text(
          Textclass.Inkspire,
          style: TextStyles.Bold24,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colorclass.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // صورة الملف الشخصي
            CircleAvatar(
              backgroundImage:
                  profilePicture != null && profilePicture!.isNotEmpty
                      ? (profilePicture!.startsWith('images/')
                          ? AssetImage(profilePicture!)
                          : FileImage(File(profilePicture!)))
                      : const AssetImage('images/avatar1.png') as ImageProvider,
              radius: 40,
            ),
            const SizedBox(height: 25),
            // عرض Display Name و Username
            Column(
              children: [
                Text(
                  displayName ??
                      'Loading...', // عرض Display Name أو حالة الانتظار
                  style: TextStyles.Bold18,
                ),
                Text(
                  username != null
                      ? '@$username'
                      : 'Loading...', // عرض Username
                  style: TextStyles.hint14,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      publishedBooksCount.toString(), // عرض عدد الكتب المنشورة
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
                      readersCount.toString(), // عرض عدد القراء
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
              child: const Text(
                Textclass.MyBooks,
                style: TextStyles.Bold18,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: storyImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        showEditStoryForm(context);
                      },
                      child: Container(
                        width: 120,
                        height: 180,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colorclass.grey,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 120,
                          color: Colorclass.addicon,
                        ),
                      ),
                    );
                  } else {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return ReadBookScreen(
                                  title: storyTitle[index - 1], // تمرير العنوان
                                  imageUrl:
                                      storyImages[index - 1], // تمرير الصورة
                                  overview: storyOverView[index - 1],
                                  author: storyauthorname[index - 1],
                                  bio: index - 1 < storybio.length
                                      ? storybio[index - 1]
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
                                image: NetworkImage(
                                    storyImages[index - 1]), // عرض صورة القصة
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(30, 180),
                          child: Text(
                            storyTitle.isNotEmpty
                                ? storyTitle[index - 1]
                                : 'No Title',
                            style: TextStyles.Bold18.copyWith(
                              color: Colorclass.brown,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            Transform.translate(
              offset: const Offset(-130, 0),
              child: const Text(
                Textclass.Draft,
                style: TextStyles.Bold18,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: picks.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colorclass.grey,
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(picks[index]),
                        fit: BoxFit.cover,
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