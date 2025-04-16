import 'dart:io';

void main() async {
  final buildGradlePath = 'android/app/build.gradle';
  final batteryPlusPath = '.pub-cache/hosted/pub.dev/battery_plus-3.0.6/android/build.gradle';
  final homeDir = Platform.environment['HOME'] ?? '';
  final fullBatteryPlusPath = '$homeDir/$batteryPlusPath';
  
  try {
    // First, get kotlin version from your project's build.gradle
    final appBuildGradle = File(buildGradlePath);
    final content = await appBuildGradle.readAsString();
    
    // Extract kotlin version from main build.gradle
    final kotlinVersionRegex = RegExp(r'ext.kotlin_version\s*=\s*[\'"](.+?)[\'"]');
    final match = kotlinVersionRegex.firstMatch(content);
    final kotlinVersion = match?.group(1) ?? '1.7.10'; // Default to 1.7.10 if not found
    
    // Update battery_plus build.gradle
    final batteryBuildGradle = File(fullBatteryPlusPath);
    var batteryContent = await batteryBuildGradle.readAsString();
    
    // Add ext.kotlin_version at the beginning of the file
    if (!batteryContent.contains('ext.kotlin_version')) {
      batteryContent = 'ext.kotlin_version = "$kotlinVersion"\n$batteryContent';
      await batteryBuildGradle.writeAsString(batteryContent);
      print('Successfully added kotlin_version to battery_plus build.gradle');
    }
  } catch (e) {
    print('Error updating battery_plus build.gradle: $e');
  }
}
