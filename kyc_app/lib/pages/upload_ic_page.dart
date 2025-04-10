import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ekyc_service.dart';

class UploadICPage extends StatefulWidget {
  const UploadICPage({super.key});

  @override
  State<UploadICPage> createState() => _UploadICPageState();
}

class _UploadICPageState extends State<UploadICPage> {
  File? _idCardImage;
  String? _error;
  bool _isExtracting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickIC({required ImageSource source}) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      _processIC(File(pickedFile.path));
    }
  }

Future<void> _processIC(File file) async {
  setState(() {
    _idCardImage = file;
    _error = null;
    _isExtracting = true;
  });

  try {
    await EKYCService.verifyICStructure(file);
  } catch (e) {
    final errorMessage = e.toString().toLowerCase();
    final shouldReset = errorMessage.contains("no face") ||
        errorMessage.contains("small face") ||
        errorMessage.contains("structure") ||
        errorMessage.contains("valid text");

    if (shouldReset) {
      setState(() {
        _idCardImage = null;
      });
    }

    setState(() {
      _error = e.toString();
    });
  } finally {
    setState(() => _isExtracting = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final double frameWidth = MediaQuery.of(context).size.width * 0.85;
    final double frameHeight = frameWidth / 1.6; // 16:10 ratio

    return Scaffold(
      appBar: AppBar(title: const Text('Upload MyKad')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Step 1: Upload your MyKad',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // IC preview frame
              Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                alignment: Alignment.center,
                child: _idCardImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _idCardImage!,
                          fit: BoxFit.cover,
                          width: frameWidth,
                          height: frameHeight,
                        ),
                      )
                    : const Text(
                        'No IC uploaded',
                        style: TextStyle(color: Colors.grey),
                      ),
              ),

              const SizedBox(height: 20),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!.toLowerCase().contains("structure") || _error!.toLowerCase().contains("text")
                        ? "❌ IC verification failed. Please retake or upload a clearer MyKad."
                        : 'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              // Buttons to upload or retake
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExtracting ? null : () => _pickIC(source: ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('From Gallery'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExtracting
                          ? null
                          : () async {
                              final result = await Navigator.pushNamed(context, '/ic_camera');
                              if (result is File) {
                                _processIC(result);
                              }
                            },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Next step
              ElevatedButton(
                onPressed: (_idCardImage != null && !_isExtracting && _error == null)
                    ? () => Navigator.pushNamed(
                          context,
                          '/verify_face',
                          arguments: _idCardImage,
                        )
                    : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: _isExtracting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Verifying..."),
                        ],
                      )
                    : const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
