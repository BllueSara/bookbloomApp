import 'package:bookbloom/resetpassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/SplachScreen.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // تحميل البيانات من Firestore
  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        displayName = user.displayName ?? "No Display Name";
        username = userData['username'] ?? "";
        email = user.email ?? "";
        _usernameController.text = username;
        _emailController.text = email;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // تحميل بيانات المستخدم عند بدء التطبيق
  }

  // خاصية تعديل الاسم المعروض
  void _editDisplayName() {
    final TextEditingController controller =
        TextEditingController(text: displayName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Edit Display Name",
            style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colorclass.grey),
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  displayName = controller.text; // تحديث الاسم المعروض
                });
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({'displayName': displayName});
                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
              ),
            ),
          ],
        );
      },
    );
  }

  // خاصية تغيير صورة العرض
  void _changeProfilePicture() {
    // لوظيفتك المتعلقة بتغيير صورة الملف الشخصي
  }

  // خاصية التأكيد عند تسجيل الخروج أو حذف الحساب
  void _confirmAction(String action) {
    if (action == "logout") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Are you sure you want to log out?",
              style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const Splachscreen()));
                },
                child: Text(
                  "Log Out",
                  style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
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
            title: Text(
              "Are you sure you want to delete your account?",
              style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
                ),
              ),
              TextButton(
                onPressed: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .delete();
                    await user.delete();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const Splachscreen()));
                  }
                },
                child: Text(
                  "Delete Account",
                  style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  // خاصية تغيير وضع التطبيق
  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      appBar: AppBar(
        backgroundColor: Colorclass.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace,
              color: Colorclass.brown, size: 30),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // الصورة الشخصية مع أيقونة المرسام
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/avatar1.png'),
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
            Align(
              alignment: Alignment.centerLeft,
              child: _buildModeSwitch(),
            ),
            const SizedBox(
              height: 50,
            ), // المسافة لزر تسجيل الخروج
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
    );
  }

  Widget _buildContainer(String hint, String value, Icon icon,
      {bool isPassword = false}) {
    return GestureDetector(
      onTap: () {
        if (hint == "Password") {
          // الانتقال إلى صفحة Reset Password عند الضغط على كلمة المرور
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Resetpassword()),
          );
          return;
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final TextEditingController controller =
                TextEditingController(text: value);
            return AlertDialog(
              title: Text(
                "Edit $hint",
                style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
              ),
              content: TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  hintText: "Enter new $hint",
                  hintStyle: TextStyles.hint14.copyWith(color: Colorclass.grey),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (hint == "Username") {
                        username = controller.text;
                      } else if (hint == "Email") {
                        email = controller.text;
                      }
                    });
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({hint.toLowerCase(): controller.text});
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Save",
                    style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
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

  Widget _buildModeSwitch() {
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: Colorclass.gradient,
      ),
      child: Center(
        child: Container(
          height: 40,
          width: 140,
          decoration: BoxDecoration(
            color: Colorclass.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Mode",
                  style: TextStyles.normal16.copyWith(color: Colorclass.brown),
                ),
              ),
              Switch(
                value: isDarkMode,
                onChanged: _toggleDarkMode,
                activeColor: Colorclass.brown,
                inactiveThumbColor: Colorclass.grey,
              ),
            ],
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