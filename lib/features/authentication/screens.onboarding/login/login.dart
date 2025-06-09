import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/spacing_styles.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/password_configuration/forget_password.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/signup/signup.dart';
import 'package:flutterproject/navigation_menu.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/sizes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyles.paddingWithAppBarHeight,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image(
                      height: 150,
                      image: AssetImage(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo),
                    ),
                  ),
                  Text(AppTexts.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSizes.sm),
                  Text(AppTexts.loginSubTitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),

              Form(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
                child: Column(
                  children: [
                    //Email
                    TextFormField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Iconsax.direct_right, color: const Color(0xFF98FF98)),
                        labelText: AppTexts.email,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF98FF98), // Màu viền khi ô nhập liệu được kích hoạt
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwInputFields),
                    //Password
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Iconsax.password_check,color: const Color(0xFF98FF98)),
                        labelText: AppTexts.password,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF98FF98), // Màu viền khi ô nhập liệu được kích hoạt
                          ),
                        ),
                        suffixIcon: Icon(Iconsax.eye_slash,color:const Color(0xFF98FF98) ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwInputFields / 2),
                
                    //Remember Me and Forget Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(value: true, onChanged: (value){},activeColor: const Color(0xFF98FF98)),
                            const Text(AppTexts.rememberMe),
                          ],
                        ),
                
                        TextButton(onPressed: () => Get.to(() => const ForgetPassword()), child: const Text(AppTexts.forgetPassword)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSections),
                
                    SizedBox(width: double.infinity, child: ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:  Color(0xFF98FF98),foregroundColor: Colors.black,side: BorderSide(color: Colors.white, width: 0)) ,onPressed: () => Get.to(() => const NavigationMenu()), child: const Text(AppTexts.signIn))),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    SizedBox(width: double.infinity, child: OutlinedButton(style:OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF98FF98), width: 1)) ,onPressed: () => Get.to(() => const SignupScreen()), child: const Text(AppTexts.createAccount))),
                    ],
                  ),
              ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Divider(color: dark ? AppColors.darkGrey: AppColors.grey, thickness: 0.5, indent: 60, endIndent: 5)),
                  Text(AppTexts.orSignInWith.capitalize!, style: Theme.of(context).textTheme.labelMedium),
                  Flexible(child: Divider(color: dark ? AppColors.darkGrey: AppColors.grey, thickness: 0.5, indent: 6, endIndent: 60)),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: AppColors.grey),borderRadius: BorderRadius.circular(100)),
                    child: IconButton(
                      onPressed: (){}, 
                      icon: const Image(
                        width: AppSizes.iconMd,
                        height: AppSizes.iconMd,
                        image: AssetImage(AppImages.google),
                      )
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: AppColors.grey),borderRadius: BorderRadius.circular(100)),
                    child: IconButton(
                      onPressed: (){}, 
                      icon: const Image(
                        width: AppSizes.iconMd,
                        height: AppSizes.iconMd,
                        image: AssetImage(AppImages.facebook),
                      )
                    ),
                  ),
                ],
              )
            ],
          )
        )
      ),
    );
  }
}