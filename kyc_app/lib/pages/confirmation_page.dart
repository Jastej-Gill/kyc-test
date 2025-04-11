import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMatch = ModalRoute.of(context)!.settings.arguments as bool;

    final Color bgColor = isMatch ? const Color(0xFF2E7D32) : const Color(0xFFC62828); // deep green/red
    final String title = isMatch ? 'Identity Verified' : 'Verification Failed';
    final IconData icon = isMatch ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 100),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
