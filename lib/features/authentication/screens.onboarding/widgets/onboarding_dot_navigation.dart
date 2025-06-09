import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/device/device_utility.dart';
//import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
  //  final dark = AppHelperFunctions.isDarkMode(context);

    return Positioned(
      bottom: AppDeviceUtils.getBottomNavigationBarHeight() +25 ,
      left : AppSizes.defaultSpace,
      child: 
        SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick, 
        count : 3,
        effect: ExpandingDotsEffect(
          activeDotColor: AppColors.primary,
          dotHeight: 6),),
    );
  }
}
