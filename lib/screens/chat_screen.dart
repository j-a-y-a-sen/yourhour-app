import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final AIService _ai = AIService();

  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool chatEnded = false;

  // ✅ WELCOME MESSAGE
  @override
  void initState() {
    super.initState();
    messages.add({
      "text": "Hey 👋 I'm here to listen. Tell me what's on your mind 💙",
      "isUser": false
    });
  }

  // 🚨 SOS DETECTION
  bool isSOS(String text) {
    final t = text.toLowerCase();
    return t.contains("suicide") ||
        t.contains("kill me") ||
        t.contains("i want to die") ||
        t.contains("end my life") ||
        t.contains("don't wanna live");
  }

  // ❌ END CHAT
  bool isEnding(String text) {
    final t = text.toLowerCase();
    return t.contains("leave me alone") ||
        t.contains("not interested") ||
        t.contains("stop talking") ||
        t.contains("bye");
  }

  // 📩 SEND MESSAGE
  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty || chatEnded) return;

    String text = _controller.text.trim();
    _controller.clear();

    setState(() {
      messages.add({"text": text, "isUser": true});
      isTyping = true;
    });

    _scrollToBottom();

    // 🚨 SOS
    if (isSOS(text)) {
      setState(() {
        messages.add({
          "text":
              "🚨 I'm really sorry you're feeling this way.\n\n📞 India Helpline: 9152987821\nYou're not alone 💙",
          "isUser": false
        });
        isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    // ❌ END CHAT
    if (isEnding(text)) {
      setState(() {
        messages.add({
          "text": "Okay 💙 I’ll respect that. Take care.",
          "isUser": false
        });
        chatEnded = true;
        isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    // 🤖 AI REPLY
    String reply = await _ai.getReply(text);

    setState(() {
      messages.add({"text": reply, "isUser": false});
      isTyping = false;
    });

    _scrollToBottom();
  }

  // 📷 IMAGE PICK
  Future<void> pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        messages.add({
          "image": image.path,
          "isUser": true,
        });
      });
      _scrollToBottom();
    }
  }

  // 📞 CALL BUTTON
  void callUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📞 Calling feature coming soon...")),
    );
  }

  // 🔽 AUTO SCROLL
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 💬 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),

      // 🔝 APPBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "YourHour 💙",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: callUser,
          ),
        ],
      ),

      // 💬 BODY
      body: Column(
        children: [
          // 🧾 MESSAGES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["isUser"];

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF6C63FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: msg["image"] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(msg["image"])),
                          )
                        : Text(
                            msg["text"],
                            style: TextStyle(
                              color:
                                  isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // ✨ TYPING
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("AI is typing..."),
            ),

          // ✍️ INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5)
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !chatEnded,
                    decoration: InputDecoration(
                      hintText:
                          chatEnded ? "Chat ended" : "Share your thoughts...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6C63FF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}