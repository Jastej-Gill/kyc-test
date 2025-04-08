import 'dart:io';

void main() {
  final plugins = {
    'google_mlkit_commons-0.4.0': 'com.google_mlkit_commons',
    'google_mlkit_face_detection-0.7.0': 'com.google_mlkit_face_detection',
  };

  final basePath = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME']; // for Windows/Mac compatibility

  if (basePath == null) {
    print('⚠️  Could not detect your home directory.');
    return;
  }

  final pubCachePath =
      '$basePath${Platform.isWindows ? '\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev' : '/.pub-cache/hosted/pub.dev'}';

  plugins.forEach((plugin, namespace) {
    final gradleFile =
        File('$pubCachePath\\$plugin\\android\\build.gradle');

    if (!gradleFile.existsSync()) {
      print('❌ Skipping: $plugin not found.');
      return;
    }

    final lines = gradleFile.readAsLinesSync();
    final alreadyHasNamespace =
        lines.any((line) => line.trim().startsWith('namespace '));

    if (alreadyHasNamespace) {
      print('✅ $plugin already patched.');
      return;
    }

    final updatedLines = <String>[];
    bool inserted = false;

    for (final line in lines) {
      updatedLines.add(line);
      if (!inserted && line.trim().startsWith('android {')) {
        updatedLines.add('    namespace "$namespace"');
        inserted = true;
      }
    }

    gradleFile.writeAsStringSync(updatedLines.join('\n'));
    print('✅ Patched $plugin with namespace "$namespace".');
  });

  print('\n🎉 All done. Run `flutter clean` then `flutter run`.');
}
