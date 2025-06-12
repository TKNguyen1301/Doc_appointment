import 'package:flutter/material.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/constants/sizes.dart';

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