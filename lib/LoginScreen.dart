// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/SignUpScreen.dart';
import 'package:bookbloom/ShapesClasses/LoginShape.dart'; // كلاس الرسمة
import 'package:bookbloom/mainpage.dart';
import 'package:bookbloom/resetpassword.dart';
import 'package:flutter/material.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // الرسمة في الأعلى
            Transform.translate(
              offset: const Offset(30, 7), // المسافات للرسمة
              child: CustomPaint(
                size: const Size(307, 231),
                painter: RPSSCustomPainter(),
              ),
            ),
            const SizedBox(height: 20),
            // العنوان والنصوص على اليسار
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft, // محاذاة النصوص إلى اليسار
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Textclass.Log_in,  // استدعاء النص من كلاس Textclass
                      style: TextStyles.Bold30,  // استدعاء التنسيق من كلاس TextStyles
                    ),
                    const SizedBox(height: 5),
                    Text(
                      Textclass.Please,  // استدعاء النص من كلاس Textclass
                      style: TextStyles.normal18,  // استدعاء التنسيق من كلاس TextStyles
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
                  // حقل إدخال البريد الإلكتروني
                  Container(
                    decoration: BoxDecoration(
                      gradient: Colorclass.gradient,  // استدعاء التدرج من كلاس Colorclass
                      borderRadius: BorderRadius.circular(30), // زوايا الحواف
                    ),
                    padding: const EdgeInsets.all(5), // سمك الحواف
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colorclass.white,  // استدعاء اللون من كلاس Colorclass
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: Textclass.Email,  // استدعاء النص من كلاس Textclass
                          hintStyle: TextStyles.normal16,  // استدعاء التنسيق من كلاس TextStyles
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none, // بدون حدود إضافية
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20), // مسافة داخلية
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // حقل إدخال كلمة المرور
                  Container(
                    decoration: BoxDecoration(
                      gradient: Colorclass.gradient,  // استدعاء التدرج من كلاس Colorclass
                      borderRadius: BorderRadius.circular(30), // زوايا الحواف
                    ),
                    padding: const EdgeInsets.all(5), // سمك الحواف
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colorclass.white,  // استدعاء اللون من كلاس Colorclass
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: Textclass.Password,  // استدعاء النص من كلاس Textclass
                          hintStyle: TextStyles.normal16,  // استدعاء التنسيق من كلاس TextStyles
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none, // بدون حدود إضافية
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20), // مسافة داخلية
                          suffixIcon: Icon(
                            Icons.visibility,
                            color: Colorclass.brown,  // استدعاء اللون من كلاس Colorclass
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Text(
                  //     Textclass.ForgotPassword,  // استدعاء النص من كلاس Textclass
                  //     style: TextStyles.normal18.copyWith(
                  //       color: Colorclass.dustyPink,  // استدعاء اللون من كلاس Colorclass
                  //     ),
                  //   ),
                  // ),

                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Resetpassword()),
                      );
                    },
                    child: Text(
                      Textclass.ForgotPassword,
                      style: TextStyles.normal18.copyWith(


                        color: Colorclass.dustyPink,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  // زر تسجيل الدخول
                  Align(
                    alignment: Alignment.center, // محاذاة الزر لليمين
                    child: Container(
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: Colorclass.gradient,  // استدعاء التدرج من كلاس Colorclass
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(),
                            ),
                          );
                        },
                        child: Text(
                          Textclass.Login,  // استدعاء النص من كلاس Textclass
                          style: TextStyles.Bold18.copyWith(
                            color: Colorclass.white,  // استدعاء اللون من كلاس Colorclass
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  // رابط إنشاء حساب جديد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Textclass.DontHave,  // استدعاء النص من كلاس Textclass
                        style: TextStyles.normal18,  // استدعاء التنسيق من كلاس TextStyles
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>Signupscreen()),
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
