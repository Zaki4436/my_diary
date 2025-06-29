import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'password_change.dart';
import 'email_change.dart';

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _avatarIndex = 0;
  final List<String> _avatars = [
    'assets/avatar1.webp',
    'assets/avatar2.webp',
    'assets/avatar3.webp',
  ];

  String _username = 'My Account';
  String _email = 'test@example.com';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _loadUserInfo();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarIndex = prefs.getInt('avatar_index') ?? 0;
    });
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'My Account';
      _email = prefs.getString('email') ?? 'test@example.com';
      _password = prefs.getString('password') ?? '';
    });
  }

  Future<void> _updateAvatar(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('avatar_index', index);
    setState(() {
      _avatarIndex = index;
    });
  }

  Future<void> _updateUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    setState(() {
      _username = username;
    });
  }

  Future<void> _updateEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    setState(() {
      _email = email;
    });
  }

  Future<void> _updatePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
    setState(() {
      _password = password;
    });
  }

  void _showChangeAvatarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose New Avatar'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_avatars.length, (index) {
            return GestureDetector(
              onTap: () {
                _updateAvatar(index);
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _avatarIndex == index
                        ? Color.fromARGB(255, 47, 83, 179)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(_avatars[index]),
                  backgroundColor: Colors.grey[200],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 47, 83, 179),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showChangeAvatarDialog,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(_avatars[_avatarIndex]),
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
                    color: Color.fromARGB(255, 47, 83, 179),
                    fontWeight: FontWeight.bold,
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
                        color: Color.fromARGB(255, 47, 83, 179),
                        fontWeight: FontWeight.bold,
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
                        color: Color.fromARGB(255, 47, 83, 179),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                icon: Icon(Icons.logout, color: Colors.white, size: 20,),
                label: Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 47, 83, 179),
                  minimumSize: Size(double.infinity, 48),
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
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, '/');
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
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}