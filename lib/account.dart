import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Account')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 100, color: Colors.black),
              SizedBox(height: 10),
              Text('Current Account:', style: TextStyle(fontSize: 18)),
              Text('test@example.com', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                icon: Icon(Icons.logout, color: Colors.white, size: 20,),
                label: Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 47, 83, 179),
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add your delete account logic here
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
                            // Perform delete action here
                            Navigator.pop(context); // Close dialog
                            Navigator.pushReplacementNamed(context, '/'); // Go to login or home
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
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}