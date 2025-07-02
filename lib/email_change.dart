import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class EmailChangePage extends StatefulWidget {
  @override
  State<EmailChangePage> createState() => _EmailChangePageState();
}

class _EmailChangePageState extends State<EmailChangePage> {
  final _oldEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _successMsg;

  bool _obscurePassword = true;

  Future<void> _changeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final oldEmail = _oldEmailController.text.trim();
    final newEmail = _newEmailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final currentEmail = prefs.getString('email') ?? '';
    final currentUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _successMsg = null;
      _emailError = null;
    });

    if (oldEmail.isEmpty || newEmail.isEmpty || password.isEmpty) {
      setState(() {
        _emailError = 'Please fill all fields';
      });
      return;
    }

    if (oldEmail != currentEmail) {
      setState(() {
        _emailError = 'Old email does not match current email';
      });
      return;
    }

    if (oldEmail == newEmail) {
      setState(() {
        _emailError = 'New email cannot be the same as old email';
      });
      return;
    }

    try {
      final cred = EmailAuthProvider.credential(email: oldEmail, password: password);
      await currentUser?.reauthenticateWithCredential(cred);

      await currentUser?.verifyBeforeUpdateEmail(newEmail);

      setState(() {
        _successMsg = 'Verification email sent to new address. Please check your inbox.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification email sent. Check your inbox.',
            style: TextStyle(
              color: Color.fromARGB(255, 56, 56, 56),
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Email change error: $e');
      setState(() {
        _emailError = 'Failed to change email. Make sure password is correct and new email is valid.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool _isDarkMode = isDarkMode.value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Change Email', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 47, 83, 179),
        iconTheme: IconThemeData(color: Colors.white),
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
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.7),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your old email, new email, and password',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _oldEmailController,
                    decoration: InputDecoration(
                      labelText: 'Old Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _newEmailController,
                    decoration: InputDecoration(
                      labelText: 'New Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      errorText: _emailError,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                  ElevatedButton(
                    onPressed: _changeEmail,
                    child: Text('Confirm Change',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Color.fromARGB(255, 47, 83, 179),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_successMsg != null) ...[
                    SizedBox(height: 16),
                    Text(
                      _successMsg!,
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}