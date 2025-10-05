import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../constants/app_constants.dart';
import '../../shared/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Box _userBox = Hive.box(AppConstants.userBox);

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  bool get isSignedIn => _auth.currentUser != null;

  // Email & Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        await _updateUserPresence(true);
        await _cacheUserData(result.user!);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  // Email & Password Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);

        // Create user document in Firestore
        await _createUserDocument(
          result.user!,
          name: name,
          email: email.trim(),
        );

        await _cacheUserData(result.user!);
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled sign in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      if (result.user != null) {
        // Check if user document exists, create if not
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(result.user!.uid)
            .get();

        if (!userDoc.exists) {
          await _createUserDocument(
            result.user!,
            name: result.user!.displayName ?? 'User',
            email: result.user!.email ?? '',
          );
        }

        await _updateUserPresence(true);
        await _cacheUserData(result.user!);
      }

      return result;
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // Phone Number Authentication - Send OTP
  Future<String> sendPhoneVerificationCode({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
  }) async {
    String verificationId = '';

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification (Android only)
        await _signInWithPhoneCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(_handleAuthException(e));
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        onCodeSent(verId);
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
      timeout: const Duration(seconds: 60),
    );

    return verificationId;
  }

  // Phone Number Authentication - Verify OTP
  Future<UserCredential?> verifyPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await _signInWithPhoneCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Phone verification failed');
    }
  }

  // Sign In with Phone Credential
  Future<UserCredential> _signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    final UserCredential result = await _auth.signInWithCredential(credential);

    if (result.user != null) {
      // Check if user document exists, create if not
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _createUserDocument(
          result.user!,
          name: result.user!.displayName ?? 'User',
          email: result.user!.email ?? '',
          phoneNumber: result.user!.phoneNumber ?? '',
        );
      }

      await _updateUserPresence(true);
      await _cacheUserData(result.user!);
    }

    return result;
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _updateUserPresence(false);
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _clearCachedUserData();
    } catch (e) {
      throw Exception('Sign out failed');
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _deleteUserData(user.uid);

        // Delete user account
        await user.delete();

        await _clearCachedUserData();
      }
    } catch (e) {
      throw Exception('Failed to delete account');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email');
    }
  }

  // Update Email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail.trim());
        await _updateUserDocumentField(user.uid, 'email', newEmail.trim());
      }
    } catch (e) {
      throw Exception('Failed to update email');
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw Exception('Failed to update password');
    }
  }

  // Re-authenticate user
  Future<void> reAuthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Re-authentication failed');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    required String name,
    required String email,
    String phoneNumber = '',
  }) async {
    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      profileImageUrl: user.photoURL ?? '',
      bio: 'Hey there! I\'m using Talkative.',
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(userModel.toJson());
  }

  // Update user presence
  Future<void> _updateUserPresence(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
            'isOnline': isOnline,
            'lastSeen': FieldValue.serverTimestamp(),
          });
    }
  }

  // Update user document field
  Future<void> _updateUserDocumentField(
    String uid,
    String field,
    dynamic value,
  ) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete user data
  Future<void> _deleteUserData(String uid) async {
    // Delete user document
    await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();

    // Delete user's chats, messages, etc. (implement based on requirements)
  }

  // Cache user data locally
  Future<void> _cacheUserData(User user) async {
    await _userBox.put('uid', user.uid);
    await _userBox.put('email', user.email);
    await _userBox.put('displayName', user.displayName);
    await _userBox.put('photoURL', user.photoURL);
    await _userBox.put('phoneNumber', user.phoneNumber);
  }

  // Clear cached user data
  Future<void> _clearCachedUserData() async {
    await _userBox.clear();
  }

  // Get cached user data
  Map<String, dynamic> getCachedUserData() {
    return {
      'uid': _userBox.get('uid'),
      'email': _userBox.get('email'),
      'displayName': _userBox.get('displayName'),
      'photoURL': _userBox.get('photoURL'),
      'phoneNumber': _userBox.get('phoneNumber'),
    };
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Stream to listen to user changes
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserModel.fromJson(doc.data()!);
          }
          return null;
        });
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    }
    return null;
  }
}
