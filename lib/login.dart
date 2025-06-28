import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  void _login(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              //Icon(Icons.book_outlined, size: 100, color: const Color.fromARGB(255, 90, 133, 250)),
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
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _login(context),
                icon: Icon(Icons.login, color: Colors.white, size: 20,),
                label: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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