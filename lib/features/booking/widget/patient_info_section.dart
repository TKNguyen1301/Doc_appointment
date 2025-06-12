import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutterproject/utils/constants/colors.dart';
class PatientInfoSection extends StatelessWidget {
  final bool isUserLoggedIn;
  final Map<String, String> patientProfile;
  final VoidCallback onLogin;

  const PatientInfoSection({
    Key? key,
    required this.isUserLoggedIn,
    required this.patientProfile,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đặt lịch khám này cho:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (!isUserLoggedIn) ...[
          // Hiển thị khi chưa đăng nhập
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Bạn cần đăng nhập để đặt lịch khám',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onLogin,
                    child: Text(
                      'Đăng nhập ngay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Hiển thị khi đã đăng nhập
          Consumer<PatientController>(
            builder: (context, patientController, child) {
              final profile = patientController.profile;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                        'Họ và tên:',
                        profile?.user?.username ?? patientProfile['name'] ?? '',
                        Icons.person),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Giới tính:',
                        profile?.gender?.toString() ?? patientProfile['gender'] ?? '',
                        Icons.wc),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Ngày sinh:',
                        profile?.dateOfBirth?.toString().split(' ')[0] ?? patientProfile['birthdate'] ?? '',
                        Icons.cake),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Số điện thoại:',
                        profile?.phoneNumber ?? patientProfile['phone'] ?? '',
                        Icons.phone),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Mã BHYT:',
                        profile?.insuranceNumber ?? 'Chưa cập nhật',
                        Icons.health_and_safety),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
