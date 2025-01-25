import 'dart:io';
import 'package:bookbloom/WriteStoryScreen.dart';
import 'package:bookbloom/mainpage.dart';
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
  List<String> storyIds = [];

  List<String> draftImages = [];
  List<String> draftTitle = []; // متغير لعنوان القصة
  List<String> draftOverView = []; // متغير لوصف القصة
  List<String> draftauthorname = []; // متغير لوصف القصة
  List<String> draftbio = []; // متغير لوصف القصة
  List<String> draftIds = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchStoryData();
    _fetchDraftData();
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
        username = userData['username'];
      });
    }
  }

  void _confirmDeleteStory(String storyId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colorclass.white,
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this story?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق الحوار
              },
              child: Text(
                'Cancel',
                style: TextStyles.Bold16.copyWith(
                  color: Colorclass.brown, // لون النص أحمر
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteStory(storyId); // تنفيذ الحذف

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(index: 1),
                    ));
              },
              child: Text(
                'Delete',
                style: TextStyles.Bold16.copyWith(
                  color: Colorclass.Red, // لون النص أحمر
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteStory(String storyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(storyId)
          .delete();
      setState(() {
        storyIds.remove(storyId);
        // تحديث القوائم المحلية حسب الحاجة
        storyTitle.removeWhere((title) => storyIds.contains(storyId));
        storyImages.removeWhere((image) => storyIds.contains(storyId));
        storyOverView.removeWhere((overview) => storyIds.contains(storyId));
        storyauthorname.removeWhere((author) => storyIds.contains(storyId));
        storybio.removeWhere((bio) => storyIds.contains(storyId));
      });
    } catch (e) {
      print("Error deleting story: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete story')),
      );
    }
  }

  void _fetchStoryData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // جلب بيانات القصص (بما في ذلك المسودات والمنشورات)
      QuerySnapshot storyData = await FirebaseFirestore.instance
          .collection('stories')
          .where('authorId', isEqualTo: user.uid) // الفلترة حسب المؤلف
          .get();

      // جلب بيانات المستخدم (السيرة الذاتية)
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // جمع جميع قيم readerCount (يشمل كل الكتب)
      int totalReaderCount = storyData.docs.fold<int>(0, (sum, doc) {
        var data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('readerCount')) {
          int readerCount = (data['readerCount'] as num?)?.toInt() ?? 0;
          return sum + readerCount;
        }
        return sum;
      });

      // تصفية البيانات لاستبعاد المسودات (isDraft: true) من العرض فقط
      var filteredStories = storyData.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>?;
        return data == null ||
            !data.containsKey('isDraft') ||
            data['isDraft'] == false;
      }).toList();

      setState(() {
        // إجمالي عدد الكتب (بما في ذلك المسودات والمنشورات)
        int totalBooksCount = storyData.docs.length;

        // تخزين القيم في القوائم مع استبعاد المسودات
        storyIds = filteredStories.map((doc) => doc.id).toList();
        storyTitle =
            filteredStories.map((doc) => doc['title'] as String).toList();
        storyImages =
            filteredStories.map((doc) => doc['imageUrl'] as String).toList();
        storyOverView =
            filteredStories.map((doc) => doc['description'] as String).toList();
        storyauthorname =
            filteredStories.map((doc) => doc['author'] as String).toList();
        storybio = List.generate(
            filteredStories.length, (index) => userData['bio'] as String);

        // تخزين العدد الإجمالي للمقروءات
        readersCount = totalReaderCount;

        // عرض الإجمالي بدلًا من المنشورة فقط
        publishedBooksCount = totalBooksCount;

        print("عدد الكتب المسودة: ${totalBooksCount - filteredStories.length}");
        print("إجمالي عدد الكتب: $totalBooksCount");
        print("إجمالي عدد القراء: $readersCount");
      });
    }
  }

  void _fetchDraftData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // جلب بيانات القصص
      QuerySnapshot draftData = await FirebaseFirestore.instance
          .collection('stories')
          .where('authorId', isEqualTo: user.uid)
          .where('isDraft', isEqualTo: true) // فلترة القصص حسب isDraft

          .get();

      // جلب بيانات المستخدم (السيرة الذاتية)
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        // تخزين القيم في القوائم
        draftIds = draftData.docs.map((doc) => doc.id).toList();
        draftTitle =
            draftData.docs.map((doc) => doc['title'] as String).toList();
        draftImages =
            draftData.docs.map((doc) => doc['imageUrl'] as String).toList();
        draftOverView =
            draftData.docs.map((doc) => doc['description'] as String).toList();
        draftauthorname =
            draftData.docs.map((doc) => doc['author'] as String).toList();
        draftbio = List.generate(
            draftData.docs.length, (index) => userData['bio'] as String);
      });
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
                                  title: storyTitle.isNotEmpty
                                      ? storyTitle[index - 1]
                                      : '',
                                  overview: storyOverView.isNotEmpty
                                      ? storyOverView[index - 1]
                                      : '',
                                  bio: storybio.isNotEmpty
                                      ? storybio[index - 1]
                                      : 'hello ',
                                  author: storyauthorname.isNotEmpty
                                      ? storyauthorname[index - 1]
                                      : '',
                                  imageUrl: storyImages.isNotEmpty
                                      ? storyImages[index - 1]
                                      : '',
                                  storyId: storyIds.isNotEmpty
                                      ? storyIds[index - 1]
                                      : '',
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
                                image: NetworkImage(storyImages[index - 1]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
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
                                storyTitle.isNotEmpty
                                    ? storyTitle[index - 1]
                                    : '',
                                textAlign: TextAlign.center,
                                style: TextStyles.hint14.copyWith(
                                  color: Colors
                                      .white, // لون النص أبيض ليظهر على الخلفية
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -5,
                          left: 90,
                          child: IconButton(
                              onPressed: () {
                                _confirmDeleteStory(storyIds[index - 1]);
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colorclass.white,
                                size: 20,
                              )),
                        )
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
                'My Draft',
                style: TextStyles.Bold18,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: draftImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 180,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colorclass.grey,
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(draftImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
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
                              draftTitle.isNotEmpty ? draftTitle[index] : '',
                              textAlign: TextAlign.center,
                              style: TextStyles.hint14.copyWith(
                                color: Colors
                                    .white, // لون النص أبيض ليظهر على الخلفية
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -15,
                        left: 80,
                        child: IconButton(
                          onPressed:
                              null, // نتركه فارغًا لأننا نستخدم PopupMenuButton
                          icon: PopupMenuButton<String>(
                            color: Colorclass.white,
                            onSelected: (value) async {
                              if (value == 'edit') {
                                // خيار التعديل
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WriteStoryScreen(
                                      storyId: draftIds[index],
                                      isEdit: true,
                                    ),
                                  ),
                                );
                              } else if (value == 'delete') {
                                // خيار الحذف مع تأكيد المستخدم
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colorclass.white,
                                    title: const Text('Confirm Deletion'),
                                    content: const Text(
                                        'Are you sure you want to delete this draft?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyles.Bold16.copyWith(
                                            color: Colorclass
                                                .brown, // لون النص أحمر
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MainPage(index: 1),
                                                )),
                                        child: Text(
                                          'Delete',
                                          style: TextStyles.Bold16.copyWith(
                                            color:
                                                Colorclass.Red, // لون النص أحمر
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  // حذف المسودة من Firebase
                                  await FirebaseFirestore.instance
                                      .collection('stories')
                                      .doc(draftIds[index])
                                      .delete();

                                  setState(() {
                                    draftIds.removeAt(index);
                                    draftTitle.removeAt(index);
                                    draftImages.removeAt(index);
                                    draftOverView.removeAt(index);
                                    draftauthorname.removeAt(index);
                                    draftbio.removeAt(index);
                                  });
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colorclass.white,
                              size: 20,
                            ),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: ListTile(
                                  title: Text('Edit'),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}