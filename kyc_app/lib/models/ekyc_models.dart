// lib/models/ekyc_models.dart
class IcTextResult {
  final String icNumber;
  final String name;
  final String address;
  final String rawText;

  IcTextResult({
    required this.icNumber,
    required this.name,
    required this.address,
    required this.rawText,
  });

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

  FaceVerificationResult({
    required this.similarity,
    required this.match,
    required this.savedFiles,
  });

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
