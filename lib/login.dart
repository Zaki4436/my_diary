import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailError = false;
  bool _passError = false;

  void _login(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    setState(() {
      _emailError = _emailController.text.trim() != savedEmail;
      _passError = _passController.text.trim() != savedPassword;
    });

    if (!_emailError && !_passError) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset(
                'assets/logo.webp',
                width: 130,
                height: 130,
              ),
              SizedBox(height: 20),
              Text("Welcome To My Diary", style: TextStyle(color: Color.fromARGB(255, 47, 83, 179), fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: _emailError ? 'Wrong email' : null,
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
                  errorText: _passError ? 'Wrong password' : null,
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
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color.fromARGB(255, 47, 83, 179),
                ),
              ),
              TextButton(
                child: Text("Don't have an account? Sign Up"),
                onPressed: () => Navigator.pushNamed(context, '/signup'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// email: zakihassim
// password: kakitangan