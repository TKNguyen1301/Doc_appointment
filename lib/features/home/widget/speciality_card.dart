// Widget riêng cho từng ô chuyên khoa
import 'package:flutter/material.dart';
import 'package:flutterproject/utils/constants/colors.dart';

class SpecialityCard extends StatelessWidget {
  final String label;
  final String? image;
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
            SizedBox(
              height: 48,
              width: 48,
              child: _buildImage(),
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

  Widget _buildImage() {
    // Check if image is provided and is a valid URL
    if (image != null && image!.isNotEmpty && image!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          image!,
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.medical_services,
        color: Colors.blue[600],
        size: 24,
      ),
    );
  }
}
