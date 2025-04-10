// lib/pages/confirmation_page.dart
import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMatch = ModalRoute.of(context)!.settings.arguments as bool;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Center(
        child: isMatch
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 20),
                  Text('✅ Identity Verified Successfully!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 80),
                  SizedBox(height: 20),
                  Text('❌ Verification Failed',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
