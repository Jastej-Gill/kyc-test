# Flutter eKYC Frontend

This Flutter app allows users to complete an electronic Know Your Customer (eKYC) process by:
- Uploading their MyKad (Malaysian ID)
- Performing face verification and liveness check using the front camera
- Receiving confirmation results (match + liveness)

## 📱 Requirements

- Flutter 3.x installed
- Android/iOS device (camera support required)
- Backend server running (FastAPI — see backend readme)

## 🔧 Setup & Run

```bash
flutter pub get
flutter run
```

## ⚠️ IMPORTANT: Configure API URL

Before running the app, ensure the backend API URL is correctly set in:

```dart
lib/services/ekyc_service.dart

Use http://10.0.2.2:8000 if testing on Android emulator

Use your machine IP (e.g. 192.168.1.x) if testing on a real device

