import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookbloom/mainpage.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';

class WriteStoryScreen extends StatefulWidget {
  final String storyId;

  const WriteStoryScreen({required this.storyId, super.key});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final TextEditingController _partContentController = TextEditingController();
  String selectedPart = "Part 1";

  Future<void> _loadPartContent() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore
        .collection('stories')
        .doc(widget.storyId)
        .collection('parts')
        .where('partTitle', isEqualTo: selectedPart)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String content = snapshot.docs.first['content'];
      _partContentController.text = content;
    } else {
      _partContentController.clear();
    }
  }

  Future<void> _savePart(String partContent, {bool isDraft = false}) async {
    if (partContent.isEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore
        .collection('stories')
        .doc(widget.storyId)
        .collection('parts')
        .add({
      'partTitle': selectedPart,
      'content': partContent,
      'isDraft': isDraft,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isDraft ? 'تم حفظ المسودة بنجاح' : 'تم نشر الجزء بنجاح'),
    ));

    if (!isDraft) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(index: 1),
        ),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPartContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // شريط الأدوات العلوي
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر العودة
                      IconButton(
                        icon: const Icon(Icons.keyboard_backspace,
                            color: Colorclass.brown, size: 40),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10,),
                      // اختيار الجزء
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          setState(() {
                            selectedPart = value;
                          });
                          _loadPartContent();
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: "Part 1",
                            child: Text(
                              "Part 1",
                              style: TextStyles.normal16.copyWith(
                                color: Colorclass.brown,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: "Part 2",
                            child: Text(
                              "Part 2",
                              style: TextStyles.normal16.copyWith(
                                color: Colorclass.brown,
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: "Part 3",
                            child: Text(
                              "Part 3",
                              style: TextStyles.normal16.copyWith(
                                color: Colorclass.brown,
                              ),
                            ),
                          ),
                        ],
                        child: Row(
                          children: [
                            Text(
                              selectedPart,
                              style: TextStyles.Bold16.copyWith(
                                color: Colorclass.brown,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down,
                                color: Colorclass.brown),
                          ],
                        ),
                      ),
                      // زر النشر
                      ElevatedButton(
                        onPressed: () {
                          _savePart(_partContentController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colorclass.dustyPink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          Textclass.Publish,
                          style: TextStyles.Bold16.copyWith(
                            color: Colorclass.brown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // اسم البارت مع خط
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          initialValue:
                              "Part Title", // القيمة الافتراضية لعنوان البارت
                          textAlign: TextAlign.center, // توسيط النص داخل الحقل
                          decoration: InputDecoration(
                            hintText: "Part Title", // النص التوجيهي
                            hintStyle: TextStyles.normal18.copyWith(
                              color: Colorclass.addicon, // لون النص التوجيهي
                            ),
                            border: InputBorder
                                .none, // إزالة الحدود الافتراضية للحقل
                          ),
                          style: TextStyles.normal18.copyWith(
                            color: Colorclass.addicon, // لون النص
                          ),
                          onChanged: (value) {
                            // تحديث عنوان البارت عند تغييره
                            selectedPart = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a part title'; // رسالة خطأ عند ترك الحقل فارغًا
                            }
                            return null;
                          },
                        ),
                      ),
                      const Divider(
                        color: Colorclass.brown,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                    ],
                  ),
                ),

                // حقل الكتابة
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 110),
                    child: TextField(
                      controller: _partContentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: Textclass.start, // النص التوجيهي
                        hintStyle: TextStyles.normal16.copyWith(
                          color: Colorclass.addicon,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // زر الحفظ كمسودة
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    _savePart(_partContentController.text, isDraft: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorclass.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    Textclass.Draft,
                    style: TextStyles.Bold16.copyWith(
                      color: Colorclass.brown,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
