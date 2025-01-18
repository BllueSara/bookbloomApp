import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Readingprofile extends StatefulWidget {
  const Readingprofile({super.key});

  @override
  State<Readingprofile> createState() => _ReadingprofileState();
}

class _ReadingprofileState extends State<Readingprofile> {
  final List<String> Author_Books = [
    'images/book1.png',
    'images/book2.png',
  ];
  final List<String> Author_Lists = [
    'images/book1.png',
    'images/book2.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            Textclass.Willo34,
            style: TextStyles.Bold24,
            textAlign: TextAlign.center,
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          forceMaterialTransparency: true,
          centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('images/avatar2.png'),
              radius: 50,
            ),
            const SizedBox(height: 20),
            const Text(
              Textclass.William,
              style: TextStyles.Bold18,
            ),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  Textclass.Book,
                  style: TextStyles.normal16,
                ),
                Text(
                  Textclass.Readers,
                  style: TextStyles.normal16,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Transform.translate(
              offset: const Offset(-120, 0),
              child: const Text(
                Textclass.AuthorBooks,
                style: TextStyles.Bold18,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Author_Books.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colorclass.grey,
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(Author_Books[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Transform.translate(
              offset: const Offset(-120, 0),
              child: const Text(
                Textclass.AuthorList,
                style: TextStyles.Bold18,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Author_Lists.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colorclass.grey,
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(Author_Lists[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
