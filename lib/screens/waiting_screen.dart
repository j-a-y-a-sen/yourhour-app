import 'package:flutter/material.dart';
import '../services/match_service.dart';
import 'chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class WaitingScreen extends StatefulWidget {
  final String userId;
  final String role;

  const WaitingScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final MatchService _matchService = MatchService();
  bool isSearching = true;

  @override
  void initState() {
    super.initState();
    startMatching();
  }

  Future<void> startMatching() async {
    try {
      // 🔥 MATCH FIND
      var match = await _matchService.findMatchOrAI(
        widget.userId,
        widget.role,
      );

      String chatId;

      if (match['type'] == 'human') {
        // 🔍 check existing chat
        String? existingChat = await _getExistingChat(
          widget.userId,
          match['userId'],
        );

        if (existingChat != null) {
          chatId = existingChat;
        } else {
          chatId = await _matchService.createChat(
            widget.userId,
            match['userId'],
          );
        }
      } else {
        // 🤖 AI fallback
        chatId = await _matchService.createAIChat(widget.userId);
      }

      // 🚀 SAFE NAVIGATION
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            currentUserId: widget.userId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // 🔥 EXISTING CHAT CHECK
  Future<String?> _getExistingChat(String user1, String user2) async {
var result = await FirebaseFirestore.instance        .collection('chats')
        .where('participants', arrayContains: user1)
        .get();

    for (var doc in result.docs) {
      List participants = doc['participants'];
      if (participants.contains(user2)) {
        return doc.id;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isSearching
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Finding someone for you... 💙",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            : const Text("Something went wrong"),
      ),
    );
  }
}