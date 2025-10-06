import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../constants/app_constants.dart';
import '../../shared/models/status_model.dart';
import 'media_service.dart';

final statusServiceProvider = Provider<StatusService>((ref) {
  return StatusService();
});

final statusStreamProvider = StreamProvider<List<StatusModel>>((ref) {
  final statusService = ref.watch(statusServiceProvider);
  return statusService.getStatusUpdates();
});

final myStatusStreamProvider = StreamProvider<List<StatusModel>>((ref) {
  final statusService = ref.watch(statusServiceProvider);
  return statusService.getMyStatus();
});

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Get all status updates from contacts
  Stream<List<StatusModel>> getStatusUpdates() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.statusCollection)
        .where('isVisible', isEqualTo: true)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StatusModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Get current user's status updates
  Stream<List<StatusModel>> getMyStatus() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.statusCollection)
        .where('userId', isEqualTo: _currentUserId)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StatusModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Create text status
  Future<StatusModel> createTextStatus({
    required String content,
    required String backgroundColor,
    required String textColor,
    String? fontFamily,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final currentUser = _auth.currentUser!;

    final status = StatusModel.createTextStatus(
      userId: _currentUserId!,
      userName: currentUser.displayName ?? 'Unknown',
      userProfileUrl: currentUser.photoURL,
      content: content,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontFamily: fontFamily,
    );

    await _firestore
        .collection(AppConstants.statusCollection)
        .doc(status.id)
        .set(status.toJson());

    return status;
  }

  // Create media status (image/video)
  Future<StatusModel> createMediaStatus({
    required File mediaFile,
    required StatusType type,
    String? caption,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final currentUser = _auth.currentUser!;

    // Upload media to Firebase Storage
    final mediaUploadResult = await MediaService().uploadFile(
      file: mediaFile,
      chatId: 'status_media_$_currentUserId',
    );

    final status = StatusModel.createMediaStatus(
      userId: _currentUserId!,
      userName: currentUser.displayName ?? 'Unknown',
      userProfileUrl: currentUser.photoURL,
      type: type,
      mediaUrl: mediaUploadResult.downloadUrl,
      caption: caption,
    );

    await _firestore
        .collection(AppConstants.statusCollection)
        .doc(status.id)
        .set(status.toJson());

    return status;
  }

  // View status (increment view count)
  Future<void> viewStatus(String statusId, String viewerId) async {
    final statusRef = _firestore
        .collection(AppConstants.statusCollection)
        .doc(statusId);

    await _firestore.runTransaction((transaction) async {
      final statusDoc = await transaction.get(statusRef);

      if (statusDoc.exists) {
        final status = StatusModel.fromJson(statusDoc.data()!);

        // Don't count views from the status owner
        if (status.userId != viewerId) {
          final updatedViewers = List<String>.from(status.viewedBy);
          if (!updatedViewers.contains(viewerId)) {
            updatedViewers.add(viewerId);

            transaction.update(statusRef, {
              'viewedBy': updatedViewers,
              'viewCount': updatedViewers.length,
            });
          }
        }
      }
    });
  }

  // Delete status
  Future<void> deleteStatus(String statusId) async {
    await _firestore
        .collection(AppConstants.statusCollection)
        .doc(statusId)
        .delete();
  }

  // Get status viewers
  Future<List<Map<String, dynamic>>> getStatusViewers(String statusId) async {
    final statusDoc = await _firestore
        .collection(AppConstants.statusCollection)
        .doc(statusId)
        .get();

    if (!statusDoc.exists) return [];

    final status = StatusModel.fromJson(statusDoc.data()!);
    final viewers = <Map<String, dynamic>>[];

    for (final viewerId in status.viewedBy) {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(viewerId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        viewers.add({
          'userId': viewerId,
          'name': userData['name'] ?? 'Unknown',
          'profileUrl': userData['profileImageUrl'],
          'viewedAt':
              DateTime.now(), // You might want to store actual view time
        });
      }
    }

    return viewers;
  }

  // Update status privacy settings
  Future<void> updateStatusPrivacy({
    required String statusId,
    required bool isVisible,
    List<String>? allowedViewers,
    List<String>? blockedViewers,
  }) async {
    final updateData = <String, dynamic>{'isVisible': isVisible};

    if (allowedViewers != null) {
      updateData['allowedViewers'] = allowedViewers;
    }

    if (blockedViewers != null) {
      updateData['blockedViewers'] = blockedViewers;
    }

    await _firestore
        .collection(AppConstants.statusCollection)
        .doc(statusId)
        .update(updateData);
  }

  // Clean up expired status (call this periodically)
  Future<void> cleanupExpiredStatus() async {
    final expiredStatus = await _firestore
        .collection(AppConstants.statusCollection)
        .where('expiresAt', isLessThan: Timestamp.now())
        .get();

    final batch = _firestore.batch();

    for (final doc in expiredStatus.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Get status by user
  Stream<List<StatusModel>> getUserStatus(String userId) {
    return _firestore
        .collection(AppConstants.statusCollection)
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StatusModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Report status
  Future<void> reportStatus({
    required String statusId,
    required String reporterId,
    required String reason,
  }) async {
    await _firestore.collection('reports').doc().set({
      'type': 'status',
      'contentId': statusId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': Timestamp.now(),
      'status': 'pending',
    });
  }

  // Mute status updates from user
  Future<void> muteStatusUpdates(String userId) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(_currentUserId)
        .update({
          'mutedStatusUsers': FieldValue.arrayUnion([userId]),
        });
  }

  // Unmute status updates from user
  Future<void> unmuteStatusUpdates(String userId) async {
    if (_currentUserId == null) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(_currentUserId)
        .update({
          'mutedStatusUsers': FieldValue.arrayRemove([userId]),
        });
  }
}
