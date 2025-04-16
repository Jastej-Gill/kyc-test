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
class LivenessVerificationResult {
  final bool success;
  final bool match;
  final bool livenessPassed;
  final double similarity;
  final int framesProcessed;
  final String? error;

  LivenessVerificationResult({
    required this.success,
    required this.match,
    required this.livenessPassed,
    required this.similarity,
    required this.framesProcessed,
    this.error,
  });

  factory LivenessVerificationResult.fromJson(Map<String, dynamic> json) {
    return LivenessVerificationResult(
      success: true,
      match: json['match'] ?? false,
      livenessPassed: json['liveness_passed'] ?? false,
      similarity: (json['similarity'] ?? 0).toDouble(),
      framesProcessed: json['frames_processed'] ?? 0,
    );
  }

  factory LivenessVerificationResult.failure(String? errorMessage) {
    return LivenessVerificationResult(
      success: false,
      match: false,
      livenessPassed: false,
      similarity: 0.0,
      framesProcessed: 0,
      error: errorMessage,
    );
  }
}
