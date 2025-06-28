// Add these imports at the top if not present
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  int _selectedAvatar = 0; // 0: avatar1, 1: avatar2, 2: avatar3

  void _signup(BuildContext context) {
    // You can use _selectedAvatar to know which avatar was chosen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final avatars = [
      'assets/avatar1.webp',
      'assets/avatar2.webp',
      'assets/avatar3.webp',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
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
    );
  }
}