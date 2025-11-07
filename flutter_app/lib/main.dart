import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/predictions_screen_full.dart';
import 'screens/dream_screen_full.dart';
import 'screens/subscribe_screen_full.dart';
import 'screens/profile_screen_full.dart';
import 'screens/game_history_screen.dart';
import 'screens/common_numbers_screen.dart';

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
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Teer Khela',
        debugShowCheckedModeBanner: false,
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
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/predictions': (context) => const PredictionsScreen(),
          '/dream': (context) => const DreamScreen(),
          '/subscribe': (context) => const SubscribeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/game-history': (context) => const GameHistoryScreen(),
          '/common-numbers': (context) => const CommonNumbersScreen(),
        },
      ),
    );
  }
}
