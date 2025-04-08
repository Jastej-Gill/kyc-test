import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector;

  FaceDetectorService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableContours: true,
            enableClassification: true,
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  Future<bool> hasSingleFace(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces.length == 1;
    } catch (e) {
      print('Error detecting face: $e');
      return false;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
