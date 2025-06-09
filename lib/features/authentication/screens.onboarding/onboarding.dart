import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/widgets/onboarding_next_button.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/widgets/onboarding_page.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/widgets/onboarding_skip.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: AppImages.onBoardingImage1,
                title: AppTexts.onBoardingTitle1,
                subTitle: AppTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: AppImages.onBoardingImage2,
                title: AppTexts.onBoardingTitle2,
                subTitle: AppTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: AppImages.onBoardingImage3,
                title: AppTexts.onBoardingTitle3,
                subTitle: AppTexts.onBoardingSubTitle3,
              ),
            ],
          ),
          const OnBoardingSkip(),

          const OnBoardingDotNavigation(),
          
          const OnBoardingNextButton()
        ],
      ),
    );
  }
}


