import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'main.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:io'; // For file handling
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:firebase_storage/firebase_storage.dart'; // For image uploading

// Save selected images and existing image
List<XFile> _selectedImages = [];
List<String> _existingImageUrls = [];

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Key for the ScaffoldMessenger to show SnackBars
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // Current user data variables
  String _avatarUrl = '';
  String _username = 'My Account';
  String _userId = '';

  // Controllers for form inputs
  final TextEditingController _feelingController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  // ID of the entry being edited, null if creating a new entry
  String? _editingId;

  Set<int> _expandedIndexes = {}; // Set to track expanded entries
  int _selectedIndex = 0; // Index for bottom navigation

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  // Get user data from SharedPreferences and Firebase
  Future<void> _initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _avatarUrl = prefs.getString('avatar_url') ?? '';
      _username = prefs.getString('username') ?? 'My Account';
      _userId = user?.uid ?? '';
    });
  }

  // Show modal bottom sheet for adding or editing diary entries
  void _showEntryModal({Map<String, dynamic>? entry}) {
    if (entry != null) {
      _editingId = entry['id'];
      _feelingController.text = entry['feeling'];
      _descController.text = entry['description'];
      _existingImageUrls = List<String>.from(entry['images'] ?? []);
      _selectedImages.clear();
    } else {
      _editingId = null;
      _feelingController.clear();
      _descController.clear();
    }

    final bool _isDarkMode = isDarkMode.value;

    // Show the modal bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? const Color(0xFF23272F) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editingId == null ? "New Diary" : "Edit Diary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              // Feeling field for diary entry
              TextField(
                controller: _feelingController,
                decoration: InputDecoration(
                  labelText: 'How are you feeling today?',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Description field for diary entry
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'What happened today?',
                  labelStyle: TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
              // Image selection for diary entry
              ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickMultiImage();
                  if (picked != null) {
                    setState(() {
                      _selectedImages = picked;
                    });
                  }
                },
                icon: Icon(Icons.image),
                label: Text("Select Images"),
              ),
              // Display selected images
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedImages.map((img) {
                    return Image.file(
                      File(img.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
              SizedBox(height: 12),
              // Save Button
              ElevatedButton(
                child: Text(
                  _editingId == null ? "Add" : "Update",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (_feelingController.text.trim().isEmpty ||
                      _descController.text.trim().isEmpty) return;

                  List<String> imageUrls = [];
                  // Upload images to Firebase Storage
                  for (var image in _selectedImages) {
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('entries')
                        .child('${DateTime.now().millisecondsSinceEpoch}_${image.name}');
                    await ref.putFile(File(image.path));
                    final url = await ref.getDownloadURL();
                    imageUrls.add(url);
                  }

                  final data = {
                    'userId': _userId,
                    'feeling': _feelingController.text.trim(),
                    'description': _descController.text.trim(),
                    'createdAt': DateTime.now(),
                    'images': imageUrls,
                  };

                  if (_editingId == null) {
                    await FirebaseFirestore.instance.collection('entries').add(data);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('entries')
                        .doc(_editingId)
                        .update(data);
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 47, 83, 179),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete diary entry
  Future<void> _deleteEntry(String id) async {
    await FirebaseFirestore.instance.collection('entries').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    bool _isDarkMode = isDarkMode.value;

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
    );
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
    );

    return Theme(
      data: _isDarkMode ? darkTheme : lightTheme,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: _isDarkMode
                ? Colors.grey[900]?.withOpacity(0.8)
                : Colors.lightBlue.shade100.withOpacity(0.8),
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.webp', height: 36),
                SizedBox(width: 15),
                Text(
                  'My Diary',
                  style: TextStyle(
                    color: _isDarkMode
                        ? Colors.white
                        : Color.fromARGB(255, 47, 83, 179),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              if (_isDarkMode)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              Column(
                children: [
                  SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AccountPage()),
                                );
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                    ? (_avatarUrl!.startsWith('http')
                                        ? NetworkImage(_avatarUrl!)
                                        : FileImage(File(_avatarUrl!)) as ImageProvider)
                                    : AssetImage('assets/avatar1.webp'),
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              _username,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dark mode toggle button
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: IconButton(
                          icon: Icon(
                            _isDarkMode
                                ? Icons.nightlight_round
                                : Icons.wb_sunny,
                            color:
                                _isDarkMode ? Colors.yellow : Colors.orange,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              isDarkMode.value = !isDarkMode.value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Diary entries list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _userId.isEmpty
                          ? SizedBox.shrink()
                          : StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('entries')
                                  .where('userId', isEqualTo: _userId)
                                  .orderBy('createdAt', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final docs = snapshot.data?.docs ?? [];
                                if (docs.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No diary yet. Try add your story.',
                                      style: TextStyle(
                                        color: _isDarkMode ? Colors.white70 : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }
                                return RefreshIndicator(
                                  onRefresh: () async {
                                    setState(() {});
                                  },
                                  child: ListView.builder(
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      // Format the createdAt date
                                      final data = docs[index].data() as Map<String, dynamic>;
                                      final createdAt = data['createdAt'];
                                      String formattedDate = '';
                                      if (createdAt is Timestamp) {
                                        formattedDate = DateFormat('d MMMM yyyy, h:mm a').format(createdAt.toDate());
                                      } else if (createdAt is DateTime) {
                                        formattedDate = DateFormat('d MMMM yyyy, h:mm a').format(createdAt);
                                      } else if (createdAt is String) {
                                        formattedDate = createdAt;
                                      }
                                      final parts = formattedDate.split(',');
                                      final date = parts.isNotEmpty ? parts[0] : '';
                                      final time = parts.length > 1 ? parts[1].trim() : '';
                                      final entry = {
                                        'id': docs[index].id,
                                        'feeling': data['feeling'],
                                        'description': data['description'],
                                        'createdAt': formattedDate,
                                        'userId': data['userId'],
                                      };
                                      final isExpanded = _expandedIndexes.contains(index);

                                      // Display the diary entry
                                      return Dismissible(
                                        key: Key(entry['id'].toString()),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(horizontal: 24),
                                          color: Colors.redAccent,
                                          child: Icon(Icons.delete, color: Colors.white, size: 32),
                                        ),
                                        onDismissed: (direction) async {
                                          final deletedEntry = Map<String, dynamic>.from(entry);
                                          final entryId = deletedEntry['id'];

                                          await FirebaseFirestore.instance
                                              .collection('entries')
                                              .doc(entryId)
                                              .delete();

                                          _scaffoldMessengerKey.currentState?.showSnackBar(
                                            SnackBar(
                                              content: Text('Diary deleted'),
                                              action: SnackBarAction(
                                                label: 'UNDO',
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance
                                                      .collection('entries')
                                                      .doc(entryId)
                                                      .set({
                                                    'userId': deletedEntry['userId'],
                                                    'feeling': deletedEntry['feeling'],
                                                    'description': deletedEntry['description'],
                                                    'createdAt': DateTime.now(),
                                                  });
                                                },
                                              ),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                        },
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isExpanded) {
                                                _expandedIndexes.remove(index);
                                              } else {
                                                _expandedIndexes.add(index);
                                              }
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              color: _isDarkMode
                                                  ? Colors.grey[850]
                                                  : Colors.white.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: SizedBox(
                                              height: isExpanded ? null : 130,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.all(16),
                                                title: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          date,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          time,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                entry['feeling'],
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: _isDarkMode
                                                                      ? Colors.white
                                                                      : Colors.black,
                                                                ),
                                                                maxLines: isExpanded ? null : 1,
                                                                overflow: isExpanded
                                                                    ? TextOverflow.visible
                                                                    : TextOverflow.ellipsis,
                                                              ),
                                                              SizedBox(height: 9),
                                                              Text(
                                                                entry['description'],
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: _isDarkMode
                                                                      ? Colors.white70
                                                                      : Colors.black87,
                                                                ),
                                                                maxLines: isExpanded ? null : 1,
                                                                overflow: isExpanded
                                                                    ? TextOverflow.visible
                                                                    : TextOverflow.ellipsis,
                                                              ),
                                                              // Display images if entry is expanded
                                                              if (isExpanded && data['images'] != null)
                                                              SizedBox(height: 10),
                                                              if (isExpanded && data['images'] != null)
                                                              Wrap(
                                                                spacing: 8,
                                                                runSpacing: 8,
                                                                children: List<Widget>.from((data['images'] as List).map((url) {
                                                                  return ClipRRect(
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    child: Image.network(
                                                                      url,
                                                                      width: 100,
                                                                      height: 100,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  );
                                                                })),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 0),
                                                          child: IconButton(
                                                            icon: Icon(
                                                              Icons.edit,
                                                              color: _isDarkMode
                                                                  ? Colors.lightBlueAccent
                                                                  : Color.fromARGB(255, 47, 83, 179),
                                                            ),
                                                            onPressed: () => _showEntryModal(entry: entry),
                                                            tooltip: "Edit",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  )
                ],
              ),
            ],
          ),
          // Floating action button to add new diary entry
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 47, 83, 179).withOpacity(0.9),
            onPressed: () => _showEntryModal(),
            child: Icon(Icons.add, color: Colors.white, size: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          // Bottom navigation bar with two items
          bottomNavigationBar: BottomAppBar(
            color: _isDarkMode ? Colors.grey[900] : Colors.white,
            shape: CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: IconButton(
                      icon: Icon(
                        Icons.list_alt,
                        color: _selectedIndex == 0
                            ? (_isDarkMode
                                ? Colors.white
                                : Color.fromARGB(255, 47, 83, 179))
                            : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      tooltip: "View All",
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: _selectedIndex == 1
                            ? (_isDarkMode
                                ? Colors.white
                                : Color.fromARGB(255, 47, 83, 179))
                            : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AccountPage()),
                        );
                      },
                      tooltip: "Settings",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}