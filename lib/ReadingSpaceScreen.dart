import 'package:bookbloom/WriteStoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';
import 'package:bookbloom/Readingprofile.dart';

class Readingspacescreen extends StatefulWidget {
  final String storyId;
  final String partTitle;

  const Readingspacescreen({
    super.key,
    required this.storyId,
    required this.partTitle,
  });

  @override
  State<Readingspacescreen> createState() => _ReadingspacescreenState();
}

class _ReadingspacescreenState extends State<Readingspacescreen> {
  double fontSize = 16.0; // Default font size
  String title = "Loading...";
  String content = "Loading...";
  String authorName = "Unknown Author";

  @override
  void initState() {
    super.initState();
    _fetchPartData();
  }

  Future<void> _fetchPartData() async {
    try {
      DocumentSnapshot storyDoc = await FirebaseFirestore.instance
          .collection('stories')
          .doc(widget.storyId)
          .get();

      if (storyDoc.exists) {
        QuerySnapshot partSnapshot = await FirebaseFirestore.instance
            .collection('stories')
            .doc(widget.storyId)
            .collection('parts')
            .where('partTitle', isEqualTo: widget.partTitle)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (partSnapshot.docs.isNotEmpty) {
          setState(() {
            title = storyDoc['title'] ?? "No Title";
            authorName = storyDoc['author'] ?? "Unknown Author";
            content =
                partSnapshot.docs.first['content'] ?? "No Content Available";
          });
        }
      }
    } catch (e) {
      print("Error fetching part data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      appBar: AppBar(
        backgroundColor: Colorclass.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace,
              color: Colorclass.dustyPink, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                authorName,
                style: TextStyles.hint14.copyWith(color: Colorclass.grey),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              widget.partTitle,
              style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: TextStyle(fontSize: fontSize, color: Colorclass.brown),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colorclass.brown, size: 30),
                      onPressed: () {
                        // Handle like action
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Colorclass.brown, size: 30),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WriteStoryScreen(
                                storyId: widget.storyId), // شاشة الكتابة
                          ),
                        );

                        // تحديث النص في شاشة القراءة
                        if (result != null) {
                          setState(() {
                            content = result; // النص الجديد
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildFontSizeSlider(),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Stack(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
            border: Border(
              top: BorderSide(color: Colorclass.grey, width: 3),
              left: BorderSide(color: Colorclass.grey, width: 3),
              right: BorderSide(color: Colorclass.grey, width: 3),
            ),
            color: Colorclass.white,
          ),
        ),
        Positioned(
          top: 5,
          left: 28.0,
          child: Text(
            "Font Size",
            style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
          ),
        ),
        Positioned(
          top: 20,
          left: 16,
          right: 16,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
              thumbColor: Colorclass.white,
              activeTrackColor: Colorclass.brown,
              inactiveTrackColor: Colorclass.grey,
              overlayColor: Colorclass.brown.withOpacity(0.2),
            ),
            child: Slider(
              value: fontSize,
              min: 12,
              max: 24,
              divisions: 6,
              label: fontSize.toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  fontSize = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
