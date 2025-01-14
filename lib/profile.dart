import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String displayName = "Display Name"; // الاسم المعروض الافتراضي
  String username = ""; // اسم المستخدم الافتراضي
  String email = ""; // البريد الإلكتروني الافتراضي
  String password = ""; // كلمة المرور الافتراضية
  bool isDarkMode = false; // الوضع الافتراضي (Light Mode)

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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colorclass.brown),
              title: Text("Choose from gallery",
                  style: TextStyles.hint14.copyWith(color: Colorclass.brown)),
              onTap: () {
                // إضافة خاصية اختيار صورة من المعرض
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colorclass.brown),
              title: Text("Take a photo",
                  style: TextStyles.hint14.copyWith(color: Colorclass.brown)),
              onTap: () {
                // إضافة خاصية التقاط صورة بالكاميرا
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colorclass.brown),
              title: Text("Remove photo",
                  style: TextStyles.hint14.copyWith(color: Colorclass.brown)),
              onTap: () {
                setState(() {
                  // إعادة الصورة الافتراضية
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // خاصية التأكيد عند تسجيل الخروج أو حذف الحساب
  void _confirmAction(String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            action == "logout" ? "Log Out" : "Delete Account",
            style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
          ),
          content: Text(
            action == "logout"
                ? "Are you sure you want to log out?"
                : "Are you sure you want to delete your account?",
            style: TextStyles.hint14.copyWith(color: Colorclass.brown),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyles.hint14.copyWith(color: Colorclass.brown),
              ),
            ),
            TextButton(
              onPressed: () {
                if (action == "logout") {
                  // تسجيل الخروج
                } else {
                  // حذف الحساب
                }
                Navigator.of(context).pop();
              },
              child: Text(
                action == "logout" ? "Log Out" : "Delete",
                style: TextStyles.Bold16.copyWith(color: Colorclass.Red),
              ),
            ),
          ],
        );
      },
    );
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
          icon: const Icon(Icons.arrow_back, color: Colorclass.brown),
          onPressed: () {
            // يمكن إضافة وظيفة العودة هنا
          },
        ),
        title: Text(
          Textclass.Myprofile,
          style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
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
                    onTap: _changeProfilePicture, // خاصية تغيير الصورة
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
                Text(
                  displayName,
                  style: TextStyles.normal16.copyWith(color: Colorclass.brown),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: _editDisplayName, // خاصية تعديل الاسم المعروض
                  child: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Colorclass.brown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // حقل اسم المستخدم
            _buildField("user name", Icons.edit, "username"),
            const SizedBox(height: 20),
            // حقل البريد الإلكتروني
            _buildField("email", Icons.lock, "email"),
            const SizedBox(height: 20),
            // حقل كلمة المرور
            _buildField("password", Icons.lock, "password"),
            const SizedBox(height: 30),
            // مستطيل Mode مع السويتش
            Align(
              alignment: Alignment.centerLeft,
              child: _buildModeSwitch(),
            ),
            const Spacer(),
            // مستطيل Log Out
            GestureDetector(
              onTap: () => _confirmAction("logout"),
              child: _buildLogoutButton(),
            ),
            const SizedBox(height: 10),
            // نص Delete Your Account
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

  // مكون بناء الحقول
  Widget _buildField(String hint, IconData icon, String field) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: Colorclass.gradient,
      ),
      child: Center(
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colorclass.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                if (field == "username") username = value;
                if (field == "email") email = value;
                if (field == "password") password = value;
              });
            },
            textAlign: TextAlign.start,
            style: TextStyles.normal16.copyWith(color: Colorclass.brown),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyles.hint14.copyWith(color: Colorclass.grey),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              suffixIcon: Icon(
                icon,
                size: 20,
                color: Colorclass.brown,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // مكون بناء مستطيل الوضع Mode مع السويتش
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

  // مستطيل Log Out
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

  // نص Delete Your Account
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
