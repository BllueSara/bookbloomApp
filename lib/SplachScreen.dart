import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/LoginScreen.dart';
import 'package:bookbloom/ShapesClasses/SplachShape.dart';
import 'package:flutter/material.dart';

class Splachscreen extends StatelessWidget {
  const Splachscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(-30, 40), //المسافات
                child: CustomPaint(
                  // رسمة splash
                  size: const Size(354, 401),
                  painter: RPSCustomPainter(),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -230), //المسافات
                child: Image.asset(
                  'images/bookbloom.png',
                  width: 350,
                  height: 300,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -300), //المسافات
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: Textclass.Welcome,
                    style: TextStyles.Bold30.copyWith(
                      color: Colorclass.brown,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: Textclass.BookBloom,
                        style: TextStyles.Bold30.copyWith(
                          color: Colorclass.dustyPink,
                        ),
                      ),
                      TextSpan(
                        text: Textclass.Flourish,
                        style: TextStyles.Bold30.copyWith(
                          color: Colorclass.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-10, -280), //المسافات
                child: Text(
                  Textclass.Explore,
                  textAlign: TextAlign.left,
                  style: TextStyles.hint14.copyWith(
                    color: Colorclass.gbrown,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -200), //المسافات
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Loginscreen()),
                    );
                  },
                  child: Container(
                    width: 250,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: Colorclass.gradient,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      Textclass.LetsGo,
                      style: TextStyles.Bold18.copyWith(
                        color: Colorclass.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}