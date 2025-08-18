import 'package:flutter/material.dart';
import '../pages/pages.dart';
import '../pages/profile/professional_settings_page.dart';
import 'app_routes.dart';
import 'route_animations.dart';

/// Professional Route Generator
///
/// Handles all route generation with proper error handling,
/// animations, and route guards following Flutter best practices.
class RouteGenerator {
  /// Generate routes with professional error handling
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '';
    final Object? arguments = settings.arguments;

    // Validate route exists
    if (!AppRoutes.isValidRoute(routeName) && routeName != '/') {
      return _buildErrorRoute(routeName);
    }

    try {
      return _getRouteForName(routeName, arguments);
    } catch (e) {
      debugPrint('Route generation error for $routeName: $e');
      return _buildErrorRoute(routeName);
    }
  }

  /// Map route names to pages
  static Route<dynamic> _getRouteForName(String routeName, Object? arguments) {
    switch (routeName) {
      // Authentication Routes
      case AppRoutes.splash: // This is '/' - splash route
        return RouteAnimations.slideRoute(
          const AuthWrapper(),
          settings: RouteSettings(name: routeName),
        );

      case AppRoutes.authWrapper:
        return RouteAnimations.fadeRoute(
          const AuthWrapper(),
          settings: RouteSettings(name: routeName),
        );

      // Home Routes
      case AppRoutes.home:
        return RouteAnimations.fadeRoute(
          const MainHomePage(),
          settings: RouteSettings(name: routeName),
        );

      case AppRoutes.dashboard:
        return RouteAnimations.slideRoute(
          const DashboardPage(),
          settings: RouteSettings(name: routeName),
        );

      // Profile Routes
      case AppRoutes.profile:
        return RouteAnimations.slideRoute(
          // TODO: Import actual ProfilePage from presentation/pages/profile/
          // For now, using a placeholder - replace with: const ProfilePage()
          const Scaffold(
            body: Center(child: Text('Profile Page - Under Development')),
          ),
          settings: RouteSettings(name: routeName),
        );

      case AppRoutes.settings:
        return RouteAnimations.slideRoute(
          const SettingsPage(),
          settings: RouteSettings(name: routeName),
        );

      case AppRoutes.about:
        return RouteAnimations.slideRoute(
          // TODO: Import actual AboutPage when created
          // For now, using a placeholder - replace with: const AboutPage()
          const Scaffold(
            body: Center(child: Text('About Page - Under Development')),
          ),
          settings: RouteSettings(name: routeName),
        );

      // Communication Routes
      case AppRoutes.messenger:
        return RouteAnimations.slideRoute(
          // TODO: Import actual MessengerPage from communication pages
          // For now, using a placeholder - replace with: const MessengerPage()
          const Scaffold(
            body: Center(child: Text('Messenger Page - Under Development')),
          ),
          settings: RouteSettings(name: routeName),
        );

      case AppRoutes.chat:
        return RouteAnimations.slideRoute(
          // TODO: Import actual ChatPage from communication pages
          // For now, using a placeholder - replace with: const ChatPage()
          const Scaffold(
            body: Center(child: Text('Chat Page - Under Development')),
          ),
          settings: RouteSettings(name: routeName),
        );

      // Default case - should not reach here for valid routes
      default:
        return _buildErrorRoute(routeName);
    }
  }

  /// Build professional error route
  static Route<dynamic> _buildErrorRoute(String routeName) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Route Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The route "$routeName" does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
      settings: RouteSettings(name: '/error'),
    );
  }

  /// Get initial route based on authentication state
  static String getInitialRoute() {
    // TODO: Check authentication state
    // For now, return auth wrapper
    return AppRoutes.authWrapper;
  }

  /// Log route navigation for analytics
  static void logRouteNavigation(String routeName) {
    final category = AppRoutes.getRouteCategory(routeName);
    debugPrint('Navigation: $routeName (Category: $category)');

    // TODO: Send to analytics service
    // AnalyticsService.trackScreenView(routeName, category);
  }
}
