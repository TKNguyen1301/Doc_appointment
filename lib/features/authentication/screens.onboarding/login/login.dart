import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/spacing_styles.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/password_configuration/forget_password.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/signup/signup.dart';
import 'package:flutterproject/navigation_menu.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/sizes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final PatientController _patientController = Get.put(PatientController());
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _patientController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      Get.offAll(() => const NavigationMenu());
    } catch (e) {
      Get.snackbar(
        'Đăng nhập thất bại',
        'Vui lòng kiểm tra email và mật khẩu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyles.paddingWithAppBarHeight,
          child: Column(
            children: [
              // Logo & Titles
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image(
                      height: 150,
                      image: AssetImage(
                        dark ? AppImages.darkAppLogo : AppImages.lightAppLogo,
                      ),
                    ),
                  ),
                  Text(
                    AppTexts.loginTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    AppTexts.loginSubTitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              // Form
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spaceBtwSections,
                  ),
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.direct_right, color: Color(0xFF98FF98)),
                          labelText: AppTexts.email,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF98FF98)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!value.isEmail) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spaceBtwInputFields),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Iconsax.password_check, color: Color(0xFF98FF98)),
                          labelText: AppTexts.password,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF98FF98)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                              color: const Color(0xFF98FF98),
                            ),
                            onPressed: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.spaceBtwInputFields / 2),

                      // Remember & Forget
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: true,
                                onChanged: (_) {},
                                activeColor: const Color(0xFF98FF98),
                              ),
                              const Text(AppTexts.rememberMe),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Get.to(() => const ForgetPassword()),
                            child: const Text(AppTexts.forgetPassword),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSizes.spaceBtwSections),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF98FF98),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(AppTexts.signIn),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spaceBtwItems),

                      // Create Account
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF98FF98),
                              width: 1,
                            ),
                          ),
                          onPressed: () => Get.to(() => const SignupScreen()),
                          child: const Text(AppTexts.createAccount),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Or Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Divider(
                      color: dark ? AppColors.darkGrey : AppColors.grey,
                      thickness: 0.5,
                      indent: 60,
                      endIndent: 5,
                    ),
                  ),
                  Text(
                    AppTexts.orSignInWith.capitalize!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Flexible(
                    child: Divider(
                      color: dark ? AppColors.darkGrey : AppColors.grey,
                      thickness: 0.5,
                      indent: 6,
                      endIndent: 60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Image(
                        width: AppSizes.iconMd,
                        height: AppSizes.iconMd,
                        image: AssetImage(AppImages.google),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceBtwItems),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Image(
                        width: AppSizes.iconMd,
                        height: AppSizes.iconMd,
                        image: AssetImage(AppImages.facebook),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
