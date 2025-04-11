// lib/services/ekyc_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class EKYCService {
  static const String baseUrl = 'http://172.16.12.41:8000';

  static Future<void> verifyICStructure(File icImage) async {
    var uri = Uri.parse('$baseUrl/verify_ic_structure/');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('ic_image', icImage.path));

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> result = jsonDecode(responseBody);

    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'IC structure verification failed');
    }
  }

  // // Optional: Extract IC text (if needed for UI feedback)
  // static Future<IcTextResult> extractICText(File icImage) async {
  //   var uri = Uri.parse('$baseUrl/extract_ic_text/');
  //   var request = http.MultipartRequest('POST', uri)
  //     ..files.add(await http.MultipartFile.fromPath('ic_image', icImage.path));

  //   var response = await request.send();
  //   final responseBody = await response.stream.bytesToString();
  //   final Map<String, dynamic> result = jsonDecode(responseBody);

  //   if (result['success'] == true) {
  //     return IcTextResult.fromJson(result['data']);
  //   } else {
  //     throw Exception(result['error'] ?? 'Failed to extract IC text');
  //   }
  // }

  static Future<LivenessVerificationResult> verifyLivenessAndMatch(File icImage, List<File> selfieFrames) async {
    var uri = Uri.parse('$baseUrl/verify_liveness_and_match/');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('ic_image', icImage.path));

    for (var frame in selfieFrames) {
      request.files.add(await http.MultipartFile.fromPath('selfie_images', frame.path));
    }

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> result = jsonDecode(responseBody);

    if (result['success'] == true) {
      return LivenessVerificationResult.fromJson(result['data']);
    } else {
      throw Exception(result['error'] ?? 'Liveness and face match verification failed');
    }
  }
}


class IcTextResult {
  final String icNumber;
  final String name;
  final String address;
  final String rawText;

  IcTextResult({required this.icNumber, required this.name, required this.address, required this.rawText});

  factory IcTextResult.fromJson(Map<String, dynamic> json) {
    return IcTextResult(
      icNumber: json['ic_number'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rawText: json['raw_text'] ?? '',
    );
  }
}

class FaceVerificationResult {
  final double similarity;
  final bool match;
  final Map<String, dynamic> savedFiles;

  FaceVerificationResult({required this.similarity, required this.match, required this.savedFiles});

  factory FaceVerificationResult.fromJson(Map<String, dynamic> json) {
    return FaceVerificationResult(
      similarity: (json['similarity'] as num).toDouble(),
      match: json['match'],
      savedFiles: json['saved_files'] ?? {},
    );
  }
}

class LivenessVerificationResult {
  final double similarity;
  final bool match;
  final bool livenessPassed;
  final int framesProcessed;

  LivenessVerificationResult({
    required this.similarity,
    required this.match,
    required this.livenessPassed,
    required this.framesProcessed,
  });

  factory LivenessVerificationResult.fromJson(Map<String, dynamic> json) {
    return LivenessVerificationResult(
      similarity: (json['similarity'] as num).toDouble(),
      match: json['match'],
      livenessPassed: json['liveness_passed'],
      framesProcessed: json['frames_processed'],
    );
  }
}