import 'package:flutter/material.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key, required this.image, required this.title, required this.subTitle,
  });

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo trục dọc
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo trục ngang
          children: [
            Image(
              width: AppHelperFunctions.screenWidth() * 0.8,
              height: AppHelperFunctions.screenHeight() * 0.6,
              image: AssetImage(image)
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Text(
              subTitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}