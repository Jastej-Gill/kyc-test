// ICCameraCapturePage.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart'; 
import 'package:image/image.dart' as img;

class ICCameraCapturePage extends StatefulWidget {
  const ICCameraCapturePage({super.key});

  @override
  State<ICCameraCapturePage> createState() => _ICCameraCapturePageState();
}

class _ICCameraCapturePageState extends State<ICCameraCapturePage> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras!.first, ResolutionPreset.medium);
    await controller!.initialize();
    if (mounted) {
      setState(() => isCameraReady = true);
    }
  }

 Future<void> _capturePhoto() async {
  if (!controller!.value.isInitialized || controller!.value.isTakingPicture) return;

  try {
    final XFile file = await controller!.takePicture();
    final bytes = await File(file.path).readAsBytes();

    // Decode and auto-orient the image
    img.Image? original = img.decodeImage(bytes);
    if (original == null) throw Exception("Failed to decode image.");

    final corrected = img.bakeOrientation(original);

    // Crop to match camera frame aspect ratio (16:10)
    final inputWidth = corrected.width;
    final inputHeight = corrected.height;
    final targetAspect = 16 / 10;

    int cropWidth = inputWidth;
    int cropHeight = (cropWidth / targetAspect).round();

    if (cropHeight > inputHeight) {
      cropHeight = inputHeight;
      cropWidth = (cropHeight * targetAspect).round();
    }

    final offsetX = ((inputWidth - cropWidth) / 2).round();
    final offsetY = ((inputHeight - cropHeight) / 2).round();

    final cropped = img.copyCrop(
      corrected,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );

    // Save cropped image to temp path
    final tempDir = await getTemporaryDirectory();
    final croppedPath = Path.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}_cropped.jpg');
    await File(croppedPath).writeAsBytes(img.encodeJpg(cropped));

    if (!mounted) return;
    Navigator.of(context).pop(File(croppedPath));
  } catch (e) {
    print('[ERROR] Capture error: $e');
  }
}

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: isCameraReady
        ? LayoutBuilder(
            builder: (context, constraints) {
              final screenSize = MediaQuery.of(context).size;
              final screenAspectRatio = screenSize.aspectRatio;
              final cameraAspectRatio = controller!.value.aspectRatio;

              final previewWidth = screenAspectRatio > cameraAspectRatio
                  ? screenSize.width
                  : screenSize.height * cameraAspectRatio;

              final previewHeight = screenAspectRatio > cameraAspectRatio
                  ? screenSize.width / cameraAspectRatio
                  : screenSize.height;

              final frameWidth = screenSize.width * 0.85;
              final frameHeight = frameWidth / cameraAspectRatio;

              return Stack(
                children: [
                  Center(
                    child: OverflowBox(
                      maxWidth: previewWidth,
                      maxHeight: previewHeight,
                      child: CameraPreview(controller!),
                    ),
                  ),

                  Center(
                    child: Container(
                      width: frameWidth,
                      height: frameHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: _capturePhoto,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera, color: Colors.black),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Align your MyKad inside the frame",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        : const Center(child: CircularProgressIndicator()),
  );
}



}
