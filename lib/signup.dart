import 'package:my_diary/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _usernameController = TextEditingController();

  int _selectedAvatar = 0;
  bool _obscurePassword = true;

  void _signup(BuildContext context) async{
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('avatar_index', _selectedAvatar);
    await prefs.setString('username', _usernameController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('password', _passController.text.trim());
    Navigator.pop(context);
  }

@override
  Widget build(BuildContext context) {
    final avatars = [
      'assets/avatar1.webp',
      'assets/avatar2.webp',
      'assets/avatar3.webp',
    ];

    final bool _isDarkMode = isDarkMode.value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _isDarkMode ? Colors.white : Color.fromARGB(255, 47, 83, 179)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
              color: _isDarkMode ? Colors.black.withOpacity(0.5) : null,
              colorBlendMode: _isDarkMode ? BlendMode.darken : BlendMode.srcOver,
            ),
          ),
          Container(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.7),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "Choose Your Avatar",
                    style: TextStyle(
                      color: Color.fromARGB(255, 47, 83, 179),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(avatars.length, (index) {
                      final isSelected = _selectedAvatar == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Color.fromARGB(255, 47, 83, 179)
                                  : Colors.transparent,
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundImage: AssetImage(avatars[index]),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                  Text("Create Account", style: TextStyle(color: Color.fromARGB(255, 47, 83, 179), fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _signup(context),
                    icon: Icon(Icons.person_3, color: Colors.white, size: 20),
                    label: Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: const Color.fromARGB(255, 47, 83, 179),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}