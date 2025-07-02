import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

final db = FirebaseFirestore.instance;

class SQLHelper {
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? prefs.getString('email');
  }

  // Insert a new user into Firestore
  static Future<void> insertUser(String username, String email, String password, int avatarIndex) async {
    final userDoc = db.collection('users').doc(email);
    await userDoc.set({
      'username': username,
      'email': email,
      'password': password,
      'avatarIndex': avatarIndex,
    });
  }

  // Insert a new diary entry
  static Future<void> insertEntry(String feeling, String description) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final now = DateTime.now();
    final formatted = DateFormat('d MMMM yyyy, h:mm a').format(now);

    await db.collection('users').doc(userId).collection('entries').add({
      'feeling': feeling,
      'description': description,
      'createdAt': formatted,
    });
  }

  // Get entries
  static Future<List<Map<String, dynamic>>> getEntries() async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    final snapshot = await db.collection('users').doc(userId).collection('entries').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'feeling': doc['feeling'],
        'description': doc['description'],
        'createdAt': doc['createdAt'],
      };
    }).toList();
  }

  // Update a specific entry
  static Future<void> updateEntry(String entryId, String feeling, String description) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final now = DateTime.now();
    final formatted = DateFormat('d MMMM yyyy, h:mm a').format(now);

    await db.collection('users').doc(userId).collection('entries').doc(entryId).update({
      'feeling': feeling,
      'description': description,
      'createdAt': formatted,
    });
  }

  // Delete a specific entry
  static Future<void> deleteEntry(String entryId) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    await db.collection('users').doc(userId).collection('entries').doc(entryId).delete();
  }

  // Delete all entries for the current user
  static Future<void> deleteAllUserEntries() async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final snapshot = await db.collection('users').doc(userId).collection('entries').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Delete user account
  static Future<void> deleteUserAccount() async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    await deleteAllUserEntries();
    await db.collection('users').doc(userId).delete();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}