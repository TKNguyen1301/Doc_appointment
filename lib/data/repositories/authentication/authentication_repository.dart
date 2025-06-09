import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/login/login.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/onboarding.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  //Variables 
  final deviceStorage = GetStorage();
  //Called from main.dart on app lauch
  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  screenRedirect() async {
    // Local Storage
    deviceStorage.writeIfNull('IsFirstTime', true);
    deviceStorage.read('IsFirstTime') != true 
      ? Get.offAll(() => const LoginScreen()) 
      : Get.offAll(const OnboardingScreen());
  }


}
