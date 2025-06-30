import 'package:flutter/material.dart';
import 'sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account.dart';
import 'main.dart';

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
    setState(() => _entries = List<Map<String, dynamic>>.from(data));
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
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

  Future<void> _deleteEntry(int id) async {
    await SQLHelper.deleteEntry(id);
    _refreshEntries();
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
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: _isDarkMode ? Colors.grey[900]?.withOpacity(0.8) : Colors.lightBlue.shade100.withOpacity(0.8),
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.webp', height: 36),
              SizedBox(width: 12),
              Text(
                'MCR Diary',
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
                                MaterialPageRoute(builder: (context) => AccountPage()),
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
                              color: _isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: IconButton(
                        icon: Icon(
                          _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                          color: _isDarkMode ? Colors.yellow : Colors.orange,
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
                    child: _entries.isEmpty
                        ? Center(
                            child: Text(
                              'No diary yet. Try add your story.',
                              style: TextStyle(
                                color: _isDarkMode ? Colors.white70 : Colors.black,
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
                                  color: _isDarkMode ? Colors.grey[850] : Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 6),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          final createdAt = entry['createdAt'] ?? '';
                                          final parts = createdAt.split(',');
                                          final date = parts.isNotEmpty ? parts[0] : '';
                                          final time = parts.length > 1 ? parts[1].trim() : '';
                                          return Row(
                                            children: [
                                              Text(
                                                date,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 26),
                                              Text(
                                                time,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        entry['feeling'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ],
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
                                      ],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: _isDarkMode ? Colors.lightBlueAccent : Color.fromARGB(255, 47, 83, 179)),
                                        onPressed: () => _showEntryModal(entry: entry),
                                        tooltip: "Edit",
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.redAccent),
                                        onPressed: () async {
                                          // Store deleted entry and index
                                          final deletedEntry = Map<String, dynamic>.from(entry);
                                          final deletedIndex = index;

                                          await SQLHelper.deleteEntry(entry['id']);
                                          _refreshEntries();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Diary deleted'),
                                              action: SnackBarAction(
                                                label: 'UNDO',
                                                onPressed: () async {
                                                  await SQLHelper.insertEntry(
                                                    deletedEntry['feeling'],
                                                    deletedEntry['description'],
                                                  );
                                                  _refreshEntries();
                                                },
                                              ),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                        },
                                        tooltip: "Delete",
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