import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../services/avatar_service.dart';
import '../services/avatar_state_manager.dart';
import 'glass_card.dart';

/// Avatar picker widget that shows options to take photo or choose from gallery
class AvatarPickerWidget extends StatefulWidget {
  final String userId;
  final Function(String avatarUrl) onAvatarUploaded;
  final VoidCallback? onError;

  const AvatarPickerWidget({
    Key? key,
    required this.userId,
    required this.onAvatarUploaded,
    this.onError,
  }) : super(key: key);

  @override
  State<AvatarPickerWidget> createState() => _AvatarPickerWidgetState();
}

class _AvatarPickerWidgetState extends State<AvatarPickerWidget> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 3.h),

            // Title
            Text(
              'Choose Avatar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 3.h),

            // Camera option
            _buildOption(
              context: context,
              icon: Icons.camera_alt,
              title: 'Take a Photo',
              subtitle: 'Use your camera',
              color: const Color(0xFF4A90E2),
              onTap: _isProcessing
                  ? null
                  : () => _handleImagePick(context, ImageSource.camera),
            ),

            SizedBox(height: 2.h),

            // Gallery option
            _buildOption(
              context: context,
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Pick from your photos',
              color: const Color(0xFF27AE60),
              onTap: _isProcessing
                  ? null
                  : () => _handleImagePick(context, ImageSource.gallery),
            ),

            SizedBox(height: 2.h),

            // Remove avatar option
            _buildOption(
              context: context,
              icon: Icons.delete_outline,
              title: 'Remove Avatar',
              subtitle: 'Use initials instead',
              color: const Color(0xFFE74C3C),
              onTap: _isProcessing ? null : () => _handleRemoveAvatar(context),
            ),

            SizedBox(height: 2.h),

            // Processing indicator
            if (_isProcessing)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Processing...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDisabled = onTap == null;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GlassCard(
        padding: EdgeInsets.all(4.w),
        borderRadius: 3.w,
        opacity: 0.05,
        onTap: isDisabled ? null : onTap,
        child: Row(
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3.5.w),
                boxShadow: isDisabled
                    ? []
                    : [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(icon, color: Colors.white, size: 7.w),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isDisabled)
              Icon(Icons.arrow_forward_ios, color: color, size: 5.w),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePick(
    BuildContext context,
    ImageSource source,
  ) async {
    // Prevent multiple simultaneous operations
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // Store context reference before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Close bottom sheet first
    navigator.pop();

    // Wait for bottom sheet to close
    await Future.delayed(const Duration(milliseconds: 150));

    File? imageFile;

    try {
      // Pick and crop image
      imageFile = await AvatarService.instance.pickAndCropAvatar(
        source: source,
      );

      // User cancelled - just return
      if (imageFile == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      // Validate image
      final isValid = await AvatarService.instance.isValidImageFile(imageFile);
      if (!isValid) {
        _showErrorSnackBar(
          scaffoldMessenger,
          'Invalid image file. Please choose a different image.',
        );
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      // Upload to Supabase
      final avatarUrl = await AvatarService.instance.uploadAvatar(
        userId: widget.userId,
        imageFile: imageFile,
      );

      if (avatarUrl != null) {
        // Update global state manager
        AvatarStateManager().updateAvatar(avatarUrl, widget.userId);

        // Call callback
        widget.onAvatarUploaded(avatarUrl);

        // Show success message
        _showSuccessSnackBar(scaffoldMessenger, 'Avatar updated successfully!');
      } else {
        throw Exception('Failed to get avatar URL');
      }
    } catch (e) {
      debugPrint('Error in _handleImagePick: $e');
      _showErrorSnackBar(
        scaffoldMessenger,
        e.toString().contains('too large')
            ? e.toString()
            : 'Failed to upload avatar. Please try again.',
      );
      if (widget.onError != null) widget.onError!();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRemoveAvatar(BuildContext context) async {
    // Prevent multiple simultaneous operations
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // Store context references
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Close bottom sheet first
    navigator.pop();

    // Wait for bottom sheet to close
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      // Show confirmation dialog with a new context
      final BuildContext? dialogContext = navigator.context;
      if (dialogContext == null || !dialogContext.mounted) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      final confirm = await showDialog<bool>(
        context: dialogContext,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            'Remove Avatar?',
            style: Theme.of(dialogContext).textTheme.titleLarge,
          ),
          content: Text(
            'Your profile picture will be removed and replaced with your initials.',
            style: Theme.of(dialogContext).textTheme.bodyMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      // Delete avatar
      await AvatarService.instance.deleteAvatar(widget.userId);

      // Update global state manager
      AvatarStateManager().updateAvatar(null, widget.userId);

      // Call callback with empty string to signal removal
      widget.onAvatarUploaded('');

      // Show success message
      _showSuccessSnackBar(scaffoldMessenger, 'Avatar removed successfully!');
    } catch (e) {
      debugPrint('Error in _handleRemoveAvatar: $e');
      _showErrorSnackBar(
        scaffoldMessenger,
        'Failed to remove avatar. Please try again.',
      );
      if (widget.onError != null) widget.onError!();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 2.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Show avatar picker bottom sheet
Future<void> showAvatarPicker({
  required BuildContext context,
  required String userId,
  required Function(String avatarUrl) onAvatarUploaded,
  VoidCallback? onError,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => AvatarPickerWidget(
      userId: userId,
      onAvatarUploaded: onAvatarUploaded,
      onError: onError,
    ),
  );
}
