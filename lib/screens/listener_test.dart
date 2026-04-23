import 'package:flutter/material.dart';
import 'waiting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListenerTestScreen extends StatefulWidget {
  const ListenerTestScreen({super.key});

  @override
  State<ListenerTestScreen> createState() => _ListenerTestScreenState();
}

class _ListenerTestScreenState extends State<ListenerTestScreen>
    with SingleTickerProviderStateMixin {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Quick Test 💙",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 💬 Question Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF334155)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Someone says:\n\n\"I feel like nobody understands me.\"",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "What should you do?",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 20),

            buildOption(0, "Tell them to stop overthinking", Colors.red),
            buildOption(1, "Ignore and change topic", Colors.orange),
            buildOption(2,
                "Acknowledge and ask them to share more", Colors.green),
          ],
        ),
      ),
    );
  }

  // 🎯 OPTION WITH ANIMATION
  Widget buildOption(int index, String text, Color color) {
    bool isSelected = selectedIndex == index;
    bool isCorrect = index == 2;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (isCorrect) {
            showSuccess();
          } else {
            showError();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(isSelected ? 1 : 0.7),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 1,
              )
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ SUCCESS UI
  void showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Great job 💙",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "You're a good listener!",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => WaitingScreen(
                    userId:
                        FirebaseAuth.instance.currentUser!.uid,
                    role: 'listener',
                  ),
                ),
              );
            },
            child: const Text("Continue",
                style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
    );
  }

  // ❌ ERROR UI
  void showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Try again ❌"),
        backgroundColor: Colors.red,
      ),
    );
  }
}