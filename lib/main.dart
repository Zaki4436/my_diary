import 'package:flutter/material.dart';
import 'login.dart';
import 'homepage.dart';
import 'signup.dart';
import 'account.dart';
import 'password_change.dart';
import 'email_change.dart';
import 'splashscreen.dart';

final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

void main() {
  runApp(DiaryApp());
}

class DiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return MaterialApp(
          title: 'My Diary App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Color(0xFFFDF5FF),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Color(0xFF181A20),
          ),
          themeMode: isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => SplashPage(),
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignUpPage(),
            '/home': (context) => HomePage(),
            '/account': (context) => AccountPage(),
            '/change-password': (context) => PasswordChangePage(),
            '/change-email': (context) => EmailChangePage(),
          },
        );
      },
    );
  }
}