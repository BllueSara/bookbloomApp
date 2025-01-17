import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart'; // استيراد كلاس النصوص

class WriteStoryScreen extends StatefulWidget {
  const WriteStoryScreen({super.key});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  String selectedPart = "Part 1"; // الجزء المختار

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
                      // جزء "Part 1" مع السهم كزر قابل للضغط
                      const SizedBox(
                        width: 0,
                      ),
                      Theme(
                        data: ThemeData(
                            popupMenuTheme: const PopupMenuThemeData(
                          color: Colorclass.white,
                        )),
                        child: PopupMenuButton<String>(
                          onSelected: (String value) {
                            setState(() {
                              selectedPart = value; // تحديث الجزء المختار
                            });
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
                              DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: Colorclass.white, // لون الخلفية
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      2.0), // مسافة داخلية إذا لزم الأمر
                                  child: Text(
                                    selectedPart,
                                    style: TextStyles.Bold16.copyWith(
                                      color: Colorclass.brown, // لون النص
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colorclass.brown,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // زر النشر
                      ElevatedButton(
                        onPressed: () {
                          // حدث النشر
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
                // باقي المحتوى
                Center(
                  child: Column(
                    children: [
                      Text(
                        Textclass.part, // استدعاء النص من كلاس النصوص
                        style: TextStyles.normal18.copyWith(
                          color: Colorclass.gbrown,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        color: Colorclass.shelf,
                        thickness: 1,
                        indent: 40,
                        endIndent: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Textclass.start, // استدعاء النص من كلاس النصوص
                        style: TextStyles.normal16.copyWith(
                          color: Colorclass.gbrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // زر الحفظ كمسودة في الأسفل
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    // حدث الحفظ كمسودة
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