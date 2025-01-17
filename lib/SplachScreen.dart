import 'package:bookbloom/ShapesClasses/SplachShape.dart';
import 'package:flutter/material.dart';


class Splachscreen extends StatelessWidget {
  const Splachscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Transform.translate(
              offset: const Offset(-30, 50), //المسافات
              child: CustomPaint(
                // رسمة splash

                size: const Size(354, 401),
                painter: RPSCustomPainter(),
              ),
            ),
          ],
        ),
      ),
      
      
    );
  }
}
