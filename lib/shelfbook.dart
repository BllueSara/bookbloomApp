import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookbloom/readbookScreen.dart';
import 'package:bookbloom/BaseClasses/ColorClass.dart';
import 'package:bookbloom/BaseClasses/TextStyleClass.dart';

class ShelfBook extends StatefulWidget {
  const ShelfBook({super.key});

  @override
  State<ShelfBook> createState() => _ShelfBookState();
}

class _ShelfBookState extends State<ShelfBook> {
  final List<String> shelves = [];

  @override
  void initState() {
    super.initState();
    _fetchShelves();
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

  void _deleteShelf(String shelfName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shelves')
          .doc(shelfName)
          .delete();

      setState(() {
        shelves.remove(shelfName);
      });
    }
  }

  void _editShelfName(String oldName, String newName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null && newName.isNotEmpty) {
      final shelfRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shelves')
          .doc(oldName);

      final shelfData = await shelfRef.get();
      if (shelfData.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('shelves')
            .doc(newName)
            .set(shelfData.data()!);

        await shelfRef.delete();

        setState(() {
          shelves.remove(oldName);
          shelves.add(newName);
        });
      }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(shelves[index]),
                      PopupMenuButton<String>(
                      
                        color: Colors
                            .white, // تعيين خلفية القائمة إلى اللون الأبيض
                        onSelected: (value) {
                          if (value == 'Edit') {
                            _showEditShelfDialog(context, shelves[index]);
                          } else if (value == 'Delete') {
                            _deleteShelf(shelves[index]);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'Edit',
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                  color: Colorclass.brown), // لون النص
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                  color: Colorclass.brown), // لون النص
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                                      image:
                                          NetworkImage(book['imageUrl'] ?? ''),
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
    TextEditingController shelfNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
void _addBookToShelf(String shelfName, Map<String, dynamic> book) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    final shelfRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shelves')
        .doc(shelfName);

    // تحديث الكتب في الشيلف
    await shelfRef.update({
      'books': FieldValue.arrayUnion([book]),
    }).catchError((error) async {
      // إذا لم يكن الشيلف موجودًا، يتم إنشاؤه
      await shelfRef.set({
        'shelfName': shelfName,
        'books': [book],
      });
    });

    setState(() {
      // تحديث الحالة محليًا
      final index = shelves.indexOf(shelfName);
      if (index != -1) {
        shelves[index] = shelfName; // تحديث قائمة الشيلف
      }
    });
  }
}

  void _showEditShelfDialog(BuildContext context, String oldName) {
    TextEditingController shelfNameController =
        TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colorclass.white,
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
                  hintText: "New shelf name",
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
                    _editShelfName(oldName, shelfNameController.text);
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
                      "Save",
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
