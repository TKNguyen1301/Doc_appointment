import 'package:flutter/material.dart';
import 'package:flutterproject/features/home/model/doctor.dart';

class DoctorInfoCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorInfoCard({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: doctor.user?.avatar != null && doctor.user!.avatar!.isNotEmpty
                ? Image.network(
                    doctor.user!.avatar!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BÁC SĨ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}