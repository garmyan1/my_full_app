import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_routes.dart';

/// Professional Route Guards
///
/// Handles route protection, authentication checks, and permission validation
/// following Flutter and Firebase security best practices.
class RouteGuards {
  /// Check if user is authenticated
  static bool get isAuthenticated {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Check if route requires authentication
  static bool requiresAuth(String routeName) {
    const List<String> publicRoutes = [
      AppRoutes.authWrapper,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.splash,
      '/',
    ];

    return !publicRoutes.contains(routeName);
  }

  /// Check if user can access route
  static bool canAccessRoute(String routeName) {
    // If route doesn't require auth, allow access
    if (!requiresAuth(routeName)) {
      return true;
    }

    // If route requires auth, check if user is authenticated
    return isAuthenticated;
  }

  /// Get redirect route for unauthorized access
  static String getRedirectRoute(String attemptedRoute) {
    if (!isAuthenticated && requiresAuth(attemptedRoute)) {
      // Redirect to home instead of login - TikTok style
      return AppRoutes.home;
    }

    return attemptedRoute;
  }

  /// Validate route access and return appropriate route
  static String validateRouteAccess(String routeName) {
    if (!canAccessRoute(routeName)) {
      debugPrint('Access denied to route: $routeName, redirecting to login');
      return getRedirectRoute(routeName);
    }

    return routeName;
  }

  /// Check if user has specific permission (for future use)
  static bool hasPermission(String permission) {
    // TODO: Implement permission checking
    // This would check user roles, subscription status, etc.
    return true;
  }

  /// Check if user has admin access
  static bool get isAdmin {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // TODO: Check admin claims or user document
    // This would typically check custom claims or Firestore user document
    return false;
  }

  /// Check if user has premium subscription
  static bool get isPremium {
    // TODO: Check subscription status
    // This would check Firestore subscription document or custom claims
    return false;
  }
}

/// Route Guard Middleware
///
/// Extension methods for easier route guard integration
extension RouteGuardExtensions on String {
  /// Check if this route requires authentication
  bool get requiresAuth => RouteGuards.requiresAuth(this);

  /// Check if current user can access this route
  bool get canAccess => RouteGuards.canAccessRoute(this);

  /// Get validated route (with redirects if needed)
  String get validated => RouteGuards.validateRouteAccess(this);
}
