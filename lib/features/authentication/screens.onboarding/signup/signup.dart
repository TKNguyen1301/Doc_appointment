import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/signup/verify_email.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iconsax/iconsax.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return  Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child:  Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppTexts.signupTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSizes.spaceBtwSections),

              //Form
              Form(
                child: Column(
                  children: [
                    Row(
                      children: [
                        //First, Last Name
                        Expanded(
                          child: TextFormField(
                            expands: false,
                            decoration: const  InputDecoration(labelText: AppTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceBtwInputFields),
                        Expanded(
                          child: TextFormField(
                            expands: false,
                            decoration: const  InputDecoration(labelText: AppTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                          ),
                        ),
                      ],
                    ),
                    // Username
                    const SizedBox(height: AppSizes.spaceBtwInputFields),
                    TextFormField(
                      expands: false,
                      decoration: const  InputDecoration(labelText: AppTexts.username, prefixIcon: Icon(Iconsax.user_edit)),
                    ),
                    // Email
                    const SizedBox(height: AppSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const  InputDecoration(labelText: AppTexts.email, prefixIcon: Icon(Iconsax.direct)),
                    ),
                    // Phone Number
                    const SizedBox(height: AppSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const  InputDecoration(labelText: AppTexts.phoneNo, prefixIcon: Icon(Iconsax.call)),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwInputFields),
                    //Password
                    Obx(
                      () => TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: AppTexts.password,
                          prefixIcon: const Icon(Iconsax.password_check),
                          suffixIcon: Icon(Iconsax.eye_slash),
                        ),
                      ),
                    ),        
                    const SizedBox(height: AppSizes.spaceBtwSections),
                    // Privacy,terms
                    Row(
                      children: [
                        SizedBox(width: 24, height: 24, child: Checkbox(value: true, onChanged: (value) {},activeColor: const Color(0xFF98FF98))),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(text: AppTexts.iAgreeTo, style: Theme.of(context).textTheme.bodySmall),
                            TextSpan(text: AppTexts.privacyPolicy, style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: dark ? AppColors.white : AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: dark ? AppColors.white : AppColors.primary,
                            )),
                            TextSpan(text: AppTexts.and, style: Theme.of(context).textTheme.bodySmall),
                            TextSpan(text: AppTexts.termsOfUse, style: Theme.of(context).textTheme.bodyMedium!.apply(
                              color: dark ? AppColors.white : AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: dark ? AppColors.white : AppColors.primary,
                            )),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSections),
                    // Sign up Button
                    SizedBox(width: double.infinity, child: ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:  Color(0xFF98FF98),foregroundColor: Colors.black,side: BorderSide(color: Colors.white, width: 0)) ,onPressed: () => const VerifyEmailScreen(), child: const Text(AppTexts.createAccount)))
                  ],
                )
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              //Divider
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
          ),
        ),
      ),
    );
  }
}
