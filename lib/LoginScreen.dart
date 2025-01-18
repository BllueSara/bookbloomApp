import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/SignUpScreen.dart';
import 'package:bookbloom/ShapesClasses/LoginShape.dart';
import 'package:bookbloom/mainpage.dart';
import 'package:bookbloom/resetpassword.dart';

class Loginscreen extends StatefulWidget {
  Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscureText = true; // To manage password visibility

  Future<void> _login(BuildContext context) async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        _showErrorDialog(context, 'Please enter both email and password.');
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _showErrorDialog(
            context, 'Your password or your email is not correct.');
      } else {
        _showErrorDialog(context, 'Login failed: ${e.message}');
      }
    } catch (e) {
      _showErrorDialog(context, 'An error occurred: ${e.toString()}');
    }
  }

  // دالة لعرض AlertDialog مخصص
  void _showErrorDialog(BuildContext context, String message) {
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
                color: Colorclass.brown, // النص باللون البني
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 40,
              width: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
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
                    color: Colorclass.white, // النص باللون الأبيض
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
        child: Column(
          children: [
            Transform.translate(
              offset: const Offset(25, 7),
              child: CustomPaint(
                size: const Size(307, 231),
                painter: RPSSCustomPainter(),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Textclass.Log_in,
                      style: TextStyles.Bold30,
                    ),
                    SizedBox(height: 5),
                    Text(
                      Textclass.Please,
                      style: TextStyles.normal18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      gradient: Colorclass.gradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colorclass.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: Textclass.Email,
                          hintStyle: TextStyles.normal16,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      gradient: Colorclass.gradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colorclass.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: Textclass.Password,
                          hintStyle: TextStyles.normal16,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colorclass.brown,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Resetpassword(),
                          ),
                        );
                      },
                      child: Text(
                        Textclass.ForgotPassword,
                        style: TextStyles.normal18.copyWith(
                          color: Colorclass.dustyPink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  // Login button
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: Colorclass.gradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: MaterialButton(
                        onPressed: () => _login(context),
                        child: Text(
                          Textclass.Login,
                          style: TextStyles.Bold24.copyWith(
                            color: Colorclass.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign-up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        Textclass.DontHave,
                        style: TextStyles.normal18,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: Text(
                          Textclass.CreateAccount,
                          style: TextStyles.normal18.copyWith(
                            color: Colorclass.dustyPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
