import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/RedoV0.5.dart';
import 'theme/theme.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BattleDex',
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.selected,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.selected,
          secondary: AppColors.highlight,
          background: AppColors.background,
          surface: AppColors.card,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
      ),
    );
  }
}
