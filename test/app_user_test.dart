import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yourhour/models/app_user.dart';

void main() {
  test('AppUser serializes and deserializes cleanly', () {
    final now = DateTime(2026, 4, 11, 18, 0);
    final user = AppUser(
      uid: 'abc123',
      email: 'hello@example.com',
      nickname: 'hello',
      createdAt: now,
      updatedAt: now,
      selectedRole: UserRole.listener,
      lastActiveAt: now,
    );

    final map = user.toMap();
    final restored = AppUser.fromMap({
      ...map,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'lastActiveAt': Timestamp.fromDate(now),
    });

    expect(restored.uid, user.uid);
    expect(restored.email, user.email);
    expect(restored.nickname, user.nickname);
    expect(restored.selectedRole, user.selectedRole);
    expect(restored.createdAt, user.createdAt);
    expect(restored.updatedAt, user.updatedAt);
    expect(restored.lastActiveAt, user.lastActiveAt);
  });
}
