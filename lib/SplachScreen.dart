// import 'package:bookbloom/ShapesClasses/SplachShape.dart';
// import 'package:flutter/material.dart';
//
//
// class Splachscreen extends StatelessWidget {
//   const Splachscreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             Transform.translate(
//               offset: const Offset(-30, 50), //المسافات
//               child: CustomPaint(
//                 // رسمة splash
//
//                 size: const Size(354, 401),
//                 painter: RPSCustomPainter(),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//             );
//   }
// }
//
//

import 'package:flutter/material.dart';
import 'package:bookbloom/ShapesClasses/SplachShape.dart';
import 'package:bookbloom/LoginScreen.dart';

class Splachscreen extends StatelessWidget {
  const Splachscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(-40, -120),
              child: CustomPaint(
                size: const Size(400, 80),
                painter: RPSCustomPainter(),
              ),
            ),

            const SizedBox(height: 10),

            Image.asset(
              'assets/images/bookbloom.png',
              width: 250,
              height: 200,
            ),
      Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
           child:  RichText(

              text: TextSpan(

                text: 'Welcome to ',
                style: const TextStyle(

                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'BookBloom',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffD4ACA5),
                    ),
                  ),
                  const TextSpan(
                    text: ' where Stories Flourish!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
      ),
            const SizedBox(height: 30),
      Padding(
        padding: const EdgeInsets.only(left: 22.0, right: 22),
            child:  Text(
              'Explor a World of Free Reading and Writing Where Every Story is Just a Page Away',
              style: TextStyle(

                fontSize: 16,
              ),
            ),
      ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Loginscreen()),
                );
              },
              child: const Text("Let's Go",
                  style: TextStyle(  fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,),
              ),
              style: ElevatedButton.styleFrom(

                fixedSize: Size(200, 50),
                backgroundColor:Color(0xffD4ACA5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


