import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/ShapesClasses/LoginShape.dart';
import 'package:flutter/material.dart';
import 'SignUpScreen.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  State<Resetpassword> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  late bool showOverLay;

  @override
  void initState() {
    super.initState();
    showOverLay = false;
  }

  void _showOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colorclass.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colorclass.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: const Text(
                Textclass.Checkyouremail,
                style: TextStyles.Bold30,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: const SizedBox(
                width: 250,
                child: Text(
                  textAlign: TextAlign.center,
                  Textclass.WeHaveSent,
                  style: TextStyles.hint14,
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context); // إغلاق الـ BottomSheet عند الضغط
              },
              child: Container(
                height: 40,
                width: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: const RadialGradient(
                    colors: [Colorclass.dustyPink, Colorclass.brown],
                    center: Alignment.centerRight,
                    radius: 10,
                    stops: [0.1, .7],
                  ),
                ),
                child: const Center(
                  child: Text(
                    Textclass.Done,
                    style: TextStyle(
                      color: Colorclass.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -270),
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colorclass.dustyPink,
                ),
                child: Image.asset('images/chat1.png'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(70, 7),
                  child: CustomPaint(
                    size: const Size(307, 231),
                    painter: RPSSCustomPainter(),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        Textclass.ForgetPass,
                        style: TextStyles.Bold30,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        Textclass.reset,
                        style: TextStyles.normal16,
                      ),
                      const SizedBox(height: 40),
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
                      const SizedBox(height: 170),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 60,
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
                          child: MaterialButton(
                            onPressed: () {
                              _showOverlay(
                                  context); // عرض BottomSheet عند الضغط
                            },
                            child: const Text(
                              Textclass.Continue,
                              style: TextStyle(
                                color: Colorclass.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
 } 
