import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/SignUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:badges/badges.dart' as badges;

class Readingspacescreen extends StatefulWidget {
  final String storyId;

  const Readingspacescreen({
    super.key,
    required this.storyId,
  });

  @override
  State<Readingspacescreen> createState() => _ReadingspacescreenState();
}

class _ReadingspacescreenState extends State<Readingspacescreen> {
  double fontSize = 16.0;
  String title = "Loading...";
  String authorName = "Unknown Author";
  List<Map<String, dynamic>> partsList = [];

  @override
  void initState() {
    super.initState();
    _fetchPartsData();
    _fetchCounts();
  }

  Future<void> _fetchPartsData() async {
    try {
      DocumentSnapshot storyDoc = await FirebaseFirestore.instance
          .collection('stories')
          .doc(widget.storyId)
          .get();

      if (storyDoc.exists) {
        QuerySnapshot partSnapshot = await FirebaseFirestore.instance
            .collection('stories')
            .doc(widget.storyId)
            .collection('parts')
            .orderBy('createdAt')
            .get();

        if (partSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> tempPartsList = [];
          for (var partDoc in partSnapshot.docs) {
            tempPartsList.add({
              'partTitle': partDoc['partTitle'],
              'content': partDoc['content'],
            });
          }

          setState(() {
            title = storyDoc['title'] ?? "No Title";
            authorName = storyDoc['author'] ?? "Unknown Author";
            partsList = tempPartsList;
          });
        }
      }
    } catch (e) {
      print("Error fetching parts data: $e");
    }
  }

  int likesCount = 0;
  int commentsCount = 0;
  bool isLiked = false; // متغير لحالة الضغط

