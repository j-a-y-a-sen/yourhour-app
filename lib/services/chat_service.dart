import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==============================
  // CREATE CHAT
  // ==============================
  Future<String> createChat(String user1, String user2) async {
    try {
      DocumentReference chatRef =
          await _firestore.collection('chats').add({
        'participants': [user1, user2],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'blockedBy': [], // important for blocking system
      });

      return chatRef.id;
    } catch (e) {
      throw Exception("Error creating chat: $e");
    }
  }

  // ==============================
  // SEND MESSAGE
  // ==============================
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      DocumentSnapshot chatDoc =
          await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        throw Exception("Chat does not exist");
      }

      List blockedBy = chatDoc['blockedBy'] ?? [];

      // Check if sender is blocked
      if (blockedBy.contains(senderId)) {
        throw Exception("You are blocked in this chat");
      }

      // Add message
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Send Message Error: $e");
    }
  }

  // ==============================
  // GET MESSAGES (REALTIME)
  // ==============================
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ==============================
  // GET USER CHATS
  // ==============================
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ==============================
  // BLOCK USER
  // ==============================
  Future<void> blockUser(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'blockedBy': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print("Block Error: $e");
    }
  }

  // ==============================
  // UNBLOCK USER
  // ==============================
  Future<void> unblockUser(String chatId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'blockedBy': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print("Unblock Error: $e");
    }
  }

  // ==============================
  // DELETE MESSAGE
  // ==============================
  Future<void> deleteMessage(
      String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Delete Message Error: $e");
    }
  }

  // ==============================
  // REPORT USER
  // ==============================
  Future<void> reportUser({
    required String chatId,
    required String reportedUserId,
    required String reportedBy,
    required String reason,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'chatId': chatId,
        'reportedUserId': reportedUserId,
        'reportedBy': reportedBy,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Report Error: $e");
    }
  }
}