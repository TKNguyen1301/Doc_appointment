// Widget riêng cho từng ô chuyên khoa
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterproject/utils/constants/colors.dart';

class SpecialityCard extends StatelessWidget {
  final String label;
  final String? image; // Đổi từ imageData thành image
  final VoidCallback onTap;

  const SpecialityCard({
    Key? key,
    required this.label,
    this.image,
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
            // Hiển thị ảnh: nếu có image thì dùng Image.memory, không thì dùng SVG mặc định
            SizedBox(
              height: 48,
              width: 48,
              child: image != null && image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        Uri.parse(image!).data!.contentAsBytes(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return SvgPicture.asset(
                            'assets/assets_frontend/General_physician.svg',
                            height: 48,
                          );
                        },
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/assets_frontend/General_physician.svg',
                      height: 48,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
