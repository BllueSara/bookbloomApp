import 'package:bookbloom/resetpassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/SplachScreen.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String displayName = "Loading..."; // الاسم المعروض الافتراضي
  String username = ""; // اسم المستخدم الافتراضي
  String email = ""; // البريد الإلكتروني الافتراضي
  String password = ""; // كلمة المرور الافتراضية
  bool isDarkMode = false; // الوضع الافتراضي (Light Mode)
  String selectedImage = ''; // لتخزين الصورة المختارة مؤقتًا
  String profilePicture = 'images/avatar1.png'; // الصورة الافتراضية
  String bio = ''; // لتخزين وصف المستخدم

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // تحميل البيانات من Firestore
  @override
  void initState() {
    super.initState();
    _loadUserData(); // تحميل بيانات المستخدم عند بدء التطبيق
    _loadProfilePicture();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        displayName = userData['displayName'] ??
            "No Display Name"; // تأكد من تحميل displayName من Firestore
        username = userData['username'] ?? "";
        bio = userData['bio'] ?? ""; // تحميل الوصف
        email = user.email ?? "";
        _usernameController.text = username;
        _emailController.text = email;
        _bioController.text = bio;
      });
    }
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePicture =
          prefs.getString('profilePicture') ?? 'images/avatar1.png';
    });
  }

  Future<void> _saveProfilePicture(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePicture', imagePath);
  }

  // خاصية تعديل الاسم المعروض
  void _editDisplayName() {
    final TextEditingController controller =
        TextEditingController(text: displayName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colorclass.white,
          title: Text(
            "Edit Display Name",
            style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colorclass.brown),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colorclass.brown),
              ),
              hintText: "Enter new display name",
              hintStyle: TextStyles.hint14.copyWith(color: Colorclass.grey),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colorclass.brown,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyles.Bold16.copyWith(
                              color: Colorclass.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colorclass.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            displayName = controller.text; // تحديث الاسم
                          });
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({'displayName': displayName});

                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save",
                          style: TextStyles.Bold16.copyWith(
                              color: Colorclass.brown),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // خاصية تغيير صورة العرض
  void _changeProfilePicture() async {
    final List<String> availableImages = [
      'images/avatar1.png',
      'images/Avatar2.png',
      'images/Avatar3.png',
      'images/Avatar4.png',
      'images/Avatar5.png',
      'images/Avatar6.png',
    ]; // قائمة الصور المتوفرة داخل التطبيق

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الشريط العلوي يحتوي على زر الإغلاق والنص
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose Profile Picture",
                        style:
                            TextStyles.Bold16.copyWith(color: Colorclass.brown),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colorclass.brown),
                        onPressed: () {
                          Navigator.of(context).pop(); // إغلاق النافذة
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // عدد الأعمدة في الشبكة
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: availableImages.length,
                      itemBuilder: (context, index) {
                        final imagePath = availableImages[index];
                        return GestureDetector(
                          onTap: () {
                            setStateModal(() {
                              selectedImage =
                                  imagePath; // تخزين الصورة المختارة
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                              if (selectedImage == imagePath)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colorclass.brown,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colorclass.brown,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              if (selectedImage.isNotEmpty) {
                                await _saveProfilePicture(
                                    selectedImage); // حفظ الصورة

                                setState(() {
                                  profilePicture = selectedImage;
                                });
                                Navigator.of(context).pop(); // إغلاق النافذة
                              }
                            },
                            child: Text(
                              "Save",
                              style: TextStyles.Bold16.copyWith(
                                  color: Colorclass.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // خاصية التأكيد عند تسجيل الخروج أو حذف الحساب
  void _confirmAction(String action) {
    if (action == "logout") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colorclass.white,
            title: Text(
              "Log Out",
              style: TextStyles.Bold18.copyWith(color: Colorclass.brown),
            ),
            content: Text(
              "Are you sure you want to log out?",
              style: TextStyles.normal16.copyWith(color: Colorclass.brown),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر Cancel باللون البني
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colorclass.brown,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // إغلاق النافذة
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyles.Bold16.copyWith(
                                color: Colorclass.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // زر Log Out باللون الرمادي
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colorclass.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const Splachscreen()));
                          },
                          child: Text(
                            "Log Out",
                            style: TextStyles.Bold16.copyWith(
                                color: Colorclass.brown),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else if (action == "delete") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colorclass.white,
            title: Text(
              "Delete Account",
              style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
            ),
            content: Text(
              "Are you sure you want to delete your account?",
              style: TextStyles.normal16.copyWith(color: Colorclass.brown),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر Cancel باللون البني
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colorclass.brown,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // إغلاق النافذة
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyles.Bold16.copyWith(
                                color: Colorclass.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // زر Delete باللون الرمادي
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colorclass.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // إغلاق النافذة الأولى
                            _showPasswordDialog(); // عرض نافذة المصادقة
                          },
                          child: Text(
                            "Delete",
                            style: TextStyles.Bold16.copyWith(
                                color: Colorclass.brown),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }
  }

// عرض نافذة المصادقة لطلب كلمة المرور
  void _showPasswordDialog() {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colorclass.white,
          title: Text(
            "Confirm Deletion",
            style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Please enter your password to confirm account deletion:",
                style: TextStyles.normal16.copyWith(color: Colorclass.brown),
              ),
              const SizedBox(height: 10),
              // حقل كلمة المرور
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Password",
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر Cancel باللون البني
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colorclass.brown,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // إغلاق النافذة
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyles.Bold16.copyWith(
                              color: Colorclass.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // زر Delete باللون الرمادي
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colorclass.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          String password = passwordController.text.trim();
                          if (password.isEmpty) {
                            _showErrorDialog("Password cannot be empty");
                            return;
                          }
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            try {
                              // إعادة المصادقة
                              final credential = EmailAuthProvider.credential(
                                email: user.email!,
                                password: password,
                              );
                              await user
                                  .reauthenticateWithCredential(credential);

                              // حذف البيانات من Firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .delete();

                              // حذف المستخدم من Authentication
                              await user.delete();

                              // الانتقال إلى شاشة البداية
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Splachscreen(),
                                ),
                              );
                            } catch (e) {
                              _showErrorDialog(
                                  'Error: ${e.toString()}'); // عرض رسالة خطأ
                            }
                          }
                        },
                        child: Text(
                          "Delete",
                          style: TextStyles.Bold16.copyWith(
                              color: Colorclass.brown),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

// عرض رسالة الخطأ بتصميم محدّث
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colorclass.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyles.normal18.copyWith(color: Colorclass.brown),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // زر OK بتصميم Gradient
              Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colorclass.brown, Colorclass.dustyPink],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: MaterialButton(
                  onPressed: () => Navigator.pop(context),
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
      appBar: AppBar(
        backgroundColor: Colorclass.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace,
              color: Colorclass.dustyPink, size: 40),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Textclass.Myprofile,
          style: TextStyles.Bold18.copyWith(color: Colorclass.brown),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // الصورة الشخصية مع أيقونة المرسام
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(profilePicture),
                    backgroundColor: Colorclass.grey,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _changeProfilePicture,
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colorclass.brown,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // الاسم المعروض مع أيقونة المرسام
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _editDisplayName,
                    child: Text(
                      displayName,
                      style:
                          TextStyles.normal16.copyWith(color: Colorclass.brown),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _editDisplayName,
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colorclass.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // الحقول
              _buildContainer(
                "Username",
                username,
                const Icon(
                  Icons.person,
                  color: Colorclass.brown,
                ),
              ),
              const SizedBox(height: 20),
              _buildContainer(
                "Bio",
                bio,
                const Icon(
                  Icons.biotech,
                  color: Colorclass.brown,
                ),
              ),
              const SizedBox(height: 20),

              _buildContainer(
                "Email",
                email,
                const Icon(
                  Icons.email,
                  color: Colorclass.brown,
                ),
              ),

              const SizedBox(height: 20),
              _buildContainer(
                  "Password",
                  password,
                  const Icon(
                    Icons.lock,
                    color: Colorclass.brown,
                  ),
                  isPassword: true),
              const SizedBox(height: 30),

              // المسافة لزر تسجيل الخروج
              GestureDetector(
                onTap: () => _confirmAction("logout"),
                child: _buildLogoutButton(),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _confirmAction("delete"),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: _buildDeleteAccountText(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(String hint, String value, Icon icon,
      {bool isPassword = false}) {
    return GestureDetector(
      onTap: () {
        // لا يمكن تعديل الإيميل
        if (hint == "Email") return;

        if (hint == "Password") {
          // الانتقال إلى صفحة Reset Password عند الضغط على كلمة المرور
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Resetpassword()),
          );
          return;
        }

        final TextEditingController controller =
            TextEditingController(text: value);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colorclass.white,
              title: Text(
                "Edit $hint",
                style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colorclass.brown),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colorclass.brown),
                  ),
                  hintText: "Enter new $hint",
                  hintStyle: TextStyles.hint14.copyWith(color: Colorclass.grey),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colorclass.brown,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyles.Bold16.copyWith(
                                  color: Colorclass.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colorclass.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final newValue = controller.text;
                              if (hint == "Username") {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({'username': newValue});
                                setState(() {
                                  username = newValue;
                                });
                              } else if (hint == "Display Name") {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({'displayName': newValue});
                                await FirebaseAuth.instance.currentUser!
                                    .updateDisplayName(newValue);
                                setState(() {
                                  displayName = newValue;
                                });
                              } else if (hint == "Bio") {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({'bio': newValue});
                                setState(() {
                                  bio = newValue;
                                });
                              }

                              // إعادة تحميل البيانات
                              await _loadUserData();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Save",
                              style: TextStyles.Bold16.copyWith(
                                  color: Colorclass.brown),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: Colorclass.gradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 40,
              decoration: BoxDecoration(
                color: Colorclass.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    "$hint: ",
                    style:
                        TextStyles.normal16.copyWith(color: Colorclass.brown),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyles.normal16
                          .copyWith(color: Colorclass.dustyPink),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  icon,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: Colorclass.gradient,
      ),
      child: Center(
        child: Text(
          "Log Out",
          style: TextStyles.Bold18.copyWith(color: Colorclass.white),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Delete Your Account",
            style: TextStyles.hint14.copyWith(color: Colorclass.Red),
          ),
          const SizedBox(height: 2),
          LayoutBuilder(
            builder: (context, constraints) {
              final textWidth = TextPainter(
                text: TextSpan(
                  text: "Delete Your Account",
                  style: TextStyles.hint14.copyWith(color: Colorclass.Red),
                ),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout();

              return Container(
                height: 1.5,
                width: textWidth.size.width,
                color: Colorclass.Red,
              );
            },
          ),
        ],
      ),
    );
  }
}