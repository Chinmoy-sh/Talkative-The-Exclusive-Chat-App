import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/phone_verification_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/chat/screens/chat_home_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/contacts/screens/contacts_screen.dart';
import '../../features/groups/screens/group_creation_screen.dart';
import '../../features/groups/screens/group_info_screen.dart';
import '../../features/calls/screens/call_screen.dart';
import '../../features/status/screens/status_screen.dart';
import '../../shared/models/chat_model.dart';
import '../../shared/widgets/error_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String phoneVerification = '/phone-verification';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String contacts = '/contacts';
  static const String groupCreation = '/group-creation';
  static const String groupInfo = '/group-info';
  static const String call = '/call';
  static const String status = '/status';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case login:
        return _buildRoute(const LoginScreen(), settings);

      case signup:
        return _buildRoute(const SignupScreen(), settings);

      case phoneVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          PhoneVerificationScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            verificationId: args?['verificationId'] ?? '',
          ),
          settings,
        );

      case profileSetup:
        return _buildRoute(const ProfileSetupScreen(), settings);

      case home:
        return _buildRoute(const ChatHomeScreen(), settings);

      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ChatScreen(
            chat: args?['chat'] as ChatModel,
            otherUserId: args?['otherUserId'] as String?,
          ),
          settings,
        );

      case profile:
        return _buildRoute(const ProfileScreen(), settings);

      case AppRouter.settings:
        return _buildRoute(const SettingsScreen(), settings);

      case contacts:
        return _buildRoute(const ContactsScreen(), settings);

      case groupCreation:
        return _buildRoute(const GroupCreationScreen(), settings);

      case groupInfo:
        return _buildRoute(const GroupInfoScreen(), settings);

      case call:
        return _buildRoute(const CallScreen(), settings);

      case status:
        return _buildRoute(const StatusScreen(), settings);

      default:
        return _buildRoute(
          ErrorScreen(
            message: 'Route "${settings.name}" not found',
            onRetry: null,
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // Navigation helper methods
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(
      context,
    ).pushReplacementNamed<T, Object?>(routeName, arguments: arguments);
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

// Global Navigator Key for accessing navigation from anywhere in the app
class NavigatorKey {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get currentState => navigatorKey.currentState;

  static BuildContext? get currentContext => navigatorKey.currentContext;
}
