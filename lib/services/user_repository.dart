import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<AppUser?> fetchCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final snapshot = await _users.doc(user.uid).get();
    if (!snapshot.exists) {
      return null;
    }

    return AppUser.fromMap(snapshot.data()!);
  }

  Future<AppUser> createUserProfile({
    required User user,
    required String nickname,
  }) async {
    final now = DateTime.now();
    final profile = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      nickname: nickname,
      createdAt: now,
      updatedAt: now,
    );

    await _users.doc(user.uid).set(profile.toMap());
    return profile;
  }

  Future<AppUser> ensureUserProfile({
    required User user,
    String? fallbackNickname,
  }) async {
    final existing = await fetchCurrentUserProfile();
    if (existing != null) {
      return existing;
    }

    return createUserProfile(
      user: user,
      nickname: fallbackNickname ?? _nicknameFromEmail(user.email),
    );
  }

  Future<void> updateSelectedRole(UserRole role) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user found.');
    }

    final now = Timestamp.fromDate(DateTime.now());
    await _users.doc(user.uid).set({
      'selectedRole': role.name,
      'updatedAt': now,
      'lastActiveAt': now,
    }, SetOptions(merge: true));
  }

  Stream<AppUser?> watchCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<AppUser?>.empty();
    }

    return _users.doc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return AppUser.fromMap(snapshot.data()!);
    });
  }

  String _nicknameFromEmail(String? email) {
    final value = email ?? '';
    if (value.contains('@')) {
      return value.split('@').first;
    }
    return 'Anonymous';
  }
}
