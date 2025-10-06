import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String bio;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // online, offline, away, busy
  final Map<String, dynamic> settings;
  final List<String> blockedUsers;
  final String fcmToken;
  final String language;
  final String theme;
  final bool isVerified;
  final Map<String, dynamic> privacy;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.profileImageUrl = '',
    this.bio = '',
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'offline',
    this.settings = const {},
    this.blockedUsers = const [],
    this.fcmToken = '',
    this.language = 'en',
    this.theme = 'system',
    this.isVerified = false,
    this.privacy = const {},
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
      'settings': settings,
      'blockedUsers': blockedUsers,
      'fcmToken': fcmToken,
      'language': language,
      'theme': theme,
      'isVerified': isVerified,
      'privacy': privacy,
    };
  }

  // Create from JSON from Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: (json['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status'] ?? 'offline',
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      fcmToken: json['fcmToken'] ?? '',
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      isVerified: json['isVerified'] ?? false,
      privacy: Map<String, dynamic>.from(json['privacy'] ?? {}),
    );
  }

  // Copy with method for updating fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    Map<String, dynamic>? settings,
    List<String>? blockedUsers,
    String? fcmToken,
    String? language,
    String? theme,
    bool? isVerified,
    Map<String, dynamic>? privacy,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      fcmToken: fcmToken ?? this.fcmToken,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      isVerified: isVerified ?? this.isVerified,
      privacy: privacy ?? this.privacy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, isOnline: $isOnline)';
  }

  // Helper methods
  String get displayName => name.isNotEmpty ? name : email;

  bool get hasProfileImage => profileImageUrl.isNotEmpty;

  String get initials {
    if (name.isNotEmpty) {
      final names = name.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0].toUpperCase()}${names[1][0].toUpperCase()}';
      } else if (names.isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  String get lastSeenText {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (isOnline) return 'Online';

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'Long time ago';
    }
  }
}
