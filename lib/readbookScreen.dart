import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/mainpage.dart';
import 'package:bookbloom/readingprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReadBookScreen extends StatefulWidget {
  const ReadBookScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.overview,
    required this.author,
    required this.bio,
  });
  final String title;
  final String imageUrl;
  final String overview;
  final String author;
  final String bio;

  @override
  State<ReadBookScreen> createState() => _ReadBookScreenState();
}

class _ReadBookScreenState extends State<ReadBookScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colorclass.white,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 250, // القسم العلوي الأبيض
                  width: double.infinity,
                  color: Colorclass.white,
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colorclass.gbrown,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 80), // رفع النصوص
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyles.Bold20.copyWith(
                                          color: Colorclass.brown,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return Readingprofile(
                                                authorId: widget
                                                    .author, // تمرير معرّف الكاتب
                                              );
                                            },
                                          ));
                                        },
                                        child: Text(
                                          widget.author,
                                          style: TextStyles.normal16.copyWith(
                                            color: Colorclass.grey,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          5,
                                          (index) => const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 15,
                                          ),
                                        )
                                          ..add(
                                            const SizedBox(width: 8),
                                          )
                                          ..add(
                                            Text(
                                              "5.0",
                                              style:
                                                  TextStyles.normal16.copyWith(
                                                color: Colorclass.grey,
                                              ),
                                            ),
                                          ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),
                                        Text(
                                          "About the Author",
                                          style: TextStyles.Bold16.copyWith(
                                            color: Colorclass.brown,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          widget.bio.isNotEmpty
                                              ? widget.bio
                                              : "soory", // عرض رسالة في حالة عدم وجود bio
                                          style: TextStyles.hint14.copyWith(
                                            color: Colorclass.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Overview',
                                          style: TextStyles.Bold18.copyWith(
                                            color: Colorclass.brown,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.overview,
                                          style: TextStyles.hint14.copyWith(
                                            color: Colorclass.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // زر "Start Reading"
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // أضف الإجراء هنا
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colorclass.dustyPink,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 25, // عرض الزر محدود
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                "Start Reading",
                                style: TextStyles.Bold24.copyWith(
                                  color: Colorclass.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // الكتاب فوق الحاوية
            Positioned(
              top: 70, // تعديل مكان الكتاب
              left: MediaQuery.of(context).size.width / 2 - 85,
              child: Container(
                height: 250,
                width: 170,
                decoration: BoxDecoration(
                  color: Colorclass.dustyPink,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                      image: NetworkImage(widget.imageUrl), fit: BoxFit.cover),
                ),
              ),
            ),
            // الأيقونات في أعلى الصفحة
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.keyboard_backspace,
                  color: Colorclass.dustyPink,
                  size: 40,
                ),
                onPressed: () {
                  // يرجع المستخدم إلى صفحة السابقة
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colorclass.dustyPink,
                  size: 40,
                ),
                onPressed: () {
                  _showAddDialog(context); // استدعاء نافذة الإضافة
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    String? selectedShelf;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colorclass.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: const BoxConstraints(maxHeight: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.highlight_off,
                            color: Colorclass.brown,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        GestureDetector(
                          onTap: selectedShelf != null
                              ? () {
                                  _addBookToShelf(selectedShelf!);
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              Textclass.Save,
                              style: TextStyles.Bold16.copyWith(
                                color: selectedShelf != null
                                    ? Colorclass.brown
                                    : Colorclass.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // List of shelves from Firebase
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection('shelves')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                "No shelves available",
                                style: TextStyles.normal16
                                    .copyWith(color: Colorclass.grey),
                              ),
                            );
                          }

                          final shelves = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: shelves.length,
                            itemBuilder: (context, index) {
                              final shelfName = shelves[index]['shelfName'];

                              return ListTile(
                                title: Text(
                                  shelfName,
                                  style: TextStyles.normal16
                                      .copyWith(color: Colorclass.brown),
                                ),
                                trailing: Radio<String>(
                                  value: shelfName,
                                  groupValue: selectedShelf,
                                  activeColor: Colorclass.brown,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedShelf = value!;
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _addBookToShelf(String shelfName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final shelfRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shelves')
          .doc(shelfName);

      await shelfRef.update({
        'books': FieldValue.arrayUnion([
          {
            'title': widget.title,
            'imageUrl': widget.imageUrl,
            'overview': widget.overview,
            'author': widget.author,
            'bio': widget.bio,
          }
        ]),
      }).catchError((error) async {
        // إذا لم يكن الرف موجودًا، يتم إنشاؤه
        await shelfRef.set({
          'shelfName': shelfName,
          'books': [
            {
              'title': widget.title,
              'imageUrl': widget.imageUrl,
              'overview': widget.overview,
              'author': widget.author,
              'bio': widget.bio,
            }
          ],
        });
      });
    }
  }
}
