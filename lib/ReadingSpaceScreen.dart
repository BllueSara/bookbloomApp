import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

class Readingspacescreen extends StatefulWidget {
  final String storyId;

  const Readingspacescreen({
    super.key,
    required this.storyId,
  });

  @override
  State<Readingspacescreen> createState() => _ReadingspacescreenState();
}

class _ReadingspacescreenState extends State<Readingspacescreen> {
  double fontSize = 16.0; // Default font size
  String title = "Loading...";
  String authorName = "Unknown Author";
  List<Map<String, dynamic>> partsList = [];

  @override
  void initState() {
    super.initState();
    _fetchPartsData();
  }

  Future<void> _fetchPartsData() async {
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
            .orderBy('createdAt') // ترتيب تصاعدي
            .get();

        if (partSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> tempPartsList = [];
          for (var partDoc in partSnapshot.docs) {
            tempPartsList.add({
              'partTitle': partDoc['partTitle'],
              'content': partDoc['content'],
            });
          }

          setState(() {
            title = storyDoc['title'] ?? "No Title";
            authorName = storyDoc['author'] ?? "Unknown Author";
            partsList = tempPartsList;
          });
        }
      }
    } catch (e) {
      print("Error fetching parts data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        backgroundColor: Colorclass.white,
        
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
      body: partsList.isEmpty
          ? Center(
              child: Text(
                "No Content Available",
                style: TextStyle(fontSize: fontSize, color: Colorclass.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: partsList.length,
                itemBuilder: (context, index) {
                  final part = partsList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ch.${index + 1}", // Display "Chapter" with the number
                            style: TextStyles.Bold20.copyWith(
                              color: Colorclass.brown,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite_border,
                                  color: Colorclass.brown,
                                  size: 30,
                                ),
                                onPressed: () {
                                  // Handle like action
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colorclass.brown,
                                  size: 30,
                                ),
                                onPressed: () {
                                  // Handle comment action
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        part['partTitle'] ?? "No Part Title",
                        style: TextStyles.normal16.copyWith(
                          color: Colorclass.brown,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        part['content'] ?? "No Content",
                        style: TextStyle(fontSize: fontSize, color: Colorclass.brown),
                      ),
                      const Divider(color: Colorclass.grey, thickness: 1),
                    ],
                  );
                },
              ),
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _buildFontSizeSlider(),
        ],
      ),
    );
  }

Widget _buildFontSizeSlider() {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // حواف إضافية للداخل
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            border: Border(
              top: BorderSide(color: Colorclass.grey, width: 3),
              left: BorderSide(color: Colorclass.grey, width: 3),
              right: BorderSide(color: Colorclass.grey, width: 3),
            ),
            color: Colorclass.white,
          ),
        ),
      ),
      Positioned(
        top: 20.0, // تعديل الموضع لتصبح الكلمة في الأسفل قليلاً
        left: 50.0,
        child: Text(
          "Font Size",
          style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
        ),
      ),
      Positioned(
        top: 40, // تعديل الموضع ليكون داخل المربع
        left: 40, // حواف إضافية للداخل
        right: 40, // حواف إضافية للداخل
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