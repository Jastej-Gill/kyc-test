// main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/ekyc_service.dart';

void main() {
  runApp(const KYCApp());
}

class KYCApp extends StatelessWidget {
  const KYCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KYC Proof of Concept',
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      initialRoute: '/upload_ic',
      routes: {
        '/upload_ic': (context) => const UploadICPage(),
        '/verify_face': (context) => const VerifyFacePage(),
        '/confirmation': (context) => const ConfirmationPage(),
      },
    );
  }
}

// Page 1: Upload IC
class UploadICPage extends StatefulWidget {
  const UploadICPage({super.key});

  @override
  State<UploadICPage> createState() => _UploadICPageState();
}

class _UploadICPageState extends State<UploadICPage> {
  File? _idCardImage;
  String? _icName;
  String? _icAddress;
  String? _icNumber;
  String? _error;
  bool _isExtracting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickIC() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _idCardImage = File(pickedFile.path);
        _icName = null;
        _icAddress = null;
        _icNumber = null;
        _error = null;
        _isExtracting = true;
      });

      try {
        final result = await EKYCService.extractICText(_idCardImage!);
        setState(() {
          _icName = result.name;
          _icAddress = result.address;
          _icNumber = result.icNumber;
        });
      } catch (e) {
        setState(() => _error = e.toString());
      } finally {
        setState(() => _isExtracting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload MyKad')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Step 1: Upload your MyKad'),
            const SizedBox(height: 10),
            if (_idCardImage != null)
              Image.file(_idCardImage!, height: 200),
            if (_isExtracting) const CircularProgressIndicator(),
            if (_icName != null) Text('Name: $_icName'),
            if (_icAddress != null) Text('Address: $_icAddress'),
            if (_icNumber != null) Text('IC No: $_icNumber'),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickIC,
              icon: const Icon(Icons.photo),
              label: const Text('Upload MyKad'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _idCardImage != null && _icName != null
                  ? () => Navigator.pushNamed(
                        context,
                        '/verify_face',
                        arguments: _idCardImage,
                      )
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page 2: Take Selfie + Real Face Comparison
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
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
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
      final result = await EKYCService.verifyFace(icImage, _selfie!);
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
          children: [
            const Text('Step 2: Take a clear selfie'),
            const SizedBox(height: 10),
            _selfie != null
                ? Image.file(_selfie!, height: 200)
                : const Text('No selfie taken'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _takeSelfie,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Selfie'),
            ),
            const SizedBox(height: 20),
            if (_selfie != null)
              ElevatedButton(
                onPressed: _verify,
                child: _isVerifying
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Verifying...'),
                        ],
                      )
                    : const Text('Verify'),
              ),
            if (_match != null && !_match!)
              const Text(
                '❌ Face does not match. Please try again.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

// Page 3: Confirmation
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