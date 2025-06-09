import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/device/device_utility.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppDeviceUtils.getAppBarHeight(), 
      right: AppSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnboardingController.instance.skipPage(), 
        child: const Text('Skip'),));
  }
}