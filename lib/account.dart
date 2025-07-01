import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'password_change.dart';
import 'email_change.dart';
import 'main.dart';
import 'homepage.dart';

bool _isDarkMode = isDarkMode.value;

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
  int _selectedIndex = 1;

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
    _isDarkMode = isDarkMode.value;
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
                SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
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
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5, bottom: 15),
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
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  icon: Icon(Icons.logout, color: Colors.white, size: 20,),
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
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/login');
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
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