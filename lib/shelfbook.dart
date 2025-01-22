import 'package:bookbloom/readbookScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

class ShelfBook extends StatefulWidget {
  const ShelfBook({super.key});

  @override
  State<ShelfBook> createState() => _ShelfBookState();
}

class _ShelfBookState extends State<ShelfBook> {
  final List<String> shelves = [];
  String displayName = '';
  String username = '';
  
  @override
  void initState() {
    super.initState();
    _fetchShelves();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        displayName = userData['displayName'];
        username = userData['username'];
      });
    }
  }

  void _fetchShelves() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shelves')
          .get();

      setState(() {
        shelves.clear();
        for (var doc in snapshot.docs) {
          shelves.add(doc.id);
        }
      });
    }
  }

  void _addNewShelf(String shelfName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shelves')
          .doc(shelfName)
          .set({
        'shelfName': shelfName,
        'books': [],
      });

      setState(() {
        shelves.add(shelfName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorclass.white,
      appBar: AppBar(
        backgroundColor: Colorclass.white,
        elevation: 0,
        title: Text(
          "My Book Shelf",
          style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colorclass.dustyPink,
              size: 40,
            ),
            onPressed: () {
              _showAddShelfDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: shelves.length,
        itemBuilder: (context, index) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('shelves')
                .doc(shelves[index])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox();
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final books = data['books'] as List<dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(shelves[index]),
                  const SizedBox(height: 20),
                  books.isEmpty
                      ? _buildEmptyBookPlaceholder()
                      : SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: books.length,
                            itemBuilder: (context, bookIndex) {
                              final book = books[bookIndex];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ReadBookScreen(
                                        title: book['title'] ?? '',
                                        overview: book['overview'] ?? '',
                                        bio: book['bio'] ?? '',
                                        author: book['author'] ?? '',
                                        imageUrl: book['imageUrl'] ?? '',
                                      );
                                    },
                                  ));
                                },
                                child: Container(
                                  width: 100,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(book['imageUrl'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyles.Bold16.copyWith(color: Colorclass.brown),
    );
  }

  Widget _buildEmptyBookPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colorclass.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "No books added",
          style: TextStyles.normal16.copyWith(color: Colorclass.shelf),
        ),
      ),
    );
  }

  void _showAddShelfDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController shelfNameController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close, color: Colorclass.shelf),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: shelfNameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Shelf name",
                  hintStyle:
                      TextStyles.normal18.copyWith(color: Colorclass.shelf),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colorclass.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colorclass.brown),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (shelfNameController.text.isNotEmpty) {
                    _addNewShelf(shelfNameController.text);
                  }
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: Colorclass.gradient,
                  ),
                  child: Center(
                    child: Text(
                      "Create Shelf",
                      style:
                          TextStyles.Bold16.copyWith(color: Colorclass.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
