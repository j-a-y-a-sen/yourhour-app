import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: Colors.grey),
          SizedBox(width: 5),
          CircleAvatar(radius: 5, backgroundColor: Colors.grey),
          SizedBox(width: 5),
          CircleAvatar(radius: 5, backgroundColor: Colors.grey),
        ],
      ),
    );
  }
}