import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/WriteStoryScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class EditStoryForm extends StatefulWidget {
  final Function(BuildContext) showCategorySelection;
  final Function(BuildContext) showSelectLanguage;
  final ValueChanged<bool> onMatureChanged;
  final ValueChanged<bool> onCompletedChanged;

  final String selectedLanguage;
  final bool isMature;
  final bool isCompleted;
  final List<String> selectedCategories;

  const EditStoryForm({
    super.key,
    required this.showCategorySelection,
    required this.showSelectLanguage,
    required this.onMatureChanged,
    required this.onCompletedChanged,
    required this.selectedLanguage,
    required this.isMature,
    required this.isCompleted,
    required this.selectedCategories,
  });

  @override
  State<EditStoryForm> createState() => _EditStoryFormState();
}

class _EditStoryFormState extends State<EditStoryForm> {
  final ImagePicker _picker = ImagePicker();

  // إضافة الـ TextEditingController لجميع الحقول
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController =
      TextEditingController(); // حقل الـ Tags

  late String selectedLanguage;
  late bool isMature;
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    _getUserName();
    _titleController.text = '';
    _descriptionController.text = '';
    _tagsController.text = '';
    selectedLanguage = widget.selectedLanguage;
    isMature = widget.isMature;
    isCompleted = widget.isCompleted;
  }

  @override
  void dispose() {
    // عند مغادرة الصفحة، لا تحفظ القيم إذا لم يتم حفظها
    super.dispose();
  }

  String? _imageUrl; // لتخزين رابط الصورة
  bool _isImageSelected = false; // لتخزين حالة الصورة إذا تم اختيارها أم لا
  String? _userName; // لتخزين اسم المستخدم (username)
  String? customCategory; // لتخزين الفئة المخصصة

  bool get _isFormValid {
    return _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _isImageSelected &&
        _userName != null;
  }

  // دالة لاختيار وتحميل الصورة
  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File imageFile = File(image.path);
    try {
      String fileName =
          'story_covers/${DateTime.now().millisecondsSinceEpoch}.jpg';
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
        _isImageSelected = true;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم رفع الصورة بنجاح')));
    } catch (e) {
      print('حدث خطأ أثناء رفع الصورة: $e');
    }
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['username']; // تخزين اسم المستخدم في المتغير
        });
      }
    }
  }

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
                      icon: const Icon(Icons.keyboard_arrow_down,
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
                    const Text(
                      Textclass.Editstory,
                      style: TextStyles.Bold18,
                    ),
                    TextButton(
                      onPressed: _isFormValid
                          ? () async {
                              String title = _titleController.text;
                              String description = _descriptionController.text;
                              String tags = _tagsController.text;

                              if (!_isImageSelected || _userName == null)
                                return;

                              // إضافة القيمة المدخلة في حقل الفئة المخصصة إذا كانت موجودة
                              List<String> finalCategories =
                                  List.from(widget.selectedCategories);
                              if (customCategory != null &&
                                  customCategory!.isNotEmpty) {
                                finalCategories.add(customCategory!);
                              }

                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;

                              // إضافة القصة إلى قاعدة البيانات وجلب الوثيقة المرجعية
                              DocumentReference docRef =
                                  await firestore.collection('stories').add({
                                'imageUrl': _imageUrl,
                                'title': title,
                                'description': description,
                                'tags': tags,
                                'selectedLanguage': widget.selectedLanguage,
                                'isMature': widget.isMature,
                                'isCompleted': widget.isCompleted,
                                'selectedCategories':
                                    finalCategories, // إضافة الفئات النهائية
                                'author': _userName,
                                'authorId': FirebaseAuth.instance.currentUser
                                    ?.uid, // إضافة authorId
                                'isDraft': false,
                                'readerCount': 0,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              // جلب story id
                              String storyId = docRef.id;

                              // تحديث الوثيقة لإضافة story id
                              await firestore
                                  .collection('stories')
                                  .doc(storyId)
                                  .update({
                                'storyId':
                                    storyId, // إضافة story id إلى الوثيقة
                              });

                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return WriteStoryScreen(
                                    storyId: storyId,
                                    isEdit: false,
                                  );
                                },
                              ));
                            }
                          : null,
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
                          image: _imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            _pickAndUploadImage();
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
                _buildTextFieldWithValidation(
                  Textclass.Title,
                  _titleController,
                ),
                _buildTextFieldWithValidation(
                  Textclass.Description,
                  _descriptionController,
                ),

                // Category Section
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => widget.showCategorySelection(context),
                        child: Row(
                          children: [
                            const Text(
                              Textclass.Category,
                              style: TextStyles.normal16,
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            if (widget.selectedCategories.isNotEmpty)
                              Expanded(
                                child: Text(
                                  widget.selectedCategories.join(', '),
                                  overflow: TextOverflow
                                      .ellipsis, // إذا كانت النصوص طويلة
                                  style: const TextStyle(
                                    color: Colorclass.brown,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                        child: Divider(height: 1, color: Colorclass.brown),
                      ),
                    ],
                  ),
                ),

                // Tags Text Field
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _buildTextFieldWithValidation(
                    Textclass.Tags,
                    _tagsController,
                  ), // إضافة حقل Tags
                ),

                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => widget.showSelectLanguage(context),
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
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          child: Divider(
                            height: 1,
                            color: selectedLanguage.isEmpty
                                ? Colorclass.Red
                                : Colorclass
                                    .brown, // تغيير اللون إذا كان فارغًا
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -40),
                  child: _transformswitchbutton(Textclass.Mature, isMature,
                      (value) {
                    setState(() {
                      isMature = value;
                    });
                    widget.onMatureChanged(value);
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
                    setState(() {
                      isCompleted = value;
                    });
                    widget.onCompletedChanged(value);
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
              setState(() {
                onChanged(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithValidation(
    String labelText,
    TextEditingController controller,
  ) {
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
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: controller, // إضافة الـ controller هنا
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colorclass
                          .brown, // إذا كان الحقل غير فارغ، يبقى اللون كما هو
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colorclass.brown,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colorclass.brown,
                    ),
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