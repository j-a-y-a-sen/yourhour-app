import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8E8CFF)])
              : LinearGradient(colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}