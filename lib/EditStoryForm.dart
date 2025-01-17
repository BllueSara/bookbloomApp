import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/WriteStoryScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditStoryForm extends StatelessWidget {
  final Function(BuildContext) showCategorySelection;
  final Function(BuildContext) showSelectLanguage;
  final ValueChanged<bool> onCopyrightChanged;
  final ValueChanged<bool> onMatureChanged;
  final ValueChanged<bool> onCompletedChanged;
  final String selectedLanguage;
  final bool isCopyright;
  final bool isMature;
  final bool isCompleted;
  final List<String> selectedCategories;

  const EditStoryForm({
    Key? key,
    required this.showCategorySelection,
    required this.showSelectLanguage,
    required this.onCopyrightChanged,
    required this.onMatureChanged,
    required this.onCompletedChanged,
    required this.selectedLanguage,
    required this.isCopyright,
    required this.isMature,
    required this.isCompleted,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colorclass.brown, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                    Text(
                      Textclass.Editstory,
                      style: TextStyles.Bold18,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return const WriteStoryScreen();
                          },
                        ));
                      },
                      child: Text(
                        Textclass.Save,
                        style: TextStyles.Bold18.copyWith(
                          color: Colorclass.brown,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 150,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colorclass.grey,
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('images/book1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            // Add cover action
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 80,
                            color: Colorclass.addicon,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      Textclass.AddACover,
                      style: TextStyles.Bold16,
                    ),
                  ],
                ),
                _buildTextFieldWithValidation(Textclass.Title),
                _buildTextFieldWithValidation(Textclass.Description),

                // Category Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => showCategorySelection(context),
                        child: const Row(
                          children: [
                            Text(
                              Textclass.Category,
                              style: TextStyles.normal16,
                            ),
                            Text(
                              ' *',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                        child: Divider(
                          height: 1,
                          color: Colorclass.brown,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tags Text Field
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _buildTextFieldWithValidation(Textclass.Tags),
                ),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => showSelectLanguage(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    Textclass.StoryLanguage,
                                    style: TextStyles.normal16,
                                  ),
                                  Text(
                                    ' *',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 18),
                                  ),
                                ],
                              ),
                              Text(
                                selectedLanguage,
                                style: TextStyles.normal16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                          child: Divider(
                            height: 1,
                            color: Colorclass.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _transformswitchbutton(
                      Textclass.Copyright, isCopyright, (value) {
                    onCopyrightChanged(value);
                  }),
                ),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _transformswitchbutton(Textclass.Mature, isMature,
                      (value) {
                    onMatureChanged(value);
                  }),
                ),
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: Text(
                    Textclass.HintMature,
                    style:
                        TextStyles.hint14.copyWith(color: Colorclass.lightgray),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _transformswitchbutton(
                      Textclass.Completed, isCompleted, (value) {
                    onCompletedChanged(value);
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _transformswitchbutton(
      String labelText, bool switchValue, ValueChanged<bool> onChanged) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            labelText,
            style: TextStyles.normal18,
          ),
          CupertinoSwitch(
            value: switchValue,
            activeColor: Colorclass.gbrown,
            onChanged: (value) {
              // تغيير حالة الـ Switch بشكل فوري عند التفاعل
              onChanged(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithValidation(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Row(
            children: [
              Text(
                labelText,
                style: TextStyles.normal16,
              ),
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ],
          ),
          const Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colorclass.brown),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colorclass.brown),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colorclass.brown),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
