import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_diary/main.dart';


// Main login page
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for email and password input
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  // State variables for password visibility and error handling
  bool _obscurePassword = true;
  bool _emailError = false;
  bool _passError = false;

  // Function to handle manual login
  Future<void> _login(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    try {
      // Authenticate user with Firebase
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // Fetch user profile from Firestore
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final user = snapshot.data();

      if (user == null) throw Exception('User profile not found');

      // Save user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', uid);
      await prefs.setString('email', email);
      await prefs.setString('username', user['username'] ?? 'My Account');
      await prefs.setString('password', password);
      await prefs.setInt('avatar_index', user['avatarIndex'] ?? 0);

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Login failed: $e');
      setState(() {
        _emailError = true;
        _passError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  // Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      // Sign out any previous Google sign-in to avoid auto login
      await GoogleSignIn().signOut();

      // Choose Google account to sign in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      final uid = user.uid;
      final prefs = await SharedPreferences.getInstance();

      // Check if user profile exists in Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      // If not, create a new profile
      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': user.displayName ?? '',
          'email': user.email ?? '',
          'avatarIndex': 0,
          'avatarUrl': user.photoURL ?? '',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      // Save user data to SharedPreferences
      await prefs.setString('userId', uid);
      await prefs.setString('username', user.displayName ?? '');
      await prefs.setString('email', user.email ?? '');
      await prefs.setInt('avatar_index', 0);
      await prefs.setString('avatar_url', user.photoURL ?? '');

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Handle Google Sign-In errors
      print('Google Sign-In failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool _isDarkMode = isDarkMode.value;

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
    );
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
    );

    return Theme(
      data: _isDarkMode ? darkTheme : lightTheme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.7),
            ),
            Center(
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
                    Text(
                      "Welcome To My Diary",
                      style: TextStyle(
                        color: Color.fromARGB(255, 47, 83, 179),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Input fields for email
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        errorText: _emailError ? 'Wrong email or password' : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Input fields for password
                    TextField(
                      controller: _passController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        errorText: _passError ? 'Wrong email or password' : null,
                        // Toggle password visibility
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
                    SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset(
                        'assets/google.png',
                        height: 24,
                        width: 24,
                      ),
                      label: Text(
                        "Sign in with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/change-password'),
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}