import 'package:bookbloom/LoginScreen.dart';
import 'package:bookbloom/mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  String displayName = '';
  String username = '';
  String email = '';
  String password = '';
  bool obscurePassword = true;

  // Controllers for form fields
  TextEditingController displayNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signUp() async {
    if (displayName.isEmpty) {
      _showErrorDialog('Please enter a display name.');
      return;
    }
    if (username.isEmpty) {
      _showErrorDialog('Please enter a username.');
      return;
    }
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorDialog('Please enter a valid email address.');
      return;
    }
    if (password.isEmpty || password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters.');
      return;
    }

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name for the user
      await credential.user?.updateDisplayName(displayName);

      // Save user data to Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user?.uid)
          .set({
        'displayName': displayName,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to MainPage after successful sign up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }
      _showErrorDialog(errorMessage);
    }
  }

  // دالة لعرض AlertDialog مخصص
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colorclass.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    Transform.translate(
                      offset: const Offset(-15, 0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.keyboard_backspace,
                          color: Colorclass.dustyPink,
                          size: 40,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return Loginscreen();
                            },
                          ));
                        },
                      ),
                    ),
                    const SizedBox(width: 30),
                    const Center(
                      child: Text(
                        Textclass.CreateAccount,
                        style: TextStyles.Bold24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colorclass.grey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset('images/avatar1.png'),
                  ),
                ),
                const SizedBox(height: 50),
                CustomTextFormField(
                  controller: displayNameController,
                  hintText: Textclass.displayname,
                  fieldHeight: 70,
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit,
                      color: Colorclass.brown,
                    ),
                  ),
                  onChanged: (value) => displayName = value,
                ),
                CustomTextFormField(
                  controller: usernameController,
                  hintText: Textclass.Username,
                  fieldHeight: 70,
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person,
                      color: Colorclass.brown,
                    ),
                  ),
                  onChanged: (value) => username = value,
                ),
                CustomTextFormField(
                  controller: emailController,
                  hintText: Textclass.Email,
                  fieldHeight: 70,
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.email,
                      color: Colorclass.brown,
                    ),
                  ),
                  onChanged: (value) => email = value,
                ),
                CustomTextFormField(
                  controller: passwordController,
                  hintText: Textclass.Password,
                  fieldHeight: 70,
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colorclass.brown,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  onChanged: (value) => password = value,
                ),
                const SizedBox(height: 50),
                CustomButton(
                  title: Textclass.Getstarted,
                  onPressed: () {
                    signUp();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.onPressed,
  });

  final String title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const RadialGradient(
            colors: [Colorclass.dustyPink, Colorclass.brown],
            center: Alignment.centerRight,
            radius: 10,
            stops: [0.1, .7],
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colorclass.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final double fieldHeight;
  final bool isReset;
  final bool obscureText;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.fieldHeight = 70,
    this.isReset = false,
    this.obscureText = false,
    required this.controller,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: fieldHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: Colorclass.gradient,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colorclass.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                hintText: hintText,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}