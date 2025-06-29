import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EmailChangePage extends StatefulWidget {
  @override
  State<EmailChangePage> createState() => _EmailChangePageState();
}

class _EmailChangePageState extends State<EmailChangePage> {
  final _oldEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  String? _emailError;
  String? _successMsg;

  Future<void> _changeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    setState(() {
      _successMsg = null;
    });

    if (_oldEmailController.text.trim().isEmpty || _newEmailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Please fill all fields';
      });
      return;
    }

    if (_oldEmailController.text.trim() != savedEmail) {
      setState(() {
        _emailError = 'Old email does not match current email';
      });
      return;
    }

    if (_oldEmailController.text.trim() == _newEmailController.text.trim()) {
      setState(() {
        _emailError = 'New email cannot be the same as old email';
      });
      return;
    }

    await prefs.setString('email', _newEmailController.text.trim());
    setState(() {
      _emailError = null;
      _successMsg = 'Email changed successfully!';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email changed successfully!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      duration: Duration(seconds: 2),
      backgroundColor: Color.fromARGB(255, 47, 83, 179),
      behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/account', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Email', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 47, 83, 179),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your old email and new email',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _oldEmailController,
                decoration: InputDecoration(
                  labelText: 'Old Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _newEmailController,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorText: _emailError,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _changeEmail,
                child: Text('Confirm Change', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Color.fromARGB(255, 47, 83, 179),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (_successMsg != null) ...[
                SizedBox(height: 16),
                Text(
                  _successMsg!,
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}