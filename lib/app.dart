import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/onboarding.dart';
import 'package:get/get.dart';
import 'package:flutterproject/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}