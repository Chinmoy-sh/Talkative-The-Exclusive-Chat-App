import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum StatusType { text, image, video }

class StatusModel {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileUrl;
  final StatusType type;
  final String? content; // For text status
  final String? mediaUrl; // For image/video status
  final String? thumbnailUrl; // For video status
  final String? caption; // For media status
  final String? backgroundColor; // For text status
  final String? textColor; // For text status
  final String? fontFamily; // For text status
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final int viewCount;
  final bool isVisible;
  final List<String> allowedViewers; // For privacy settings
  final List<String> blockedViewers; // For privacy settings
  final Map<String, dynamic>? metadata;

  const StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileUrl,
    required this.type,
    this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.caption,
    this.backgroundColor,
    this.textColor,
    this.fontFamily,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.viewCount = 0,
    this.isVisible = true,
    this.allowedViewers = const [],
    this.blockedViewers = const [],
    this.metadata,
  });

  // Factory constructor for text status
  factory StatusModel.createTextStatus({
    required String userId,
    required String userName,
    String? userProfileUrl,
    required String content,
    required String backgroundColor,
    required String textColor,
    String? fontFamily,
  }) {
    final now = DateTime.now();
    return StatusModel(
      id: const Uuid().v4(),
      userId: userId,
      userName: userName,
      userProfileUrl: userProfileUrl,
      type: StatusType.text,
      content: content,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontFamily: fontFamily,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
  }

  // Factory constructor for media status
  factory StatusModel.createMediaStatus({
    required String userId,
    required String userName,
    String? userProfileUrl,
    required StatusType type,
    required String mediaUrl,
    String? thumbnailUrl,
    String? caption,
  }) {
    final now = DateTime.now();
    return StatusModel(
      id: const Uuid().v4(),
      userId: userId,
      userName: userName,
      userProfileUrl: userProfileUrl,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileUrl': userProfileUrl,
      'type': type.name,
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'fontFamily': fontFamily,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewedBy': viewedBy,
      'viewCount': viewCount,
      'isVisible': isVisible,
      'allowedViewers': allowedViewers,
      'blockedViewers': blockedViewers,
      'metadata': metadata,
    };
  }

  // Create from Firestore document
  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userProfileUrl: json['userProfileUrl'],
      type: StatusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StatusType.text,
      ),
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      caption: json['caption'],
      backgroundColor: json['backgroundColor'],
      textColor: json['textColor'],
      fontFamily: json['fontFamily'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      expiresAt: json['expiresAt'] is Timestamp
          ? (json['expiresAt'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(hours: 24)),
      viewedBy: List<String>.from(json['viewedBy'] ?? []),
      viewCount: json['viewCount'] ?? 0,
      isVisible: json['isVisible'] ?? true,
      allowedViewers: List<String>.from(json['allowedViewers'] ?? []),
      blockedViewers: List<String>.from(json['blockedViewers'] ?? []),
      metadata: json['metadata'],
    );
  }

  // CopyWith method for immutability
  StatusModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileUrl,
    StatusType? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    String? caption,
    String? backgroundColor,
    String? textColor,
    String? fontFamily,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewedBy,
    int? viewCount,
    bool? isVisible,
    List<String>? allowedViewers,
    List<String>? blockedViewers,
    Map<String, dynamic>? metadata,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileUrl: userProfileUrl ?? this.userProfileUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      fontFamily: fontFamily ?? this.fontFamily,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewedBy: viewedBy ?? this.viewedBy,
      viewCount: viewCount ?? this.viewCount,
      isVisible: isVisible ?? this.isVisible,
      allowedViewers: allowedViewers ?? this.allowedViewers,
      blockedViewers: blockedViewers ?? this.blockedViewers,
      metadata: metadata ?? this.metadata,
    );
  }

  // Utility methods
  bool get isTextStatus => type == StatusType.text;
  bool get isMediaStatus =>
      type == StatusType.image || type == StatusType.video;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get hasViewers => viewedBy.isNotEmpty;

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  String get timeRemainingText {
    final remaining = timeRemaining;
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m';
    } else if (remaining.inSeconds > 0) {
      return '${remaining.inSeconds}s';
    } else {
      return 'Expired';
    }
  }

  bool canViewerSee(String viewerId) {
    if (!isVisible) return false;
    if (blockedViewers.contains(viewerId)) return false;
    if (allowedViewers.isNotEmpty && !allowedViewers.contains(viewerId)) {
      return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatusModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StatusModel(id: $id, userId: $userId, type: $type, content: $content)';
  }
}
