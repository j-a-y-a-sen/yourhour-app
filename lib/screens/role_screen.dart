import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/waiting_screen.dart';

class RoleScreen extends StatefulWidget {
  final String userId;

  const RoleScreen({super.key, required this.userId});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  bool isLoading = false;

  Future<void> selectRole(String role) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Save user role in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
        'role': role,
        'isAvailable': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate to waiting screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingScreen(
            userId: widget.userId,
            role: role,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget roleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Your Role"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                roleButton(
                  title: "I want to talk",
                  subtitle: "Be a Speaker",
                  icon: Icons.record_voice_over,
                  color: Colors.blue,
                  onTap: () => selectRole('speaker'),
                ),
                roleButton(
                  title: "I want to listen",
                  subtitle: "Be a Listener",
                  icon: Icons.favorite,
                  color: Colors.green,
                  onTap: () => selectRole('listener'),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}