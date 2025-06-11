import 'package:flutter/material.dart';
import 'package:flutterproject/features/booking/booking_page.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:get/get.dart';

/// Widget hiển thị từng "card" bác sĩ
class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({
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
                child: doctor.user?.avatar != null && doctor.user!.avatar.isNotEmpty
                    ? Image.memory(
                        Uri.parse(doctor.user!.avatar).data!.contentAsBytes(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.grey[400],
                        ),
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
                    // Dòng trạng thái "Available" (dựa vào doctorShifts)
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: _isAvailable() ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isAvailable() ? 'Available' : 'Offline',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _isAvailable() ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tên bác sĩ (sử dụng username từ User model)
                    Text(
                      '${doctor.degree} ${doctor.user?.username ?? 'Unknown Doctor'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Kinh nghiệm
                    Text(
                      '${doctor.experienceYears} năm kinh nghiệm',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Chuyên khoa
                    Text(
                      doctor.specialization?.name ?? 'General',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Nút "Book"
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

  // Helper method để check available dựa vào doctor shifts
  bool _isAvailable() {
    if (doctor.doctorShifts == null || doctor.doctorShifts!.isEmpty) {
      return false;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return doctor.doctorShifts!.any((shift) => 
      shift.shiftDate.isAtSameMomentAs(today) || shift.shiftDate.isAfter(today)
    );
  }
}