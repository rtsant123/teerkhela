import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';
import 'providers/predictions_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/predictions_screen_full.dart';
import 'screens/dream_screen_full.dart';
import 'screens/subscribe_screen_full.dart';
import 'screens/profile_screen_full.dart';
import 'screens/game_history_screen.dart';
import 'screens/common_numbers_screen.dart';
import 'screens/formula_calculator_screen.dart';
import 'screens/community_forum_simple.dart';
import 'screens/create_forum_post_screen.dart';
import 'screens/accuracy_stats_screen.dart';
import 'screens/hit_numbers_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional - will skip if not configured)
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️  Firebase not configured - Push notifications disabled');
    print('   Add google-services.json to enable notifications');
  }

  // Initialize Storage
  await StorageService.init();

  // Initialize Notifications (will handle Firebase not being available)
  try {
    await NotificationService.initialize();
  } catch (e) {
    print('⚠️  Notification service not available');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PredictionsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Teer Khela',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              primarySwatch: Colors.cyan,
              primaryColor: AppTheme.primary,
              scaffoldBackgroundColor: AppTheme.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppTheme.primary,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textTheme: GoogleFonts.poppinsTextTheme(),
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.cyan,
              ).copyWith(
                secondary: AppTheme.secondary,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: AppTheme.surface,
              ),
            ),
            darkTheme: AppTheme.darkTheme(),
            home: const AppInitializer(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const HomeScreen(),
              '/predictions': (context) => const PredictionsScreen(),
              '/dream': (context) => const DreamScreen(),
              '/subscribe': (context) => const SubscribeScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/game-history': (context) => const GameHistoryScreen(),
              '/common-numbers': (context) => const CommonNumbersScreen(),
              '/formula-calculator': (context) => const FormulaCalculatorScreen(),
              '/community-forum': (context) => const SimpleCommunityForum(),
              '/create-forum-post': (context) => const CreateForumPostScreen(),
              '/accuracy-stats': (context) => const AccuracyStatsScreen(),
              '/hit-numbers': (context) => const HitNumbersScreen(),
            },
          );
        },
      ),
    );
  }
}

// App Initializer - Device-based access (no login required)
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash duration

    if (!mounted) return;

    // Check if user has seen onboarding
    final hasSeenOnboarding = StorageService.getOnboardingComplete();

    // Generate device ID if not exists (for premium tracking)
    String? deviceId = StorageService.getDeviceId();
    if (deviceId == null) {
      deviceId = await _getDeviceId();
      await StorageService.setDeviceId(deviceId);
    }

    // Initialize user with device ID (no login needed)
    if (mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.initializeWithDeviceId(deviceId);

      // Navigate based on onboarding status
      if (!hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Unique Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
