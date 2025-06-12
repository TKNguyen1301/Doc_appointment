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
                child: doctor.user?.avatar != null && doctor.user!.avatar!.isNotEmpty
                    ? Image.network(
                        doctor.user!.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
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
                    // Tên bác sĩ
                    Text(
                      doctor.user?.username ?? 'Unknown Doctor',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Chuyên khoa
                    Text(
                      doctor.specialization?.name ?? 'General',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Experience
                    Text(
                      '${doctor.experienceYears} years exp.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    
                    // Available status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isAvailable() ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isAvailable() ? 'Available' : 'Busy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
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