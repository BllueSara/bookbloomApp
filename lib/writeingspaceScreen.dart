import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/EditStoryForm.dart';
import 'package:flutter/material.dart';

class Writeingspacescreen extends StatefulWidget {
  const Writeingspacescreen({super.key});

  @override
  State<Writeingspacescreen> createState() => _WriteingspacescreenState();
}

class _WriteingspacescreenState extends State<Writeingspacescreen> {
  final List<String> books = [
    'images/book1.png',
    'images/book2.png',
  ];
  final List<String> picks = [
    'images/book1.png',
    'images/book2.png',
  ];

  List<String> selectedCategories = [];

  bool isCopyright = false; // متغير لحالة Switch
  bool isMature = false; // متغير لحالة Switch
  bool isCompleted = false; // متغير لحالة Switch
  String selectedLanguage = 'English'; // المتغير لتخزين اللغة المختارة

  void showEditStoryForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return EditStoryForm(
          showCategorySelection: _showCategorySelection,
          showSelectLanguage: _showSelectLanguage,
          onCopyrightChanged: (value) {
            setState(() {
              isCopyright = value;
            });
          },
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
          isCopyright: isCopyright,
          isMature: isMature,
          isCompleted: isCompleted,
          selectedCategories: selectedCategories,
        );
      },
    );
  }

  void _showSelectLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Arabic"),
                leading: Radio<String>(
                  value: "Arabic",
                  activeColor: Colorclass.brown,
                  groupValue: selectedLanguage,
                  onChanged: (String? value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: const Text("English"),
                leading: Radio<String>(
                  value: "English",
                  activeColor: Colorclass.brown,
                  groupValue: selectedLanguage,
                  onChanged: (String? value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategorySelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                          // Handle user input for 'Other'
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
      appBar: AppBar(
          title: const Text(
            Textclass.Inkspire,
            style: TextStyles.Bold24,
            textAlign: TextAlign.center,
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          forceMaterialTransparency: true,
          centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('images/avatar1.png'),
              radius: 40,
            ),
            const SizedBox(height: 25),
            const Text(
              Textclass.displayname,
              style: TextStyles.Bold18,
            ),
            const Text(
              '@Username',
              style: TextStyles.hint14,
            ),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  Textclass.Book,
                  style: TextStyles.normal16,
                ),
                Text(
                  Textclass.Readers,
                  style: TextStyles.normal16,
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
                itemCount: books.length + 1,
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
                    return Container(
                      width: 120,
                      height: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colorclass.grey,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(books[index - 1]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
            Transform.translate(
              offset: const Offset(-130, 0),
              child: const Text(
                Textclass.MyPicks,
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
