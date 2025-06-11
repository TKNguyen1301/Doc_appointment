import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/login/login.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/onboarding.dart';
import 'package:flutterproject/navigation_menu.dart';
import 'package:flutterproject/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientController(),
      child: GetMaterialApp(
        themeMode: ThemeMode.system,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isFirstTime = true;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndFirstTime();
  }

  Future<void> _checkAuthAndFirstTime() async {
    final patientController = Provider.of<PatientController>(context, listen: false);
    
    // Check if user has seen onboarding before
    // You can use SharedPreferences to store this info
    // For now, assuming it's always first time
    
    // Check authentication
    final isAuth = await patientController.isAuthenticated();
    
    setState(() {
      _isAuthenticated = isAuth;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If first time, show onboarding
    if (_isFirstTime) {
      return const OnboardingScreen();
    }

    // If authenticated, show main app
    if (_isAuthenticated) {
      return const NavigationMenu();
    }

    // If not authenticated, show login
    return const LoginScreen();
  }
}