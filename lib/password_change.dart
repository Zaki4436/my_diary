import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'login.dart';

class PasswordChangePage extends StatefulWidget {
  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final _emailController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _emailVerified = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _emailError;
  String? _passError;

  Future<void> _verifyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';

    setState(() {
      if (_emailController.text.trim() == savedEmail) {
        _emailVerified = true;
        _emailError = null;
      } else {
        _emailError = 'Email not found or incorrect';
      }
    });
  }

  Future<void> _changePassword() async {
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _passError = 'Please fill all fields');
      return;
    }

    if (newPass != confirmPass) {
      setState(() => _passError = 'Passwords do not match');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentPassword = prefs.getString('password') ?? '';

    if (newPass == currentPassword) {
      setState(() => _passError = 'New password cannot be the same as current password');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user signed in');

      await user.updatePassword(newPass);

      await prefs.setString('password', newPass);
      setState(() => _passError = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password changed successfully!',
            style: TextStyle(
              color: const Color.fromARGB(255, 56, 56, 56),
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      print('Password update error: $e');
      setState(() => _passError = 'Failed to change password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool _isDarkMode = isDarkMode.value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 47, 83, 179).withOpacity(0.8),
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
          if (_isDarkMode)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: !_emailVerified
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enter your account email for verification',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            errorText: _emailError,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _verifyEmail,
                          child: Text('Verify Email',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48),
                            backgroundColor:
                                const Color.fromARGB(255, 47, 83, 179),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enter your new password',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _newPassController,
                          obscureText: _obscureNew,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNew = !_obscureNew;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _confirmPassController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                            ),
                            errorText: _passError,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _changePassword,
                          child: Text('Change Password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48),
                            backgroundColor:
                                const Color.fromARGB(255, 47, 83, 179),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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