  void _fetchCounts() async {
    try {
      final storyDoc = await FirebaseFirestore.instance
          .collection('stories')
          .doc(widget.storyId)
          .get();

      if (storyDoc.exists) {
        setState(() {
          likesCount = storyDoc.data()?['likes'] ?? 0;
          commentsCount = storyDoc.data()?['commentsCount'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching counts: $e");
    }
  }

  void _incrementLikes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storyRef = FirebaseFirestore.instance
            .collection('stories')
            .doc(widget.storyId);

        if (isLiked) {
          // إذا تم الضغط مسبقًا على اللايك، نقوم بحذفه
          await storyRef.update({
            'likes': FieldValue.increment(-1), // تقليل العدد
          });

          await storyRef
              .collection('likes')
              .doc(user.uid)
              .delete(); // حذف اللايك من Firebase

          setState(() {
            likesCount--;
            isLiked = false; // تحديث الحالة
          });
        } else {
          // إذا لم يتم الضغط مسبقًا، نضيف اللايك
          await storyRef.update({
            'likes': FieldValue.increment(1), // زيادة العدد
          });

          await storyRef.collection('likes').doc(user.uid).set({
            'userId': user.uid, // حفظ معرّف المستخدم
            'timestamp': FieldValue.serverTimestamp(),
          }); // إضافة اللايك إلى Firebase

          setState(() {
            likesCount++;
            isLiked = true; // تحديث الحالة
          });
        }
      }
    } catch (e) {
      print("Error handling like: $e");
    }
  }

  void _addComment(String comment) async {
    try {
      final storyRef =
          FirebaseFirestore.instance.collection('stories').doc(widget.storyId);
      final commentsCollection = storyRef.collection('comments');

      // الحصول على المستخدم الحالي من FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid; // معرّف المستخدم
        String username = user.displayName ??
            'Unknown'; // اسم المستخدم، إذا لم يكن موجودًا يتم استخدام 'Unknown'

        await commentsCollection.add({
          'text': comment,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': userId, // حفظ معرّف المستخدم
          'username': username, // حفظ اسم المستخدم
        });

        await storyRef.update({
          'commentsCount': FieldValue.increment(1),
        });

        setState(() {
          commentsCount++;
        });
      } else {
        print("No user is signed in.");
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  Future<void> _showComments() async {
    final TextEditingController commentController = TextEditingController();
    final commentsRef = FirebaseFirestore.instance
        .collection('stories')
        .doc(widget.storyId)
        .collection('comments')
        .orderBy('timestamp', descending: true);

    // عرض الـ Modal Bottom Sheet مع التعليقات
    showModalBottomSheet(
      backgroundColor: Colorclass.white,
      context: context,
      isScrollControlled: true, // السماح بالتحكم في ارتفاع الـ Modal
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // ضمان المسافة الصحيحة عند ظهور الكيبورد
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: SafeArea(
                child: Container(
                  color: Colorclass.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان الـ Modal
                      const Center(
                        child: Text(
                          "Comments",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // عرض التعليقات داخل FutureBuilder
                      FutureBuilder<QuerySnapshot>(
                        future: commentsRef.get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final comments = snapshot.data?.docs ?? [];
                          if (comments.isEmpty) {
                            return Center(
                                child: Text(
                              'No comments yet',
                              style: TextStyles.Bold24.copyWith(
                                  color: Colorclass.brown),
                            ));
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: comments.map((doc) {
                                final commentText = (doc.data()
                                        as Map<String, dynamic>)['text'] ??
                                    '';
                                final username = (doc.data()
                                        as Map<String, dynamic>)['username'] ??
                                    'Anonymous';

                                return ListTile(
                                  subtitle: Text(
                                    commentText,
                                    style: TextStyles.normal16
                                        .copyWith(color: Colorclass.brown),
                                  ),
                                  title: Text(
                                    username,
                                    style: TextStyles.Bold16.copyWith(
                                        color: Colorclass.brown),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // حقل كتابة التعليق الجديد
                      CustomCommentTextField(
                        controller: commentController,
                        hintText: "Write your comment...",
                      ),
                      const SizedBox(height: 10),

                      // أزرار إضافة تعليق وإغلاق
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // إغلاق الـ Modal Bottom Sheet
                            },
                            child: Text(
                              "Close",
                              style: TextStyles.Bold16.copyWith(
                                  color: Colorclass.brown),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final comment = commentController.text.trim();
                              if (comment.isNotEmpty) {
                                _addComment(comment); // إضافة التعليق
                                setState(
                                    () {}); // تحديث التعليقات بعد إضافة تعليق جديد
                              }
                            },
                            child: Text(
                              "Add Comment",
                              style: TextStyles.Bold16.copyWith(
                                  color: Colorclass.brown),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        backgroundColor: Colorclass.white,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace,
              color: Colorclass.dustyPink, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                authorName,
                style: TextStyles.hint14.copyWith(color: Colorclass.grey),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: partsList.isEmpty
          ? Center(
              child: Text(
                "No Content Available",
                style: TextStyle(fontSize: fontSize, color: Colorclass.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: partsList.length,
                itemBuilder: (context, index) {
                  final part = partsList[index];
                  bool isLast = index == partsList.length - 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ch.${index + 1}",
                            style: TextStyles.Bold20.copyWith(
                              color: Colorclass.brown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        part['partTitle'] ?? "No Part Title",
                        style: TextStyles.normal16.copyWith(
                          color: Colorclass.brown,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        part['content'] ?? "No Content",
                        style: TextStyle(
                            fontSize: fontSize, color: Colorclass.brown),
                      ),
                      if (!isLast) const Divider(color: Colorclass.grey),
                      if (isLast)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _incrementLikes();
                                  },
                                  child: badges.Badge(
                                    badgeContent: Text(
                                      likesCount.toString(),
                                    ),
                                    badgeStyle: const badges.BadgeStyle(
                                        badgeColor: Colorclass.dustyPink),
                                    child: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons
                                              .favorite_border, // تغيير الأيقونة بناءً على حالة الإعجاب
                                      color: isLiked
                                          ? Colorclass.brown
                                          : Colorclass
                                              .brown, // تغيير اللون عند الإعجاب
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _showComments, // Show comments dialog
                                  child: badges.Badge(
                                    badgeContent: Text(
                                      commentsCount.toString(),
                                    ),
                                    badgeStyle: const badges.BadgeStyle(
                                        badgeColor: Colorclass.dustyPink),
                                    child: const Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colorclass.brown,
                                      size: 30,
                                    ),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _buildFontSizeSlider(),
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 70,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border(
                top: BorderSide(color: Colorclass.grey, width: 3),
                left: BorderSide(color: Colorclass.grey, width: 3),
                right: BorderSide(color: Colorclass.grey, width: 3),
              ),
              color: Colorclass.white,
            ),
          ),
        ),
        Positioned(
          top: 20.0,
          left: 50.0,
          child: Text(
            "Font Size",
            style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
          ),
        ),
        Positioned(
          top: 40,
          left: 40,
          right: 40,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
              thumbColor: Colorclass.white,
              activeTrackColor: Colorclass.brown,
              inactiveTrackColor: Colorclass.grey,
              overlayColor: Colorclass.brown.withOpacity(0.2),
            ),
            child: Slider(
              value: fontSize,
              min: 12,
              max: 24,
              divisions: 6,
              label: fontSize.toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  fontSize = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CustomCommentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomCommentTextField(
      {super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white, // اللون الأبيض للخلفية
        borderRadius: BorderRadius.circular(25.0), // حدود دائرية
        border: Border.all(
            color: Colors.grey.withOpacity(0.2)), // حدود خفيفة باللون الرمادي
      ),
      child: TextField(
        controller: controller,
        maxLines: null, // للسماح بتعدد الأسطر
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
              color: Colors.grey), // النص التوضيحي باللون الرمادي
          border: InputBorder.none, // إخفاء الحدود الافتراضية
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0), // توفير المسافة المريحة للكتابة
        ),
      ),
    );
  }
}