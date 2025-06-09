import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterproject/common/styles/widgets/appbar/appbar.dart';
import 'package:flutterproject/common/styles/widgets/custom_shapes/curved_edges/curved_edges.dart';
import 'package:flutterproject/features/screens/booking/booking_page.dart';
import 'package:flutterproject/features/screens/calendar/appointment_page.dart';
import 'package:flutterproject/features/screens/controllers/home_controller.dart';
import 'package:flutterproject/features/screens/doctor_data.dart';
import 'package:flutterproject/features/screens/search_page/search_doctor.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
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
                              style: Theme.of(context).textTheme.labelMedium!
                                  .apply(color: AppColors.darkerGrey),
                            ),
                            Text(
                              AppTexts.homeAppbarSubTitle,
                              style: Theme.of(context).textTheme.headlineSmall!
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
                        icon:const Icon(Iconsax.calendar_1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwInputFields),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
                    child: GestureDetector(
                      onTap: () {
                        // Thay bằng tên trang bạn muốn chuyển đến, ví dụ: SearchScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DoctorSearchPage()),
                        );
                      },
                      child: Container(
                        width: AppDeviceUtils.getScreenWidth(context),
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: dark ? AppColors.dark : AppColors.light,
                          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.search_normal, color: AppColors.darkerGrey),
                            const SizedBox(width: AppSizes.spaceBtwItems),
                            Text('Tên bác sĩ, chuyên khoa,...', style: Theme.of(context).textTheme.bodySmall),
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
              child: AppPromoSlider( ),
            ),

            const Padding(
              padding: EdgeInsets.all(0),
              child: FindBySpecialitySection(),
            ),

            Padding(
              padding: const EdgeInsets.all(0),
              child: TopDoctorsSection(),
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

class BannerItem {
  final String imageUrl;
  final String title;
  final String calories;
  final String duration;
  final String videoUrl;

  BannerItem({
    required this.imageUrl,
    required this.title,
    required this.calories,
    required this.duration,
    required this.videoUrl,
  });
}


class AppPromoSlider extends StatelessWidget {
  AppPromoSlider({
    super.key,
  });
  final List<BannerItem> banners = [
    BannerItem(
      imageUrl: AppImages.pushup,
      title: '',
      calories: '',
      duration: '',
      videoUrl: '',
    ),
    BannerItem(
      imageUrl: AppImages.squat,
      title: '',
      calories: '',
      duration: '',
      videoUrl: '',
    ),
    BannerItem(
      imageUrl: AppImages.plank,
      title: '',
      calories: '',
      duration: '',
      videoUrl: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
          ),
          items: banners.map((bannerItem) {
            return AppRoundedImage(
              imageUrl: bannerItem.imageUrl,
              title: bannerItem.title,
              calories: bannerItem.calories,
              duration: bannerItem.duration,
              videoUrl: bannerItem.videoUrl,
            );
          }).toList(),
        ),

        // Positioned indicator on top of the image (bottom center)
        Positioned(
          bottom: 20, // adjust depending on your image padding
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                banners.length,
                (i) => AppCircularContainer(
                  width: 20,
                  height: 4,
                  margin: const EdgeInsets.only(right: 10),
                  backgroundColor: controller.carousalCurrentIndex.value == i
                      ? AppColors.primary
                      : AppColors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppRoundedImage extends StatelessWidget {
  const AppRoundedImage({
    super.key,
    this.border,
    this.padding,
    this.onPressed,
    this.width,
    this.height,
    this.applyImageRadius = true,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.backgroundColor = AppColors.light,
    this.isNetworkImage = false,
    this.borderRadius= AppSizes.md,
    required this.title,
    required this.calories,
    required this.duration,
    required this.videoUrl,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;
  final String title;
  final String calories;
  final String duration;
  final String videoUrl;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration( borderRadius: BorderRadius.circular(AppSizes.md)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: applyImageRadius ? BorderRadius.circular(AppSizes.md) : BorderRadius.zero,
              child: Image(
                fit: fit,
                image: isNetworkImage ? NetworkImage(imageUrl) : AssetImage(imageUrl) as ImageProvider,
              ),
            ),
            // Icon play
            Positioned(
              right: 20, // Khoảng cách từ bên phải
              top: 0,
              bottom: 0, // Đặt để căn giữa theo chiều dọc
              child: GestureDetector(
                onTap: () {
                  //Get.to(() =>  VideoSupportScreen(videoUrl: videoUrl,));
                },
                // child: Container(
                //   width: 50,
                //   height: 50,
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: AppColors.primary, // Màu nền cho icon (xanh lá cây)
                //   ),
                //   child: const Icon(
                //     Iconsax.play,
                //     color: Colors.white,
                //     size: 30, // Kích thước icon
                //   ),
                // ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề bài tập
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lượng calo và thời gian
                  Row(
                    children: [
                      // const Icon(Icons.local_fire_department, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        calories, // Lượng calo tiêu thụ
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      // const Icon(Icons.timer, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        duration, // Thời gian tập luyện
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppPrimaryHeaderContainer extends StatelessWidget {
  const AppPrimaryHeaderContainer({
    super.key, 
    required this.child,
    required this.height,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCurvedEdgeWidget(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: height, // doi o day
          child: Stack(
            children: [
              Positioned(top: -150, right: -250,child:  AppCircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.2))),
              Positioned(top: 100, right: -300,child:  AppCircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.2))),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class AppCurvedEdgeWidget extends StatelessWidget {
  const AppCurvedEdgeWidget({
    super.key, this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppCustomCurvedEdges(),
      child: child,
    );
  }
}

class AppCircularContainer extends StatelessWidget {
  const AppCircularContainer({
    super.key,
    this.child,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.margin,
    this.padding = 0,
    this.backgroundColor = AppColors.white,
  });

  final double? width;
  final double? height;
  final double radius;
  final EdgeInsets? margin;
  final double padding;
  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor,
      ),
      child: child,
    );
  }
}

class FindBySpecialitySection extends StatelessWidget {
  const FindBySpecialitySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách chuyên khoa và đường dẫn SVG (bạn sẽ thay thế đường dẫn thật)
    final List<_SpecialityItem> specialties = [
      _SpecialityItem(
        label: 'General physician',
        svgAsset: 'assets/assets_frontend/General_physician.svg',
      ),
      _SpecialityItem(
        label: 'Sản phụ khoa',
        svgAsset: 'assets/assets_frontend/Gynecologist.svg',
      ),
      _SpecialityItem(
        label: 'Dermatologist',
        svgAsset: 'assets/assets_frontend/Dermatologist.svg',
      ),
      _SpecialityItem(
        label: 'Nhi khoa',
        svgAsset: 'assets/assets_frontend/Pediatricians.svg',
      ),
      _SpecialityItem(
        label: 'Neurologist',
        svgAsset: 'assets/assets_frontend/Neurologist.svg',
      ),
      _SpecialityItem(
        label: 'Gastroenterologist',
        svgAsset: 'assets/assets_frontend/Gastroenterologist.svg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiêu đề chính
          const Text(
            'Find by Speciality',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // // Subtitle
          // Text(
          //   'Simply browse through our extensive list of trusted doctors, schedule your appointment hassle-free.',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Colors.grey[700],
          //   ),
          // ),

          const SizedBox(height: 24),

          // Danh sách chuyên khoa dạng hàng ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: specialties.map((item) {
                return _SpecialityCard(
                  label: item.label,
                  svgAsset: item.svgAsset,
                  onTap: () {
                    // Xử lý sự kiện khi người dùng nhấn vào chuyên khoa
                    // Ví dụ: chuyển đến trang danh sách bác sĩ theo chuyên khoa
                    Get.to(() => DoctorSearchPage(specialty: item.label));
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Model đơn giản để chứa thông tin mỗi chuyên khoa
class _SpecialityItem {
  final String label;
  final String svgAsset;

  _SpecialityItem({
    required this.label,
    required this.svgAsset,
  });
}

// Widget riêng cho từng ô chuyên khoa
class _SpecialityCard extends StatelessWidget {
  final String label;
  final String svgAsset;
  final VoidCallback onTap;

  const _SpecialityCard({
    Key? key,
    required this.label,
    required this.svgAsset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Column(
          children: [
            SvgPicture.asset(svgAsset, height: 48),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}


/// Model đơn giản cho một bác sĩ
class TopDoctor {
  final String name;
  final String specialty;
  final String image; // đường dẫn tới file .png
  final bool isAvailable;

  TopDoctor({
    required this.name,
    required this.specialty,
    required this.image,
    this.isAvailable = true,
  });
}

/// Widget chính hiển thị section “Top Doctors to Book”
class TopDoctorsSection extends StatelessWidget {
  TopDoctorsSection({Key? key}) : super(key: key);

  final List<Doctor> doctors = doctorList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          // Tiêu đề chính
          Text(
            'Top Doctors to Book',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Simply browse through our extensive list of trusted doctors.',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // === Thay thế GridView.builder cũ bằng ListView.builder cuộn ngang ===
          SizedBox(
            height: 300, // Chiều cao cố định để chứa mỗi card bác sĩ
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: doctors.length,
              padding: const EdgeInsets.only(left: 8),
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    width: 160, // Chiều rộng cố định cho mỗi card
                    child: _DoctorCard(doctor: doctor),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Nút “More”
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 10), // Tăng chiều rộng và chiều cao
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue.shade900,
              elevation: 2, // Thêm chút độ nổi
              shadowColor: Colors.blue.shade200, // Màu bóng nhẹ
            ),
            onPressed: () {
              // TODO: Thêm hành động khi nhấn “More”
            },
            child: const Text(
              'More',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị từng “card” bác sĩ
class _DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const _DoctorCard({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        // TODO: Chuyển tới trang chi tiết bác sĩ
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Ảnh bác sĩ
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 1, // Ảnh hiển thị vuông
                child: Image.asset(
                  doctor.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Nội dung bên dưới ảnh
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng trạng thái “Available”
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: doctor.isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.isAvailable ? 'Available' : 'Offline',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: doctor.isAvailable ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tên bác sĩ
                    Text(
                      doctor.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Chuyên khoa
                    Text(
                      doctor.specialty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Nút “Book” hoặc icon chấm nhỏ nếu muốn
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryBackground,
                          textStyle: const TextStyle(fontSize: 14),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        onPressed: () {
                          // TODO: Thêm hành động đặt lịch cho bác sĩ
                          Get.to(() => BookingPage(doctor: doctor));
                        },
                        child: const Text('Book'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}