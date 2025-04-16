import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ekyc_service.dart';
import '../utils/frame_dimensions.dart';

class UploadICPage extends StatefulWidget {
  const UploadICPage({super.key});

  @override
  State<UploadICPage> createState() => _UploadICPageState();
}

class _UploadICPageState extends State<UploadICPage> {
  File? _idCardImage;
  String? _error;
  bool _isExtracting = false;
  Map<String, dynamic>? _verificationResult;

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
      _verificationResult = null;
    });

    try {
      final result = await EKYCService.verifyICStructure(file);

      setState(() {
        _verificationResult = result['data'];
      });

      final type = _verificationResult?['detected_document_type'];
      final orb = _verificationResult?['orb_match_score'];
      final ssim = _verificationResult?['ssim_score'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Verified as $type\nORB Score: $orb, SSIM: $ssim",
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      final shouldReset = errorMessage.contains("no face") ||
          errorMessage.contains("small face") ||
          errorMessage.contains("structure") ||
          errorMessage.contains("valid text") ||
          errorMessage.contains("not match");

      if (shouldReset) {
        setState(() {
          _idCardImage = null;
          _verificationResult = null;
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
    final Size frameSize = getIDFrameSize(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload ID')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Step 1: Upload your ID',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: frameSize.width,
                    height: frameSize.height,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _idCardImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: frameSize.width,
                                height: frameSize.height,
                                child: Image.file(
                                  _idCardImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text('No IC uploaded', style: TextStyle(color: Colors.grey)),
                          ),
                  ),
                  Container(
                    width: frameSize.width,
                    height: frameSize.height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white60, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Positioned(
                    bottom: -28,
                    child: Text(
                      "Captured Area",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (_error != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!.toLowerCase().contains("face")
                        ? "No face detected. Please retake with a clearer ID image."
                        : _error!.toLowerCase().contains("text")
                            ? "IC verification failed due to unreadable text."
                            : _error!.toLowerCase().contains("match")
                                ? "IC image doesn't match known layout. Please try again."
                                : 'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              if (_verificationResult != null) ...[
                const SizedBox(height: 10),
                Text(
                  "Verified as: ${_verificationResult?['detected_document_type']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text("ORB: ${_verificationResult?['orb_match_score']}, SSIM: ${_verificationResult?['ssim_score']}"),
              ],

              const SizedBox(height: 20),

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

              ElevatedButton(
                onPressed: (_idCardImage != null && !_isExtracting && _error == null && _verificationResult != null)
                    ? () => Navigator.pushNamed(
                          context,
                          '/liveness_check',
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
