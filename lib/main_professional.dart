import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import professional architecture
import 'core/core.dart';
import 'data/services/theme_service.dart';
import 'presentation/pages/professional_login_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/home/main_home_page.dart';
import 'screens/onboarding/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GoldenPrizmaApp());
}

class GoldenPrizmaApp extends StatefulWidget {
  const GoldenPrizmaApp({super.key});

  @override
  State<GoldenPrizmaApp> createState() => _GoldenPrizmaAppState();
}

class _GoldenPrizmaAppState extends State<GoldenPrizmaApp> {
  late ThemeService _themeService;
  bool _isThemeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    _themeService = await ThemeService.getInstance();
    setState(() {
      _isThemeInitialized = true;
    });
  }

  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;

    if (seen) {
      // Show main home page directly - TikTok style
      return const MainHomePage();
    } else {
      return const OnboardingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isThemeInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _themeService,
      builder: (context, child) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,

          // Use theme service for dynamic theming
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeService.themeMode,

          home: FutureBuilder<Widget>(
            future: _getInitialPage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.data!;
              } else {
                return Scaffold(
                  backgroundColor: AppColors.background,
                  body: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
            },
          ),

          // Define routes using professional architecture
          routes: {
            '/login': (context) => const ProfessionalLoginPage(),
            '/old-login': (context) =>
                const LoginPage(), // Keep old login for comparison
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const MainHomePage(),
            '/onboarding': (context) => const OnboardingPage(),
          },
        );
      },
    );
  }
}

/// Example of how to use professional architecture in existing screens
class ExampleIntegration {
  // Example: Using professional constants in existing screens
  static Widget buildAppBar() {
    return AppBar(
      title: Text(
        AppStrings.appName,
        style: AppTextStyles.headlineMedium,
      ),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
    );
  }

  // Example: Using professional validation
  static String? validateEmail(String? value) {
    return Validators.email(value);
  }

  // Example: Using professional colors
  static Widget buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
      ),
      child: Text(text, style: AppTextStyles.buttonMedium),
    );
  }

  // Example: Using professional dimensions
  static Widget buildContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      margin: const EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: child,
    );
  }
}
