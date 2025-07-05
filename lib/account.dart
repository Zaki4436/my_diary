import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'password_change.dart';
import 'email_change.dart';
import 'main.dart';
import 'homepage.dart';
import 'login.dart';

bool _isDarkMode = isDarkMode.value;

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // User information
  String _avatarUrl = '';
  String _username = 'My Account';
  String _email = 'test@example.com';
  String _password = '';
  // Selected index for bottom navigation
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    // Load user information from SharedPreferences
    _loadUserInfo();
  }

  // Function to load user information from SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarUrl = prefs.getString('avatar_url') ?? '';
      _username = prefs.getString('username') ?? 'My Account';
      _email = prefs.getString('email') ?? 'test@example.com';
      _password = prefs.getString('password') ?? '';
    });
  }

  // Function to update username in Firestore and SharedPreferences
  Future<void> _updateUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await prefs.setString('username', username);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': username,
    });

    setState(() {
      _username = username;
    });
  }

  // Function to show dialog for changing username
  void _showChangeUsernameDialog() {
    final controller = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Username'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'New Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _updateUsername(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmailChangePage()),
    );
  }

  // Functio for deletes user data from Firestore, FirebaseAuth, and SharedPreferences
  Future<void> _deleteAccount() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Delete entry from Firestore
      await FirebaseFirestore.instance.collection('entries').where('uid', isEqualTo: uid).get().then((snap) async {
        for (var doc in snap.docs) {
          await doc.reference.delete();
        }
      });

      // Delete user document from Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // Delete user account from FirebaseAuth
      await FirebaseAuth.instance.currentUser?.delete();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login page
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      // Handle errors during account deletion
      print('Account deletion error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: ${e.toString()}')),
      );
    }
  }

  // Function to pick a new avatar image from gallery
  Future<void> _pickNewAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;

    final path = picked.path;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_url', path);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatar_url': path,
      });
    }

    setState(() {
      _avatarUrl = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = isDarkMode.value;
    // Update the theme based on dark mode value
    return Theme(
      data: _isDarkMode
          ? ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black)
          : ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
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
              child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
            ),
            if (_isDarkMode)
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            Column(
              children: [
                SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
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
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickNewAvatar,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarUrl.startsWith('http')
                        ? NetworkImage(_avatarUrl)
                        : _avatarUrl.isNotEmpty
                            ? FileImage(File(_avatarUrl)) as ImageProvider
                            : AssetImage('assets/avatar1.webp'),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _username,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: _showChangeUsernameDialog,
                  child: Text(
                    "Change Username",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _isDarkMode
                          ? Color.fromARGB(255, 128, 161, 252)
                          : Color.fromARGB(255, 47, 83, 179),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _showChangeEmailDialog,
                      child: Text(
                        "Change Email",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _isDarkMode
                              ? Color.fromARGB(255, 128, 161, 252)
                              : Color.fromARGB(255, 47, 83, 179),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PasswordChangePage()),
                        );
                      },
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _isDarkMode
                              ? Color.fromARGB(255, 128, 161, 252)
                              : Color.fromARGB(255, 47, 83, 179),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: Icon(Icons.logout, color: Colors.white, size: 20),
                  label: Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 47, 83, 179),
                    minimumSize: Size(300, 48),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Account'),
                        content: Text('Are you sure you want to delete your account?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _deleteAccount();
                            },
                            child: Text('Confirm', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.delete, color: Colors.white, size: 20),
                  label: Text('Delete Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(300, 48),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Bottom navigation bar with two icons
        bottomNavigationBar: BottomAppBar(
          color: _isDarkMode ? Colors.grey[900] : Colors.white,
          shape: CircularNotchedRectangle(),
          notchMargin: 5,
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
                          ? (_isDarkMode ? Colors.white : Color.fromARGB(255, 47, 83, 179))
                          : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
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
                          ? (_isDarkMode ? Colors.white : Color.fromARGB(255, 47, 83, 179))
                          : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    tooltip: "Settings",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}