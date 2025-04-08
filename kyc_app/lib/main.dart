import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/face_detector_service.dart';

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
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickIC() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _idCardImage = File(pickedFile.path);
      });
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
            const Text('Step 1: Please upload your MyKad'),
            const SizedBox(height: 10),
            _idCardImage != null
                ? Image.file(_idCardImage!, height: 200)
                : const Text('No MyKad uploaded'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickIC,
              icon: const Icon(Icons.photo),
              label: const Text('Upload MyKad'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _idCardImage != null
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/verify_face',
                        arguments: _idCardImage,
                      );
                    }
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page 2: Take Selfie + Simulated Verification
class VerifyFacePage extends StatefulWidget {
  const VerifyFacePage({super.key});

  @override
  State<VerifyFacePage> createState() => _VerifyFacePageState();
}

class _VerifyFacePageState extends State<VerifyFacePage> {
  File? _selfie;
  final ImagePicker _picker = ImagePicker();
  bool _isVerifying = false;
  bool? _isMatch;
  late FaceDetectorService _faceService;

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    _faceService = FaceDetectorService();
  }

  Future<void> _takeSelfie() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
        _isMatch = null; // reset result
      });
    }
  }

  Future<void> _simulateFaceMatch() async {
    
    if(_selfie == null) return;
    
    setState(() {
      _isVerifying = true;
      _isMatch = null;
    });

    final faceDetected = await _faceService.hasSingleFace(_selfie!);

    setState(() {
      _isVerifying = false;
      _isMatch = faceDetected;
    });

    if (faceDetected) {
      Navigator.pushNamed(context, '/confirmation', arguments: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final File icImage = ModalRoute.of(context)!.settings.arguments as File;

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
            if (_selfie != null && _isMatch == null)
              ElevatedButton(
                onPressed: _simulateFaceMatch,
                child: _isVerifying
                    ? const CircularProgressIndicator()
                    : const Text('Verify'),
              ),
            if (_isMatch == false)
              const Text(
                '❌ Face does not match. Please retake selfie.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _faceService.dispose();
    super.dispose();
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 80),
                  SizedBox(height: 20),
                  Text('❌ Verification Failed',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
