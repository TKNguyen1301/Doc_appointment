import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/device/device_utility.dart';
//import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';


class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
//    final dark = AppHelperFunctions.isDarkMode(context);
    return Positioned(
      right: AppSizes.defaultSpace,
      bottom: AppDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(shape: const CircleBorder(),side: BorderSide(color: Color(0xFF98FF98),width: 1) , backgroundColor: AppColors.primary),
        child: const Icon(Iconsax.arrow_right_3)));
  }
}