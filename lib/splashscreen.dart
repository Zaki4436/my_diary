import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start the navigation process after a delay
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(Duration(seconds: 2)); 
    // Check if the user is already logged in
    // by checking if email is stored in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    // If user already logged in, navigate to home page
    if (email != null && email.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    // Otherwise, navigate to login page
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 47, 83, 179),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.webp', width: 120, height: 120),
            SizedBox(height: 24),
            Text(
              "My Diary",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16),
            //Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
