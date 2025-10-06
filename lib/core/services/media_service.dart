import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_constants.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService();
});

class MediaUploadResult {
  final String downloadUrl;
  final String? thumbnailUrl;
  final String fileName;
  final int fileSize;
  final int? duration;
  final Map<String, dynamic>? metadata;

  const MediaUploadResult({
    required this.downloadUrl,
    this.thumbnailUrl,
    required this.fileName,
    required this.fileSize,
    this.duration,
    this.metadata,
  });
}

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Upload image
  Future<MediaUploadResult> uploadImage({
    required File imageFile,
    required String chatId,
    bool generateThumbnail = true,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final fileName = '${const Uuid().v4()}.jpg';
      final imagePath = '${AppConstants.chatMedia}/$chatId/images/$fileName';

      // Compress image
      final compressedImage = await _compressImage(imageFile);

      // Upload original image
      final uploadTask = _storage.ref(imagePath).putData(compressedImage);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      String? thumbnailUrl;
      if (generateThumbnail) {
        thumbnailUrl = await _generateImageThumbnail(compressedImage, chatId);
      }

      final metadata = await _getImageMetadata(imageFile);

      return MediaUploadResult(
        downloadUrl: downloadUrl,
        thumbnailUrl: thumbnailUrl,
        fileName: fileName,
        fileSize: compressedImage.length,
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload video
  Future<MediaUploadResult> uploadVideo({
    required File videoFile,
    required String chatId,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final fileName = '${const Uuid().v4()}.mp4';
      final videoPath = '${AppConstants.chatMedia}/$chatId/videos/$fileName';

      // Check file size
      final fileSize = await videoFile.length();
      if (fileSize > AppConstants.maxVideoSize) {
        throw Exception('Video file too large. Maximum size is 50MB.');
      }

      // Upload video
      final uploadTask = _storage.ref(videoPath).putFile(videoFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Generate video thumbnail
      final thumbnailUrl = await _generateVideoThumbnail(videoFile, chatId);

      // Get video duration
      final duration = await _getVideoDuration(videoFile);

      return MediaUploadResult(
        downloadUrl: downloadUrl,
        thumbnailUrl: thumbnailUrl,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
      );
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  // Upload audio/voice message
  Future<MediaUploadResult> uploadAudio({
    required File audioFile,
    required String chatId,
    bool isVoiceMessage = false,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final extension = isVoiceMessage ? 'm4a' : 'mp3';
      final fileName = '${const Uuid().v4()}.$extension';
      final folder = isVoiceMessage ? 'voice' : 'audio';
      final audioPath = '${AppConstants.chatMedia}/$chatId/$folder/$fileName';

      // Check file size
      final fileSize = await audioFile.length();
      final maxSize = isVoiceMessage
          ? AppConstants.maxVoiceSize
          : AppConstants.maxVideoSize;
      if (fileSize > maxSize) {
        throw Exception('Audio file too large.');
      }

      // Upload audio
      final uploadTask = _storage.ref(audioPath).putFile(audioFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Get audio duration (you'd need to implement this based on your audio library)
      final duration = await _getAudioDuration(audioFile);

      return MediaUploadResult(
        downloadUrl: downloadUrl,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
      );
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }

  // Upload document
  Future<MediaUploadResult> uploadDocument({
    required File documentFile,
    required String chatId,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final fileName = documentFile.path.split('/').last;
      final documentPath =
          '${AppConstants.chatMedia}/$chatId/documents/$fileName';

      // Check file size
      final fileSize = await documentFile.length();
      if (fileSize > AppConstants.maxDocumentSize) {
        throw Exception('Document file too large. Maximum size is 20MB.');
      }

      // Upload document
      final uploadTask = _storage.ref(documentPath).putFile(documentFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return MediaUploadResult(
        downloadUrl: downloadUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(File imageFile) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final fileName = '$_currentUserId.jpg';
      final imagePath = '${AppConstants.profilePictures}/$fileName';

      // Compress and resize image
      final compressedImage = await _compressAndResizeImage(
        imageFile,
        500,
        500,
      );

      // Upload image
      final uploadTask = _storage.ref(imagePath).putData(compressedImage);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Upload group image
  Future<String> uploadGroupImage(File imageFile, String groupId) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final fileName = '$groupId.jpg';
      final imagePath = '${AppConstants.groupImages}/$fileName';

      // Compress and resize image
      final compressedImage = await _compressAndResizeImage(
        imageFile,
        500,
        500,
      );

      // Upload image
      final uploadTask = _storage.ref(imagePath).putData(compressedImage);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload group image: $e');
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      // File might not exist or already deleted
    }
  }

  // Compress image
  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Invalid image file');

      // Resize if too large
      final resized = img.copyResize(
        image,
        width: image.width > 1920 ? 1920 : null,
        height: image.height > 1920 ? 1920 : null,
      );

      // Compress JPEG with quality 85
      final compressedBytes = img.encodeJpg(resized, quality: 85);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  // Compress and resize image to specific dimensions
  Future<Uint8List> _compressAndResizeImage(
    File imageFile,
    int width,
    int height,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Invalid image file');

      final resized = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.linear,
      );

      final compressedBytes = img.encodeJpg(resized, quality: 90);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to compress and resize image: $e');
    }
  }

  // Generate image thumbnail
  Future<String> _generateImageThumbnail(
    Uint8List imageBytes,
    String chatId,
  ) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Invalid image');

      final thumbnail = img.copyResize(image, width: 200, height: 200);
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 60);

      final fileName = '${const Uuid().v4()}_thumb.jpg';
      final thumbnailPath =
          '${AppConstants.chatMedia}/$chatId/thumbnails/$fileName';

      final uploadTask = _storage
          .ref(thumbnailPath)
          .putData(Uint8List.fromList(thumbnailBytes));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return ''; // Return empty string if thumbnail generation fails
    }
  }

  // Generate video thumbnail
  Future<String> _generateVideoThumbnail(File videoFile, String chatId) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      // Seek to 1 second (or 10% of video duration)
      final duration = controller.value.duration;
      final seekPosition = Duration(seconds: duration.inSeconds > 10 ? 1 : 0);
      await controller.seekTo(seekPosition);

      // Note: This is a simplified version. In a real app, you'd use a
      // video_thumbnail package or similar to generate actual thumbnails
      await controller.dispose();

      // For now, return empty string. In production, implement proper thumbnail generation
      return '';
    } catch (e) {
      return '';
    }
  }

  // Get image metadata
  Future<Map<String, dynamic>> _getImageMetadata(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return {};

      return {'width': image.width, 'height': image.height, 'format': 'jpeg'};
    } catch (e) {
      return {};
    }
  }

  // Get video duration
  Future<int> _getVideoDuration(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (e) {
      return 0;
    }
  }

  // Get audio duration (placeholder - implement based on your audio library)
  Future<int> _getAudioDuration(File audioFile) async {
    try {
      // This is a placeholder. In a real app, you'd use an audio library
      // to get the actual duration of the audio file
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Check if file type is supported
  bool isSupportedImageType(String fileName) {
    final supportedTypes = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return supportedTypes.any((type) => fileName.toLowerCase().endsWith(type));
  }

  bool isSupportedVideoType(String fileName) {
    final supportedTypes = ['.mp4', '.mov', '.avi', '.mkv'];
    return supportedTypes.any((type) => fileName.toLowerCase().endsWith(type));
  }

  bool isSupportedAudioType(String fileName) {
    final supportedTypes = ['.mp3', '.wav', '.m4a', '.aac'];
    return supportedTypes.any((type) => fileName.toLowerCase().endsWith(type));
  }

  bool isSupportedDocumentType(String fileName) {
    final supportedTypes = ['.pdf', '.doc', '.docx', '.txt', '.rtf'];
    return supportedTypes.any((type) => fileName.toLowerCase().endsWith(type));
  }

  // Get file size in human readable format
  String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Format duration for display
  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Generic file upload method
  Future<MediaUploadResult> uploadFile({
    required File file,
    required String chatId,
    String? customFileName,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final fileName = customFileName ?? file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      // Determine upload method based on file type
      if ([
        'jpg',
        'jpeg',
        'png',
        'gif',
        'bmp',
        'webp',
      ].contains(fileExtension)) {
        return await uploadImage(imageFile: file, chatId: chatId);
      } else if ([
        'mp4',
        'avi',
        'mov',
        'wmv',
        'flv',
        '3gp',
      ].contains(fileExtension)) {
        return await uploadVideo(videoFile: file, chatId: chatId);
      } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(fileExtension)) {
        return await uploadAudio(audioFile: file, chatId: chatId);
      } else {
        return await uploadDocument(documentFile: file, chatId: chatId);
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
