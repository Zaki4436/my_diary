import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final List<String> _avatars = [
    'assets/avatar1.webp',
    'assets/avatar2.webp',
    'assets/avatar3.webp',
  ];
  int _selectedAvatar = 0;
  bool _obscurePassword = true;

  Future<void> _signup(BuildContext context) async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) return;

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'avatarIndex': _selectedAvatar,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', uid);
      await prefs.setString('username', username);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setInt('avatar_index', _selectedAvatar);

      Navigator.pop(context);
    } catch (e) {
      print('Signup failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        backgroundColor:
            isDarkMode ? Colors.grey[900] : Color.fromARGB(255, 47, 83, 179),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              "Choose Avatar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_avatars.length, (index) {
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
                        color: _selectedAvatar == index
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
            SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _signup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 47, 83, 179),
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Create Account",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Already have an account? Log in",
                style: TextStyle(
                  color: isDarkMode
                      ? Color.fromARGB(255, 128, 161, 252)
                      : Color.fromARGB(255, 47, 83, 179),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}