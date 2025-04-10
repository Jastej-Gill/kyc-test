import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ekyc_service.dart';

class VerifyFacePage extends StatefulWidget {
  const VerifyFacePage({super.key});

  @override
  State<VerifyFacePage> createState() => _VerifyFacePageState();
}

class _VerifyFacePageState extends State<VerifyFacePage> {
  File? _selfie;
  String? _error;
  bool _isVerifying = false;
  double? _similarity;
  bool? _match;

  final ImagePicker _picker = ImagePicker();

  Future<void> _takeSelfie() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
        _match = null;
        _similarity = null;
        _error = null;
      });
    }
  }

  Future<void> _verify() async {
    if (_selfie == null) return;
    final icImage = ModalRoute.of(context)!.settings.arguments as File;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final result = await EKYCService.verifyFaceMatch(icImage, _selfie!);
      setState(() {
        _isVerifying = false;
        _similarity = result.similarity;
        _match = result.match;
      });

      if (result.match) {
        Navigator.pushNamed(context, '/confirmation', arguments: true);
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _error = e.toString();
        _match = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Selfie & Verify')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Step 2: Submit Selfie', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Head-Shaped Selfie Frame
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[300],
              backgroundImage: _selfie != null ? FileImage(_selfie!) : null,
              child: _selfie == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white70)
                  : null,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _takeSelfie,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Selfie'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),

            const SizedBox(height: 20),

            if (_selfie != null)
              ElevatedButton(
                onPressed: _verify,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: _isVerifying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text('Verify'),
              ),

            const SizedBox(height: 16),

            if (_similarity != null)
              Text(
                'Similarity Score: ${(_similarity! * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16),
              ),

            if (_match == false)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('❌ Face does not match. Please try again.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
