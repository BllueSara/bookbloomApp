import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookbloom/mainpage.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';

class WriteStoryScreen extends StatefulWidget {
  final String storyId;
  final bool isEdit; // خاصية جديدة للتحقق إذا كانت حالة التعديل

  const WriteStoryScreen(
      {required this.storyId, super.key, required this.isEdit});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final TextEditingController _partContentController = TextEditingController();
  final TextEditingController _titleContentController = TextEditingController();

  String selectedPart = "Part 1";
  List<String> parts = ["Part 1"];
  Map<String, Map<String, String>> storyParts = {
    "Part 1": {"title": "", "content": ""}
  };
  bool isEditingTitle = false;
  bool isEditingContent = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _fetchPartsFromFirestore(); // تحميل الأجزاء من Firestore فقط عند التعديل
    }
  }

  Future<void> _fetchPartsFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot partsSnapshot = await firestore
        .collection('stories')
        .doc(widget.storyId)
        .collection('parts')
        .get();

    setState(() {
      parts = partsSnapshot.docs.map((doc) => doc.id).toList();
      storyParts = {
        for (var doc in partsSnapshot.docs)
          doc.id: {"title": doc['partTitle'], "content": doc['content']}
      };
      if (parts.isNotEmpty) {
        selectedPart = parts.first;
        _titleContentController.text = storyParts[selectedPart]?["title"] ?? "";
        _partContentController.text =
            storyParts[selectedPart]?["content"] ?? "";
      }
    });
  }

  Future<void> _updatePartToFirestore(String partId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore
          .collection('stories')
          .doc(widget.storyId)
          .collection('parts')
          .doc(partId)
          .update({
        'partTitle': _titleContentController.text,
        'content': _partContentController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        storyParts[partId] = {
          "title": _titleContentController.text,
          "content": _partContentController.text,
        };
        isEditingTitle = false;
        isEditingContent = false;
      });
    } catch (e) {}
  }

  void _switchPart(String part) {
    setState(() {
      if (_titleContentController.text.isNotEmpty ||
          _partContentController.text.isNotEmpty) {
        // تحديث الجزء الحالي فقط إذا تغير المحتوى
        if (_titleContentController.text !=
                storyParts[selectedPart]?["title"] ||
            _partContentController.text !=
                storyParts[selectedPart]?["content"]) {
          storyParts[selectedPart] = {
            "title": _titleContentController.text,
            "content": _partContentController.text,
          };
          _updatePartToFirestore(selectedPart);
        }
      }

      selectedPart = part;
      _titleContentController.text = storyParts[part]?["title"] ?? "";
      _partContentController.text = storyParts[part]?["content"] ?? "";
    });
  }

  Future<void> _publishAllParts({required bool isDraft}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // تحديث الجزء الحالي بالمحتوى الموجود في الحقول النصية
    storyParts[selectedPart] = {
      "title": _titleContentController.text,
      "content": _partContentController.text,
    };

    for (var part in parts) {
      final title = storyParts[part]?["title"] ?? "";
      final content = storyParts[part]?["content"] ?? "";

      if (title.isNotEmpty && content.isNotEmpty) {
        // إذا كانت حالة التعديل، قم بالتحديث بدلاً من الإضافة
        final docRef = firestore
            .collection('stories')
            .doc(widget.storyId)
            .collection('parts')
            .doc(part);

        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          await docRef.update({
            'partTitle': title,
            'content': content,
            'isDraft': isDraft,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await docRef.set({
            'partTitle': title,
            'content': content,
            'isDraft': isDraft,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    // تحديث حالة المسودة في المستند الرئيسي
    if (isDraft) {
      await firestore.collection('stories').doc(widget.storyId).update({
        'isDraft': true,
      });
    } else {
      await firestore.collection('stories').doc(widget.storyId).update({
        'isDraft': false,
      });
    }

    _showSuccessDialog(context, isDraft);
  }

  void _addPart() {
    setState(() {
      if (_titleContentController.text.isNotEmpty ||
          _partContentController.text.isNotEmpty) {
        storyParts[selectedPart] = {
          "title": _titleContentController.text,
          "content": _partContentController.text,
        };
      }

      final newPart = "Part ${parts.length + 1}";
      parts.add(newPart);
      storyParts[newPart] = {"title": "", "content": ""};

      selectedPart = newPart;
      _titleContentController.clear();
      _partContentController.clear();
    });
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
                    : 'story published successfully',
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
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const MainPage(index: 1);
                    },
                  )),
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
                            _addPart();
                          } else {
                            _switchPart(value);
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
                                    // عرض العنوان حسب حالة isEdit
                                    if (widget.isEdit)
                                      Text(
                                        storyParts[part]?['title'] ??
                                            'No Title',
                                        style: TextStyles.normal16.copyWith(
                                          color: Colorclass.brown,
                                        ),
                                      )
                                    else
                                      Text(
                                        part,
                                        style: TextStyles.normal16.copyWith(
                                          color: Colorclass.brown,
                                        ),
                                      ),

                                    // زر الحذف
                                    if (part != "Part 1")
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colorclass.dustyPink,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (parts.contains(part)) {
                                              parts.remove(part);
                                              storyParts.remove(part);
                                            }
                                            if (selectedPart == part) {
                                              selectedPart = parts.first;
                                              _titleContentController.text =
                                                  storyParts[selectedPart]
                                                          ?["title"] ??
                                                      "";
                                              _partContentController.text =
                                                  storyParts[selectedPart]
                                                          ?["content"] ??
                                                      "";
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
                              widget.isEdit
                                  ? (storyParts[selectedPart]?['title'] ??
                                      'No Title')
                                  : selectedPart,
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
                          _publishAllParts(isDraft: false);
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: _titleContentController,
                          textAlign: TextAlign.center,
                          style: TextStyles.normal18.copyWith(
                            color: Colorclass.addicon,
                          ),
                          decoration: InputDecoration(
                            hintText: "Part Title",
                            labelStyle: TextStyles.normal16.copyWith(
                              color: Colorclass.addicon,
                            ),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a part title';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              isEditingTitle = value.isNotEmpty;
                            });
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
                    _publishAllParts(isDraft: true);
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