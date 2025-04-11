import 'package:flutter/material.dart';
import 'pages/upload_ic_page.dart';
import 'pages/verify_face_page.dart';
import 'pages/confirmation_page.dart';
import 'pages/ic_camera_capture_page.dart';
import 'pages/flutter_liveness_page.dart';


void main() => runApp(const KYCApp());

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
        // '/verify_face': (context) => const VerifyFacePage(),
        '/confirmation': (context) => const ConfirmationPage(),
        '/ic_camera': (context) => const ICCameraCapturePage(),
        '/liveness_check': (context) => const LivenessCapturePage(),
      },
    );
  }
}
