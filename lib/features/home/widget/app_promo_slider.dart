import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterproject/features/home/view_model/home_controller.dart';
import 'package:flutterproject/features/home/widget/app_circular_container.dart';
import 'package:flutterproject/features/home/widget/app_rounded_image.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/image_strings.dart';
import 'package:get/get.dart';

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