import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../pages/home/main_home_page.dart';

/// TikTok-Style Authentication Wrapper
///
/// Shows the main home page directly with TikTok-style login modal
/// that appears when users try to access restricted features.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Return MainHomePage directly - TikTok style login system
    // Users will see the home screen and get login modal when needed
    return const MainHomePage();
  }
}
