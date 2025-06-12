import 'package:flutter/material.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/utils/widgets/network_image_with_timeout.dart';

class DoctorAppointmentCard extends StatelessWidget {
  final Doctor doctor;
  final String? selectedSlot;
  final String? selectedDate;
  final bool showScheduleInfo;

  const DoctorAppointmentCard({
    Key? key,
    required this.doctor,
    this.selectedSlot,
    this.selectedDate,
    this.showScheduleInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AvatarImageWithTimeout(
            imageUrl: doctor.user?.avatar,
            radius: 24,
            timeout: const Duration(seconds: 8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.degree,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.user?.username ?? 'Unknown Doctor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chuyên khoa: ${doctor.specialization?.name ?? 'General'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                if (showScheduleInfo &&
                    selectedSlot != null &&
                    selectedDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Giờ khám: $selectedSlot',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ngày khám: $selectedDate',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
