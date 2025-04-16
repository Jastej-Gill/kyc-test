// lib/services/ekyc_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ekyc_models.dart'; 

class EKYCService {
  static const String baseUrl = 'http://172.16.100.188:8010';
  
  // static const String baseUrl = 'http://192.168.136.240:8000';

static Future<Map<String, dynamic>> verifyICStructure(File icImage) async {
  final uri = Uri.parse('$baseUrl/verify_ic_structure/');
  final request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('ic_image', icImage.path));

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  final Map<String, dynamic> result = jsonDecode(responseBody);

  if (result['success'] != true) {
    throw Exception(result['message'] ?? 'IC structure verification failed');
  }

  return result; 
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
  try {
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
      return LivenessVerificationResult.failure(result['error'] ?? 'Verification failed');
    }
  } catch (e) {
    return LivenessVerificationResult.failure(e.toString());
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