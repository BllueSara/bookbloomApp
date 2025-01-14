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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      appBar: AppBar(
        leading: BackButton(
          color: Colorclass.dustyPink,
          style: ButtonStyle(
            iconSize: WidgetStateProperty.all(30),
          ),
        ),
        title: const Text(
          Textclass.Createyaccount,
          style: TextStyles.Bold24,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colorclass.grey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset('assets/female2.jpg'),
                ),
              ),
              const SizedBox(height: 50),
              const CustomTextFormField(hintText: Textclass.displayname),
              const CustomTextFormField(hintText: Textclass.Username),
              const CustomTextFormField(hintText: Textclass.Email),
              const CustomTextFormField(hintText: Textclass.Password),
              const SizedBox(height: 50),
              const CustomButton(
                title: Textclass.Getstarted,
              ),
            ],
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
    this.isReset = false,
  });
  final String hintText;
  final bool isReset;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 70,
            width: 450,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: Colorclass.gradient,
            ),
          ),
          SizedBox(
            height: 57,
            width: 390,
            child: TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colorclass.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                // labelText: TextClass.Username,
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
