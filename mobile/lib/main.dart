import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aqua_sense/screens/splash_screen.dart';
import 'package:aqua_sense/screens/onboarding_screen.dart';
import 'package:aqua_sense/screens/login_screen.dart';
import 'package:aqua_sense/screens/signup_screen.dart';
import 'package:aqua_sense/screens/home_screen.dart';
import 'package:aqua_sense/screens/water_reservoirs_screen.dart';
import 'package:aqua_sense/screens/water_transactions_screen.dart';
import 'package:aqua_sense/screens/weather_screen.dart';
import 'package:aqua_sense/screens/faq_screen.dart';
import 'package:aqua_sense/screens/reservoir_details_screen.dart';
import 'package:aqua_sense/screens/plants_screen.dart';
import 'package:aqua_sense/screens/plant_details_screen.dart';
import 'package:aqua_sense/screens/profile_screen.dart';
import 'package:aqua_sense/screens/settings_screen.dart';
import 'package:aqua_sense/screens/notifications_screen.dart';
import 'package:aqua_sense/screens/soil_monitoring_screen.dart';
import 'package:aqua_sense/screens/dashboard_screen.dart';
import 'package:aqua_sense/screens/add_soil_data_screen.dart';
import 'package:aqua_sense/screens/edit_profile_screen.dart';
import 'package:aqua_sense/screens/add_plant_screen.dart';
import 'package:aqua_sense/services/auth_service.dart';
import 'package:aqua_sense/utils/app_theme.dart';
import 'package:aqua_sense/utils/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'AquaSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/water_reservoirs': (context) => const WaterReservoirsScreen(),
        '/water_transactions': (context) => const WaterTransactionsScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/faq': (context) => const FAQScreen(),
        '/reservoir_details': (context) => const ReservoirDetailsScreen(),
        '/plants': (context) => const PlantsScreen(),
        '/plant_details': (context) => const PlantDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/soil_monitoring': (context) => const SoilMonitoringScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add_soil_data': (context) => const AddSoilDataScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/add_plant': (context) => const AddPlantScreen(),
      },
    );
  }
}

