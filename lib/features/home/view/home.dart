import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/features/home/widget/app_primary_header_container.dart';
import 'package:flutterproject/features/home/widget/app_promo_slider.dart';
import 'package:flutterproject/features/home/widget/find_by_speciality_section.dart';
import 'package:flutterproject/features/home/widget/doctor_list_section.dart';
import 'package:flutterproject/features/calendar/view/appointment_page.dart';
import 'package:flutterproject/features/search_page/view/search_doctor.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/login/login.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:flutterproject/navigation_menu.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:flutterproject/utils/device/device_utility.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check and fetch profile when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<PatientController>(context, listen: false);
      if (controller.profile == null && !controller.isLoading) {
        // Try to fetch profile if token exists
        controller.isAuthenticated().then((isAuth) {
          if (isAuth) {
            controller.fetchProfile().catchError((e) {
              // If fetch fails, user might not be properly authenticated
              print('Failed to fetch profile: $e');
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppPrimaryHeaderContainer(
              height: 220,
              child: Column(
                children: [
                  AppAppBar(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Thay đổi icon dựa trên trạng thái đăng nhập
                        Consumer<PatientController>(
                          builder: (context, patientController, child) {
                            if (patientController.profile != null) {
                              // Đã đăng nhập - hiển thị avatar của user
                              return GestureDetector(
                                onTap: () {
                                  // Chuyển đến tab profile
                                  final navigationController =
                                      Get.find<NavigationController>();
                                  navigationController.selectedIndex.value = 1;
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(
                                      patientController.profile!.user?.avatar ?? 
                                      'https://static.vecteezy.com/system/resources/previews/020/911/740/non_2x/user-profile-icon-profile-avatar-user-icon-male-icon-face-icon-profile-icon-free-png.png'
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Chưa đăng nhập - hiển thị icon default
                              return IconButton(
                                onPressed: () {
                                  Get.to(() => const LoginScreen());
                                },
                                icon: const Icon(Iconsax.user),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppTexts.homeAppbarTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .apply(color: AppColors.darkerGrey),
                            ),
                            // Cập nhật phần này để hiển thị đúng trạng thái
                            Consumer<PatientController>(
                              builder: (context, patientController, child) {
                                if (patientController.isLoading) {
                                  return const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF5D4037),
                                      ),
                                    ),
                                  );
                                }
                                
                                if (patientController.profile != null) {
                                  return Text(
                                    'Xin chào, ${patientController.profile!.user?.username ?? 'Người dùng'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .apply(color: const Color(0xFF5D4037)),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(() => const LoginScreen());
                                    },
                                    child: Text(
                                      AppTexts.homeAppbarSubTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .apply(color: const Color(0xFF5D4037))
                                          .copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      Consumer<PatientController>(
                        builder: (context, patientController, child) {
                          return IconButton(
                            onPressed: () {
                              if (patientController.profile != null) {
                                Get.to(() => AppointmentPage());
                              } else {
                                // Hiển thị dialog yêu cầu đăng nhập
                                _showLoginRequiredDialog(context);
                              }
                            },
                            icon: const Icon(Iconsax.calendar_1),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.defaultSpace),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoctorSearchPage()),
                        );
                      },
                      child: Container(
                        width: AppDeviceUtils.getScreenWidth(context),
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: dark ? AppColors.dark : AppColors.light,
                          borderRadius:
                              BorderRadius.circular(AppSizes.cardRadiusLg),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.search_normal,
                                color: AppColors.darkerGrey),
                            const SizedBox(width: AppSizes.spaceBtwItems),
                            Text('Tên bác sĩ, chuyên khoa,...',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: AppPromoSlider(),
            ),
            const Padding(
              padding: EdgeInsets.all(0),
              child: FindBySpecialitySection(),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: DoctorListSection(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Yêu cầu đăng nhập',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: const Text(
          'Bạn cần đăng nhập để sử dụng tính năng này.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.to(() => const LoginScreen());
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}
