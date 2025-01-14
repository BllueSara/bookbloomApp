import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                'assets/header.png',
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      Textclass.ForgetPass,
                      style: TextStyles.Bold30,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      Textclass.reset,
                    ),
                    const SizedBox(height: 20),
                    const CustomTextFormField(
                      isReset: true,
                      hintText: Textclass.Email,
                    ),
                    const SizedBox(height: 120),
                    CustomButton(
                      title: Textclass.Continue,
                      onPressed: () {
                        showOverLay = true;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showOverLay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 400,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colorclass.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 80),
                            const Text(
                              Textclass.Checkyouremail,
                              style: TextStyles.Bold30,
                            ),
                            const SizedBox(height: 15),
                            const SizedBox(
                              width: 250,
                              child: Text(
                                textAlign: TextAlign.center,
                                Textclass.WeHaveSent,
                                style: TextStyles.hint14,
                              ),
                            ),
                            const SizedBox(height: 40),
                            InkWell(
                              onTap: () {
                                showOverLay = false;
                                setState(() {});
                              },
                              child: Container(
                                height: 40,
                                width: 230,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: const RadialGradient(
                                    colors: [
                                      Colorclass.dustyPink,
                                      Colorclass.brown
                                    ],
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 350,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colorclass.dustyPink,
                        ),
                        child: Image.asset('assets/chat.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
