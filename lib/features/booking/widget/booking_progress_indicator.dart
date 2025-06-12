import 'package:flutter/material.dart';
import 'package:flutterproject/utils/constants/colors.dart';
class BookingProgressIndicator extends StatelessWidget {
  const BookingProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Bước 1: Chọn lịch khám (đã hoàn thành)
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '1',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Chọn lịch khám',
                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                ),
              ],
            ),
            // Mũi tên
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
            // Bước 2: Xác nhận (đang active)
            const SizedBox(width: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '2',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Xác nhận',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
            // Mũi tên tiếp theo
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
            // Bước 3: Nhận lịch (chưa hoàn thành)
            const SizedBox(width: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Nhận lịch hẹn',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
