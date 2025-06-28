import 'package:flutter/material.dart';
import 'login.dart';
import 'homepage.dart';
import 'signup.dart';
import 'account.dart';

void main() {
  runApp(DiaryApp());
}

class DiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Diary App',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/account': (context) => AccountPage(),
      },
    );
  }
}