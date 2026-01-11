import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Add this import for Color
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service for handling user avatar/profile picture uploads and management
class AvatarService {
  static AvatarService? _instance;
  static AvatarService get instance => _instance ??= AvatarService._();

  AvatarService._();

  final ImagePicker _picker = ImagePicker();
  static const String bucketName = 'avatars';
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  /// Show options dialog for avatar selection (camera or gallery)
  Future<File?> pickAndCropAvatar({required ImageSource source}) async {
    try {
      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        debugPrint('No image selected');
        return null;
      }

      // Check file size
      final fileSize = await File(pickedFile.path).length();
      if (fileSize > maxFileSizeBytes) {
        debugPrint('Image too large: ${fileSize} bytes');
        throw Exception(
          'Image is too large. Please select an image under 5MB.',
        );
      }

      // Crop image
      final croppedFile = await _cropImage(pickedFile.path);
      return croppedFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      rethrow;
    }
  }

  /// Crop image to circular avatar format
  Future<File?> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          Platform.isAndroid
              ? AndroidUiSettings(
                  toolbarTitle: 'Crop Avatar',
                  toolbarColor: Colors.blue, // Using Colors constant
                  toolbarWidgetColor: Colors.white, // Using Colors constant
                  initAspectRatio: CropAspectRatioPreset.square,
                  lockAspectRatio: true,
                  // aspectRatioPresets removed in newer versions
                )
              : IOSUiSettings(
                  title: 'Crop Avatar',
                  aspectRatioLockEnabled: true,
                  resetAspectRatioEnabled: false,
                  // aspectRatioPresets removed in newer versions
                ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return File(imagePath); // Return original if crop fails
    }
  }

  /// Upload avatar to Supabase Storage and update user record
  Future<String?> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      debugPrint('=== AVATAR UPLOAD DEBUG START ===');
      debugPrint('UserId: $userId');
      debugPrint('ImageFile path: ${imageFile.path}');

      if (!SupabaseService.instance.isAvailable) {
        debugPrint('ERROR: Supabase is not available');
        throw Exception('Supabase is not available');
      }

      final client = SupabaseService.instance.client;
      debugPrint('Supabase client initialized');

      // Note: Skipping authentication check since we're using anon policies
      // This allows upload without requiring Supabase Auth session

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path).toLowerCase();
      final fileName = '$userId/avatar_$timestamp$extension';

      debugPrint('Uploading avatar: $fileName');
      debugPrint('Bucket name: $bucketName');

      // Get file size and mime type
      final fileSize = await imageFile.length();
      final mimeType = _getMimeType(extension);
      debugPrint('File size: $fileSize bytes');
      debugPrint('MIME type: $mimeType');

      // Note: We attempt upload directly and handle errors if bucket doesn't exist
      // This provides better error messages and doesn't block the upload attempt
      debugPrint('Attempting upload to storage bucket: $bucketName');

      // Upload to Supabase Storage
      final uploadPath = await client.storage
          .from(bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: FileOptions(cacheControl: '3600', upsert: true),
          );

      debugPrint('Upload successful: $uploadPath');

      // Get public URL
      final publicUrl = client.storage.from(bucketName).getPublicUrl(fileName);
      debugPrint('Public URL generated: $publicUrl');

      debugPrint('Updating user record in database...');
      debugPrint('UserId for update: $userId');
      debugPrint('Avatar URL: $publicUrl');
      debugPrint('File size: $fileSize');
      debugPrint('MIME type: $mimeType');

      // Update user record in database
      final updateResult = await client
          .from('users')
          .update({
            'avatar_url': publicUrl,
            'avatar_file_size': fileSize,
            'avatar_mime_type': mimeType,
          })
          .eq('id', userId)
          .select(); // Add .select() to see what was updated

      debugPrint('Database update result: $updateResult');
      debugPrint('User record updated successfully with avatar URL');
      debugPrint('=== AVATAR UPLOAD DEBUG END ===');

      return publicUrl;
    } catch (e) {
      debugPrint('=== AVATAR UPLOAD ERROR ===');
      debugPrint('Error uploading avatar: $e');
      debugPrint('Error type: ${e.runtimeType}');

      // Provide helpful error messages based on error type
      if (e.toString().contains('Bucket not found') ||
          e.toString().contains('bucket_id') ||
          e.toString().contains('InvalidBucketId')) {
        debugPrint(
          'BUCKET ERROR - The "avatars" storage bucket does not exist',
        );
        debugPrint('SOLUTION: Follow the setup guide in bucket_setup_guide.md');
        throw Exception(
          'Storage bucket not configured. Please follow the setup guide in bucket_setup_guide.md to create the "avatars" bucket.',
        );
      } else if (e.toString().contains('Unauthorized') ||
          e.toString().contains('permission') ||
          e.toString().contains('policy')) {
        debugPrint(
          'AUTHORIZATION ERROR - Storage policies may be missing or incorrect',
        );
        debugPrint('SOLUTION: Run storage_policies.sql in Supabase SQL Editor');
        throw Exception(
          'Storage access denied. Please configure storage policies using storage_policies.sql',
        );
      } else if (e.toString().contains('new row violates row-level security')) {
        debugPrint('RLS POLICY ERROR - Storage policies are too restrictive');
        debugPrint('SOLUTION: Check storage policies for the avatars bucket');
        throw Exception(
          'Storage security policy error. Please verify storage policies are configured correctly.',
        );
      }

      debugPrint('=== END ERROR DEBUG ===');
      rethrow;
    }
  }

  /// Delete current avatar and revert to initials
  Future<void> deleteAvatar(String userId) async {
    try {
      if (!SupabaseService.instance.isAvailable) {
        throw Exception('Supabase is not available');
      }

      final client = SupabaseService.instance.client;

      // Get current avatar URL
      final response = await client
          .from('users')
          .select('avatar_url')
          .eq('id', userId)
          .single();

      final avatarUrl = response['avatar_url'] as String?;

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        // Extract file path from URL
        final uri = Uri.parse(avatarUrl);
        final filePath = uri.pathSegments.last;

        // Delete from storage (will be queued for cleanup)
        try {
          await client.storage.from(bucketName).remove(['$userId/$filePath']);
          debugPrint('Avatar deleted from storage');
        } catch (e) {
          debugPrint('Error deleting from storage: $e');
          // Continue even if storage deletion fails
        }
      }

      // Update user record to remove avatar
      await client
          .from('users')
          .update({
            'avatar_url': null,
            'avatar_file_size': null,
            'avatar_mime_type': null,
          })
          .eq('id', userId);

      debugPrint('Avatar removed from user record');
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
      rethrow;
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Check if image file is valid
  Future<bool> isValidImageFile(File file) async {
    try {
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        return false;
      }

      final extension = path.extension(file.path).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];

      return validExtensions.contains(extension);
    } catch (e) {
      debugPrint('Error validating image file: $e');
      return false;
    }
  }

  /// Get cache directory for temporary image storage
  Future<Directory> getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    final cacheDir = Directory('${directory.path}/avatar_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Clear cached avatar images
  Future<void> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('Avatar cache cleared');
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Download avatar to local cache for offline use
  Future<File?> cacheAvatar(String avatarUrl, String userId) async {
    try {
      final cacheDir = await getCacheDirectory();
      final fileName = 'avatar_$userId.jpg';
      final file = File('${cacheDir.path}/$fileName');

      // TODO: Download from URL and save to file
      // This would require dio or http package for downloading

      return file;
    } catch (e) {
      debugPrint('Error caching avatar: $e');
      return null;
    }
  }
}
