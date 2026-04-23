import 'package:cloud_firestore/cloud_firestore.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> findMatchOrAI(String myId, String myRole) async {
    String oppositeRole = myRole == 'speaker' ? 'listener' : 'speaker';

    var result = await _firestore
        .collection('users')
        .where('role', isEqualTo: oppositeRole)
        .where('isAvailable', isEqualTo: true)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      return {
        'type': 'human',
        'userId': result.docs.first.id,
      };
    } else {
      return {
        'type': 'ai',
      };
    }
  }

  Future<String> createChat(String user1, String user2) async {
    var chat = await _firestore.collection('chats').add({
      'participants': [user1, user2],
      'timestamp': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'blockedBy': [],
    });

    return chat.id;
  }

  Future<String> createAIChat(String userId) async {
    var chat = await _firestore.collection('chats').add({
      'participants': [userId, 'AI_BOT'],
      'isAI': true,
      'timestamp': FieldValue.serverTimestamp(),
      'lastMessage': '',
    });

    return chat.id;
  }
}