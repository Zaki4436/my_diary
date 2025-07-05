import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

final db = FirebaseFirestore.instance;

class SQLHelper {
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Manual signup
  static Future<void> insertManualUser(String username, String email, String password, XFile avatarFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final storageRef = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');

    await storageRef.putFile(File(avatarFile.path));
    final avatarUrl = await storageRef.getDownloadURL();

    await db.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'password': password,
      'avatarUrl': avatarUrl,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', uid);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('avatar_url', avatarUrl);
  }

  // Google signup
  static Future<void> insertGoogleUser(User googleUser) async {
    final uid = googleUser.uid;
    final doc = await db.collection('users').doc(uid).get();

    if (!doc.exists) {
      await db.collection('users').doc(uid).set({
        'username': googleUser.displayName ?? '',
        'email': googleUser.email ?? '',
        'avatarUrl': googleUser.photoURL ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', uid);
    await prefs.setString('username', googleUser.displayName ?? '');
    await prefs.setString('email', googleUser.email ?? '');
    await prefs.setString('avatar_url', googleUser.photoURL ?? '');
  }

  // Insert entries
  static Future<void> insertEntry(String feeling, String description, List<XFile> images) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final now = DateTime.now();
    final formatted = DateFormat('d MMMM yyyy, h:mm a').format(now);
    List<String> imageUrls = [];

    for (var image in images) {
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('entries/$userId/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      await imageRef.putFile(File(image.path));
      final url = await imageRef.getDownloadURL();
      imageUrls.add(url);
    }

    await db.collection('users').doc(userId).collection('entries').add({
      'feeling': feeling,
      'description': description,
      'imageUrls': imageUrls,
      'createdAt': formatted,
    });
  }

  // Update entries
  static Future<void> updateEntry(String entryId, String feeling, String description, List<XFile> newImages) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final entryRef = db.collection('users').doc(userId).collection('entries').doc(entryId);
    final entrySnapshot = await entryRef.get();

    // Delete old images
    final oldData = entrySnapshot.data();
    if (oldData != null && oldData['imageUrls'] != null) {
      for (String url in List<String>.from(oldData['imageUrls'])) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
        } catch (e) {
          print("Error deleting old image: $e");
        }
      }
    }

    // Upload new images
    List<String> newImageUrls = [];
    for (var image in newImages) {
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('entries/$userId/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      await imageRef.putFile(File(image.path));
      final url = await imageRef.getDownloadURL();
      newImageUrls.add(url);
    }

    final now = DateTime.now();
    final formatted = DateFormat('d MMMM yyyy, h:mm a').format(now);

    await entryRef.update({
      'feeling': feeling,
      'description': description,
      'imageUrls': newImageUrls,
      'createdAt': formatted,
    });
  }

  // Get entries
  static Future<List<Map<String, dynamic>>> getEntries() async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    final snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'feeling': doc['feeling'],
        'description': doc['description'],
        'createdAt': doc['createdAt'],
        'imageUrls': doc['imageUrls'] ?? [],
      };
    }).toList();
  }

  static Future<void> deleteEntry(String entryId) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final entryRef = db.collection('users').doc(userId).collection('entries').doc(entryId);
    final entrySnapshot = await entryRef.get();

    if (entrySnapshot.exists) {
      final data = entrySnapshot.data();
      if (data != null && data['imageUrls'] != null) {
        for (String url in List<String>.from(data['imageUrls'])) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(url);
            await ref.delete();
          } catch (e) {
            print("Error deleting image: $e");
          }
        }
      }
    }

    await entryRef.delete();
  }

  static Future<void> deleteAllUserEntries() async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final snapshot = await db.collection('users').doc(userId).collection('entries').get();
    for (var doc in snapshot.docs) {
      await deleteEntry(doc.id);
    }
  }

  static Future<void> deleteUserAccount() async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    await deleteAllUserEntries();
    await db.collection('users').doc(userId).delete();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await user.delete();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}