import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/pages/main_page.dart';
import 'core/constants/app_constants.dart';
import 'core/services/theme_service.dart';

final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences first for web compatibility
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('Error initializing SharedPreferences: $e');
  }
  
  // Then initialize theme
  try {
    await ThemeService.initializeTheme();
  } catch (e) {
    // If theme initialization fails, continue with default theme
    debugPrint('Error initializing theme: $e');
  }
  
  runApp(MyApp(key: appKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.setAppKey(appKey);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'GB'), // Use GB locale so week starts on Monday, but keep English text
      localeResolutionCallback: (locales, supportedLocales) {
        return const Locale('en', 'GB');
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'GB'), // English (UK) - week starts on Monday
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: ThemeService.fontFamily,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: ThemeService.fontFamily,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeService.currentTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // For now, just return MainPage for all routes
        // In the future, you can add a proper routes map here
        return MaterialPageRoute(
          builder: (context) => const MainPage(),
          settings: const RouteSettings(name: '/'),
        );
      },
    );
  }
}
