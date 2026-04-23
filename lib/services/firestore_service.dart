import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save user
  Future<DocumentReference> setRole(String role) async {
    return await _db.collection('users').add({
      'role': role,
      'matched': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Find match
  Future<DocumentSnapshot?> findMatch(String role) async {
    String opposite = role == "speaker" ? "listener" : "speaker";

    var result = await _db
        .collection('users')
        .where('role', isEqualTo: opposite)
        .where('matched', isEqualTo: false)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first;
    }

    return null;
  }

  /// Create match
  Future<void> createMatch(String user1, String user2) async {
    await _db.collection('matches').add({
      'users': [user1, user2],
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(user1).update({'matched': true});
    await _db.collection('users').doc(user2).update({'matched': true});
  }
}