import 'package:flutter/material.dart';

class PatientProfileCard extends StatelessWidget {
  final String title;
  final Map<String, String> patientProfile;
  final bool showDetailButton;
  final VoidCallback? onDetailPressed;

  const PatientProfileCard({
    Key? key,
    required this.title,
    required this.patientProfile,
    this.showDetailButton = true,
    this.onDetailPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow('Họ và tên', patientProfile['name']!),
              const SizedBox(height: 12),
              _buildInfoRow('Ngày sinh', patientProfile['birthdate']!),
              const SizedBox(height: 12),
              _buildInfoRow('Giới tính', patientProfile['gender']!),
              const SizedBox(height: 12),
              _buildPhoneRow('Số điện thoại', patientProfile['phone']!),
              if (showDetailButton) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: onDetailPressed,
                    child: Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPhoneRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const Spacer(),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                // TODO: copy phone
              },
              child: Icon(
                Icons.copy,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}