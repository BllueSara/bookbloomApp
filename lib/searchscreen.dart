import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/colorclass.dart';
import 'package:bookbloom/BaseClasses/textclass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedFilter = Textclass.Both;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colorclass.white,
      //   elevation: 0,
      //   toolbarHeight: 80,
      //   title:
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Container(
              constraints: const BoxConstraints(
                minHeight: 30,
                maxHeight: 50,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: Textclass.author,
                  hintStyle:
                      TextStyles.normal16.copyWith(color: Colorclass.brown),
                  prefixIcon: const Icon(Icons.search, color: Colorclass.brown),
                  suffixIcon: const Icon(Icons.close, color: Colorclass.brown),
                  filled: true,
                  fillColor: Colorclass.grey,
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colorclass.brown),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colorclass.brown, width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colorclass.grey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _filterButton(Textclass.Both),
                  _filterButton(Textclass.Author),
                  _filterButton(Textclass.Title1),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _bookItem("images/book1.png", Textclass.Book, Textclass.Author),
                  const Divider(color: Colorclass.grey),
                  _bookItem("images/book2.png", Textclass.Book, Textclass.Author),
                  const Divider(color: Colorclass.grey),
                  _bookItem("images/book3.png", Textclass.Book, Textclass.Author),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String text) {
    bool isActive = selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? Colorclass.white : Colorclass.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyles.normal16.copyWith(
            color: isActive ? Colorclass.brown : Colorclass.lightgray,
          ),
        ),
      ),
    );
  }

  Widget _bookItem(String imagePath, String title, String author) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              author,
              style: TextStyles.normal16.copyWith(color: Colorclass.lightgray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
