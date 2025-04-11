// 📦 Clean, consistent LivenessCapturePage (matches ICCameraCapturePage layout)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../services/ekyc_service.dart';

class LivenessCapturePage extends StatefulWidget {
  const LivenessCapturePage({super.key});

  @override
  State<LivenessCapturePage> createState() => _LivenessCapturePageState();
}

class _LivenessCapturePageState extends State<LivenessCapturePage> with SingleTickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool cameraReady = false;
  bool isProcessing = false;
  String captureStatus = '';
  File? icImage;
  AnimationController? _flashController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<void> _setup() async {
    try {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is File) {
        icImage = args;
      } else {
        _showError("IC image missing. Please restart.");
        return;
      }

      cameras = await availableCameras();
      final frontCamera = cameras!.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );

      controller = CameraController(frontCamera, ResolutionPreset.medium);
      await controller!.initialize();

      if (!mounted) return;
      setState(() => cameraReady = true);
    } catch (e) {
      _showError("Camera error: $e");
    }
  }

  Future<void> _startCapture() async {
    if (!cameraReady || isProcessing) return;
    setState(() {
      isProcessing = true;
      captureStatus = "Capturing...";
    });

    try {
      final List<File> frames = [];
      for (int i = 0; i < 5; i++) {
        setState(() => captureStatus = "Frame ${i + 1}/5");
        await _flashController!.forward(from: 0);
        final picture = await controller!.takePicture();
        frames.add(File(picture.path));
        await Future.delayed(const Duration(milliseconds: 900));
      }

      setState(() => captureStatus = "Submitting...");
      if (icImage == null) return;

      final result = await EKYCService.verifyLivenessAndMatch(icImage!, frames);

      if (!mounted) return;
      Navigator.pushNamed(context, '/confirmation', arguments: result.match && result.livenessPassed);
    } catch (e) {
      _showRetryDialog("Liveness check failed: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        isProcessing = false;
        captureStatus = '';
      });
    }
  }

  void _showRetryDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Verification Failed'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            Navigator.pop(context);
            _startCapture();
          }, child: const Text('Retry')),
        ],
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  void dispose() {
    _flashController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraReady
          ? LayoutBuilder(
              builder: (context, constraints) {
                final screenSize = MediaQuery.of(context).size;
                final aspectRatio = controller!.value.aspectRatio;
                final frameWidth = screenSize.width * 0.65;
                final frameHeight = frameWidth * 1.20;

                return Stack(
                  children: [
                    // 🔦 Flash overlay
                    if (_flashController != null)
                      FadeTransition(
                        opacity: Tween(begin: 0.0, end: 0.8).animate(
                          CurvedAnimation(parent: _flashController!, curve: Curves.easeOut),
                        ),
                        child: Container(color: Colors.white),
                      ),
                    // ✅ Camera Preview
                    Center(
                      child: OverflowBox(
                        maxWidth: screenSize.height * aspectRatio,
                        maxHeight: screenSize.height,
                        child: CameraPreview(controller!),
                      ),
                    ),

                    // 🟢 Face Frame
                    Center(
                      child: Container(
                        width: frameWidth,
                        height: frameHeight,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(150),
                        ),
                      ),
                    ),

                    // 📢 Instruction (top)
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
                            "Blink and tilt your head left/right",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                    ),

                    // 🔄 Status and Button (bottom)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          if (captureStatus.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                captureStatus,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          FloatingActionButton(
                            onPressed: isProcessing ? null : _startCapture,
                            backgroundColor: Colors.white,
                            elevation: 4.0,
                            child: isProcessing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Icon(Icons.camera, color: Colors.black),
                          ),

                        ],
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
