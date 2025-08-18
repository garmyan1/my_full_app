import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'firebase_options.dart'; // Required for Firebase initialization
import 'config/mapbox_config.dart';

import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/home/main_home_page.dart';
import 'screens/onboarding/onboarding_page.dart';
import 'data/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Mapbox with access token
  MapboxOptions.setAccessToken(MapboxConfig.accessToken);

  runApp(const GoldenPrizmaApp());
}

class GoldenPrizmaApp extends StatelessWidget {
  const GoldenPrizmaApp({super.key});

  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;

    if (seen) {
      // Show main home page directly - TikTok style login system
      return const MainHomePage();
    } else {
      return const OnboardingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeService>(
      future: ThemeService.getInstance(),
      builder: (context, themeSnapshot) {
        if (!themeSnapshot.hasData) {
          // Show loading while theme service initializes
          return MaterialApp(
            home: const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            ),
            debugShowCheckedModeBanner: false,
          );
        }

        final themeService = themeSnapshot.data!;
        return AnimatedBuilder(
          animation: themeService,
          builder: (context, child) {
            return MaterialApp(
              title: 'GoldenPrizma',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.deepPurple,
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              darkTheme: ThemeData(
                primarySwatch: Colors.deepPurple,
                useMaterial3: true,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.grey[900],
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.grey[900],
                  foregroundColor: Colors.white,
                ),
              ),
              themeMode: themeService.themeMode,
              home: FutureBuilder<Widget>(
                future: _getInitialPage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.data!;
                  } else {
                    return const Scaffold(
                      backgroundColor: Colors.black,
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
              routes: {
                '/home': (context) => const MainHomePage(),
              },
            );
          },
        );
      },
    );
  }
}
