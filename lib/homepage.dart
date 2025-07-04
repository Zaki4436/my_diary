import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'main.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int _avatarIndex = 0;
  String _username = 'My Account';
  String _userId = '';
  final List<String> _avatars = [
    'assets/avatar1.webp',
    'assets/avatar2.webp',
    'assets/avatar3.webp',
  ];

  final TextEditingController _feelingController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _editingId;

  Set<int> _expandedIndexes = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _avatarIndex = prefs.getInt('avatar_index') ?? 0;
      _username = prefs.getString('username') ?? 'My Account';
      _userId = user?.uid ?? '';
    });
  }

  void _showEntryModal({Map<String, dynamic>? entry}) {
    if (entry != null) {
      _editingId = entry['id'];
      _feelingController.text = entry['feeling'];
      _descController.text = entry['description'];
    } else {
      _editingId = null;
      _feelingController.clear();
      _descController.clear();
    }

    final bool _isDarkMode = isDarkMode.value;

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
              SizedBox(height: 12),
              ElevatedButton(
                child: Text(
                  _editingId == null ? "Add" : "Update",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (_feelingController.text.trim().isEmpty ||
                      _descController.text.trim().isEmpty) return;

                  final data = {
                    'userId': _userId,
                    'feeling': _feelingController.text.trim(),
                    'description': _descController.text.trim(),
                    'createdAt': DateTime.now(),
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
                  'MCR Diary',
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
                                backgroundImage: AssetImage(_avatars[_avatarIndex]),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor:
                Color.fromARGB(255, 47, 83, 179).withOpacity(0.9),
            onPressed: () => _showEntryModal(),
            child: Icon(Icons.add, color: Colors.white, size: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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