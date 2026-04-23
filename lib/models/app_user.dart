import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { listener, speaker }

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.createdAt,
    required this.updatedAt,
    this.selectedRole,
    this.lastActiveAt,
  });

  final String uid;
  final String email;
  final String nickname;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserRole? selectedRole;
  final DateTime? lastActiveAt;

  AppUser copyWith({
    String? uid,
    String? email,
    String? nickname,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserRole? selectedRole,
    DateTime? lastActiveAt,
    bool clearRole = false,
    bool clearLastActiveAt = false,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      selectedRole: clearRole ? null : (selectedRole ?? this.selectedRole),
      lastActiveAt: clearLastActiveAt
          ? null
          : (lastActiveAt ?? this.lastActiveAt),
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      nickname: map['nickname'] as String? ?? 'Anonymous',
      createdAt: _readDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(map['updatedAt']) ?? DateTime.now(),
      selectedRole: _roleFromString(map['selectedRole'] as String?),
      lastActiveAt: _readDate(map['lastActiveAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'selectedRole': selectedRole?.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActiveAt': lastActiveAt == null
          ? null
          : Timestamp.fromDate(lastActiveAt!),
    };
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  static UserRole? _roleFromString(String? value) {
    switch (value) {
      case 'listener':
        return UserRole.listener;
      case 'speaker':
        return UserRole.speaker;
      default:
        return null;
    }
  }
}
