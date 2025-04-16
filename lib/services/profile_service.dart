import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmora/models/profile_model.dart';
import 'package:path/path.dart' as path;

class ProfileService {
  static const String _profileKey = 'user_profile';
  static Profile? _cachedProfile;

  static Future<Profile> getProfile() async {
    if (_cachedProfile != null) return _cachedProfile!;

    final prefs = await SharedPreferences.getInstance();
    final profileData = prefs.getString(_profileKey);
    
    if (profileData == null) {
      _cachedProfile = Profile(
        name: 'Default User',
        email: 'user@example.com',
        phoneNumber: '+250 XXX XXX XXX',
        address: 'Kigali, Rwanda',
      );
      return _cachedProfile!;
    }
    
    try {
      _cachedProfile = Profile.fromJson(jsonDecode(profileData));
      return _cachedProfile!;
    } catch (e) {
      print('Error parsing profile: $e');
      _cachedProfile = Profile(
        name: 'Default User',
        email: 'user@example.com',
        phoneNumber: '+250 XXX XXX XXX',
        address: 'Kigali, Rwanda',
      );
      return _cachedProfile!;
    }
  }

  static Future<void> saveProfile(Profile profile) async {
    _cachedProfile = profile;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<String?> updateProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedImagePath = '${appDir.path}/$fileName';
      
      final File newImage = File(savedImagePath);
      await newImage.writeAsBytes(await image.readAsBytes());
      
      final profile = await getProfile();
      
      // Delete old image if exists
      if (profile.profilePicturePath != null) {
        try {
          final oldFile = File(profile.profilePicturePath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          print('Error deleting old profile image: $e');
        }
      }
      
      profile.profilePicturePath = savedImagePath;
      await saveProfile(profile);
      
      return savedImagePath;
    } catch (e) {
      print('Error updating profile picture: $e');
      return null;
    }
  }
}
