import 'package:flutter/material.dart';
import 'sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'main.dart'; // Import for isDarkMode ValueNotifier

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _avatarIndex = 0;
  String _username = 'My Account';
  final List<String> _avatars = [
    'assets/avatar1.webp',
    'assets/avatar2.webp',
    'assets/avatar3.webp',
  ];

  List<Map<String, dynamic>> _entries = [];
  final TextEditingController _feelingController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _refreshEntries();
    _loadAvatar();
    _loadUsername();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarIndex = prefs.getInt('avatar_index') ?? 0;
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'My Account';
    });
  }

  void _refreshEntries() async {
    final data = await SQLHelper.getEntries();
    setState(() => _entries = data);
    print(_entries);
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                child: Text(
                  _editingId == null ? "Add" : "Update",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  if (_feelingController.text.trim().isEmpty ||
                      _descController.text.trim().isEmpty) return;

                  if (_editingId == null) {
                    await SQLHelper.insertEntry(
                      _feelingController.text.trim(),
                      _descController.text.trim(),
                    );
                  } else {
                    await SQLHelper.updateEntry(
                      _editingId!,
                      _feelingController.text.trim(),
                      _descController.text.trim(),
                    );
                  }
                  _refreshEntries();
                  print('Add button pressed');
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

  void _deleteEntry(int id) async {
    await SQLHelper.deleteEntry(id);
    _refreshEntries();
  }

  @override
  Widget build(BuildContext context) {
    // Use the global theme notifier
    bool _isDarkMode = isDarkMode.value;

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0xFFFDF5FF),
    );
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF181A20),
    );

    return Theme(
      data: _isDarkMode ? darkTheme : lightTheme,
      child: Scaffold(
        backgroundColor: _isDarkMode ? Color(0xFF181A20) : Color(0xFFFDF5FF),
        appBar: AppBar(
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.lightBlue.shade50,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.webp',
                height: 36,
              ),
              SizedBox(width: 12),
              Text(
                'Your Secret Is My Secret Too',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Color.fromARGB(255, 47, 83, 179),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 16),
            // Profile photo and username
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountPage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(_avatars[_avatarIndex]),
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  _username,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            // Dark/Light mode switch below profile photo
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: _isDarkMode ? Colors.yellow : Colors.black,
                ),
                Switch(
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() {
                      isDarkMode.value = val;
                    });
                  },
                  activeColor: Colors.yellow,
                  inactiveThumbColor: Colors.grey,
                ),
                Text(
                  _isDarkMode ? "Dark Mode" : "Light Mode",
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _entries.isEmpty
                    ? Center(
                        child: Text(
                          'No diary yet. Try add your story.',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white70 : Color.fromARGB(255, 47, 83, 179),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isDarkMode ? Colors.grey[850] : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                entry['feeling'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      entry['createdAt'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => _showEntryModal(entry: entry),
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: _isDarkMode ? Colors.lightBlueAccent : Color.fromARGB(255, 47, 83, 179),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _deleteEntry(entry['id']),
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 47, 83, 179).withOpacity(0.9),
          onPressed: () => _showEntryModal(),
          child: Text(
            "+",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}