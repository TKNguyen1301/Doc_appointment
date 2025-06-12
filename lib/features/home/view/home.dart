import 'package:flutter/material.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/features/home/widget/app_primary_header_container.dart';
import 'package:flutterproject/features/home/widget/app_promo_slider.dart';
import 'package:flutterproject/features/home/widget/find_by_speciality_section.dart';
import 'package:flutterproject/features/home/widget/doctor_list_section.dart';
import 'package:flutterproject/features/screens/calendar/appointment_page.dart';
import 'package:flutterproject/features/search_page/view/search_doctor.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/sizes.dart';
import 'package:flutterproject/utils/constants/text_strings.dart';
import 'package:flutterproject/utils/device/device_utility.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Iconsax.user),
                        ),
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
                            Text(
                              AppTexts.homeAppbarSubTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .apply(color: const Color(0xFF5D4037)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Get.to(() => AppointmentPage());
                        },
                        icon: const Icon(Iconsax.calendar_1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.defaultSpace),
                    child: GestureDetector(
                      onTap: () {
                        // Thay bằng tên trang bạn muốn chuyển đến, ví dụ: SearchScreen
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            //   child: Container(
            //     width: AppDeviceUtils.getScreenWidth(context),
            //     padding: const EdgeInsets.all(AppSizes.md),
            //     child: Text(
            //       AppTexts.videosupport,
            //       style: Theme.of(context).textTheme.headlineMedium,
            //       textAlign: TextAlign.left, // Căn trái cho văn bản
            //     ),
            //   ),
            // ),

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

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            //   child: Container(
            //     width: AppDeviceUtils.getScreenWidth(context),
            //     padding: const EdgeInsets.all(AppSizes.md),
            //     child: Text(
            //       AppTexts.choose,
            //       style: Theme.of(context).textTheme.headlineMedium,
            //       textAlign: TextAlign.left, // Căn trái cho văn bản
            //     ),
            //   ),
            // ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
            //   child: Container(
            //     height: 100,
            //     width: AppDeviceUtils.getScreenWidth(context),
            //     padding: const EdgeInsets.all(AppSizes.md),
            //     decoration: BoxDecoration(
            //       color: dark ? AppColors.dark : AppColors.light,
            //       borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            //       border: Border.all(color: AppColors.grey),
            //     ),
            //     child: GestureDetector(
            //       onTap: () {
            //         //Get.to(() => const SetupScreenPushUp());
            //       },
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           ClipRRect(
            //             borderRadius: BorderRadius.circular(12),
            //             child: Image.asset(AppImages.pushup,height: 80,width: 80, fit: BoxFit.cover),
            //           ),

            //           const SizedBox(width: AppSizes.spaceBtwItems),

            //           Expanded(
            //             child: Text('Push Up', style: Theme.of(context).textTheme.headlineSmall),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // const SizedBox(height: AppSizes.spaceBtwItems),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
            //   child: Container(
            //     height: 100,
            //     width: AppDeviceUtils.getScreenWidth(context),
            //     padding: const EdgeInsets.all(AppSizes.md),
            //     decoration: BoxDecoration(
            //       color: dark ? AppColors.dark : AppColors.light,
            //       borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            //       border: Border.all(color: AppColors.grey),
            //     ),
            //     child: GestureDetector(
            //       onTap: () {
            //         //Get.to(() => const SetupScreenSquat());
            //       },
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           ClipRRect(
            //             borderRadius: BorderRadius.circular(12),
            //             child: Image.asset(AppImages.squat,height: 80,width: 80, fit: BoxFit.cover),
            //           ),

            //           const SizedBox(width: AppSizes.spaceBtwItems),

            //           Expanded(
            //             child: Text('Squat', style: Theme.of(context).textTheme.headlineSmall),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // const SizedBox(height: AppSizes.spaceBtwItems),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
            //   child: Container(
            //     height: 100,
            //     width: AppDeviceUtils.getScreenWidth(context),
            //     padding: const EdgeInsets.all(AppSizes.md),
            //     decoration: BoxDecoration(
            //       color: dark ? AppColors.dark : AppColors.light,
            //       borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            //       border: Border.all(color: AppColors.grey),
            //     ),
            //     child: GestureDetector(
            //       onTap: () {
            //         //Get.to(() => const SetupScreenPlank());
            //       },
            //       child: Row(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           ClipRRect(
            //             borderRadius: BorderRadius.circular(12),
            //             child: Image.asset(AppImages.plank,height: 80,width: 80, fit: BoxFit.cover),
            //           ),

            //           const SizedBox(width: AppSizes.spaceBtwItems),

            //           Expanded(
            //             child: Text('Plank', style: Theme.of(context).textTheme.headlineSmall),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
