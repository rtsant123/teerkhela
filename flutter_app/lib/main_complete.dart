import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';
import 'providers/results_provider.dart';
import 'providers/predictions_provider.dart';

// Import all screens (use _full versions)
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/predictions_screen_full.dart';
import 'screens/dream_screen_full.dart';
import 'screens/subscribe_screen_full.dart';
import 'screens/profile_screen_full.dart';
import 'screens/result_detail_screen.dart';
import 'screens/common_numbers_screen.dart';
import 'screens/formula_calculator_screen.dart';
import 'screens/manage_subscription_screen.dart';

// Global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Storage
  await StorageService.init();

  // Initialize Notifications
  await NotificationService.initialize();

  // Set notification tap handler
  NotificationService.onNotificationTap = (screen) {
    // Navigate based on screen parameter from notification
    print('Notification tapped, navigating to: $screen');
    navigatorKey.currentState?.pushNamed('/$screen');
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ResultsProvider()),
        ChangeNotifierProvider(create: (_) => PredictionsProvider()),
      ],
      child: MaterialApp(
        title: 'Teer Khela',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // Add navigator key
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: const Color(0xFF7c3aed),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF7c3aed),
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
            primarySwatch: Colors.purple,
          ).copyWith(
            secondary: const Color(0xFFa78bfa),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7c3aed),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/predictions': (context) => const PredictionsScreen(),
          '/dream': (context) => const DreamScreen(),
          '/subscribe': (context) => const SubscribeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/common-numbers': (context) => const CommonNumbersScreen(),
          '/formula-calculator': (context) => const FormulaCalculatorScreen(),
          '/manage-subscription': (context) => const ManageSubscriptionScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes with parameters
          if (settings.name?.startsWith('/result-detail/') == true) {
            final game = settings.name!.split('/').last;
            return MaterialPageRoute(
              builder: (context) => ResultDetailScreen(game: game),
            );
          }
          return null;
        },
      ),
    );
  }
}
