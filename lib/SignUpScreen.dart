import 'package:bookbloom/LoginScreen.dart';
import 'package:bookbloom/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final formKey = GlobalKey<FormState>();

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
                              return const Loginscreen();
                            },
                          ));
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Center(
                      child: Text(
                        Textclass.Createyaccount,
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
                const CustomTextFormField(
                    hintText: Textclass.displayname, fieldHeight: 70),
                const CustomTextFormField(
                    hintText: Textclass.Username, fieldHeight: 70),
                const CustomTextFormField(
                    hintText: Textclass.Email, fieldHeight: 70),
                const CustomTextFormField(
                    hintText: Textclass.Password, fieldHeight: 70),
                const SizedBox(height: 50),
                CustomButton(
                  title: Textclass.Getstarted,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(),
                      ),
                    );
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
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.fieldHeight = 70,
    this.isReset = false,
  });
  final String hintText;
  final double fieldHeight;
  final bool isReset;
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
            child: TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colorclass.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none),
                hintText: hintText,
                suffixIcon: isReset
                    ? null
                    : const Icon(
                        Icons.edit,
                        size: 30,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
