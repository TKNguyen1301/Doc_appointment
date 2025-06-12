import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/login/login.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';

class SignupController extends GetxController {
  final isPasswordHidden = true.obs;
}

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final SignupController controller = Get.put(SignupController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    final patientController = Provider.of<PatientController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark ? Colors.black : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(
                        labelText: AppTexts.username,
                        prefixIcon: Icon(Iconsax.user_edit),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Vui lòng nhập tên người dùng'
                              : null,
                    ),
                    const SizedBox(height: AppSizes.spaceBtwInputFields),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: AppTexts.email,
                        prefixIcon: Icon(Iconsax.direct),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spaceBtwInputFields),
                    Obx(
                      () => TextFormField(
                        controller: _passwordCtrl,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: AppTexts.password,
                          prefixIcon: const Icon(Iconsax.password_check),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isPasswordHidden.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye),
                            onPressed: () => controller.isPasswordHidden.value =
                                !controller.isPasswordHidden.value,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: patientController.isLoading
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                minimumSize: const Size(double.infinity, 48),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() != true) return;
                                try {
                                  await patientController.register(
                                    _usernameCtrl.text.trim(),
                                    _passwordCtrl.text.trim(),
                                    _emailCtrl.text.trim(),
                                  );
                                  // Thông báo đăng ký thành công
                                  Get.snackbar(
                                    'Đăng ký thành công',
                                    '',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  Future.delayed(const Duration(seconds: 1), () {
                                    Get.offAll(() => const LoginScreen());
                                  });
                                } catch (e) {
                                  Get.snackbar(
                                    'Đăng ký thất bại',
                                    e.toString(),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              child: const Text(AppTexts.createAccount),
                            ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
