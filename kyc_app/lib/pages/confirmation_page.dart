import 'package:flutter/material.dart';
import '../models/ekyc_models.dart'; 

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = ModalRoute.of(context)!.settings.arguments as LivenessVerificationResult;

    final Color bgColor = result.success && result.match && result.livenessPassed
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);
    final IconData icon = result.success && result.match && result.livenessPassed
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;
    final String title = result.success && result.match && result.livenessPassed
        ? "Identity Verified"
        : "Verification Result";

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
              const SizedBox(height: 24),
              _infoRow("Face Match:", result.match ? "✅ Yes" : "❌ No"),
              _infoRow("Liveness Passed:", result.livenessPassed ? "✅ Yes" : "❌ No"),
              _infoRow("Similarity Score:", result.similarity.toStringAsFixed(3)),
              _infoRow("Frames Processed:", result.framesProcessed.toString()),
              if (result.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    "⚠️ ${result.error}",
                    style: const TextStyle(color: Colors.yellowAccent, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 40),
              if (!result.success) // If failed, show back to IC Upload
                OutlinedButton(
                  onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/upload_ic')),
                  style: _btnStyle(),
                  child: const Text('Back to Upload'),
                ),
              if (result.success)
                OutlinedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: _btnStyle(),
                  child: const Text('Continue'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  ButtonStyle _btnStyle() {
    return OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.white),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
