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
  List<String> parts = ["Part 1"]; // الجزء الافتراضي "Part 1"

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

    _showSuccessDialog(context, isDraft);

    if (!isDraft) {
      Navigator.pop(context, partContent); // تمرير النص المُحدث عند العودة
    }
  }

  void _showSuccessDialog(BuildContext context, bool isDraft) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colorclass.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDraft
                    ? 'Draft saved successfully'
                    : 'Part published successfully',
                style: TextStyles.normal18.copyWith(
                  color: Colorclass.brown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colorclass.brown, Colorclass.dustyPink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: TextStyles.normal16.copyWith(
                      color: Colorclass.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_backspace,
                            color: Colorclass.brown, size: 40),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      PopupMenuButton<String>(
                        color: Colorclass.white,
                        onSelected: (String value) {
                          if (value == "add") {
                            setState(() {
                              parts.add("Part ${parts.length + 1}");
                              selectedPart = parts.last;
                            });
                          } else {
                            setState(() {
                              selectedPart = value;
                              _loadPartContent();
                            });
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            ...parts.map(
                              (part) => PopupMenuItem<String>(
                                value: part,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      part,
                                      style: TextStyles.normal16.copyWith(
                                        color: Colorclass.brown,
                                      ),
                                    ),
                                    if (part != "Part 1") // منع حذف الجزء الافتراضي
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colorclass.dustyPink,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            parts.remove(part);
                                            if (selectedPart == part) {
                                              selectedPart = parts.first;
                                              _partContentController.clear();
                                            }
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: "add",
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Add Part",
                                    style: TextStyles.normal16.copyWith(
                                      color: Colorclass.dustyPink,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add,
                                    color: Colorclass.dustyPink,
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
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
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Part Title",
                            hintStyle: TextStyles.normal18.copyWith(
                              color: Colorclass.addicon,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyles.normal18.copyWith(
                            color: Colorclass.addicon,
                          ),
                          onChanged: (value) {
                            selectedPart = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a part title';
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 110),
                    child: TextField(
                      controller: _partContentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: Textclass.start,
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
