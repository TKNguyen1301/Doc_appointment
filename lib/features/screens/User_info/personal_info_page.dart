import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterproject/features/screens/User_info/edit_profile_page.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'user_data.dart';

class PersonalInfoPage extends StatelessWidget {
  final User user;
  const PersonalInfoPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      appBar: AppBar(
        title: const Text('👤 Hồ sơ của bạn'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Thông tin cơ bản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(user: user),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(
                    'Điều chỉnh',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    _buildInfoRow(context, '🆔 Mã bệnh nhân', user.patientId, true),
                    _buildInfoRow(context, '🏥 Mã BHYT', user.healthInsurance ?? 'Chưa cập nhật', true),
                    _buildInfoRow(context, '📄 CCCD', user.citizenId ?? 'Chưa cập nhật', true),
                    _buildInfoRow(context, '👤 Họ và tên', user.name, false),
                    _buildInfoRow(context, '📞 SĐT', user.phone, false),
                    _buildInfoRow(context, '🎂 Ngày sinh', user.birthdate, false),
                    _buildInfoRow(context, '⚧ Giới tính', user.gender, false),
                    _buildInfoRow(context, '🏠 Địa chỉ', user.address ?? 'Chưa cập nhật', false),
                    _buildInfoRow(context, '🌍 Dân tộc', user.ethnicity ?? 'Chưa cập nhật', false),
                    _buildInfoRow(context, '💼 Nghề nghiệp', user.occupation ?? 'Chưa cập nhật', false),
                    _buildInfoRow(context, '📧 Email', user.email ?? 'Chưa cập nhật', false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, bool canCopy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (canCopy)
            IconButton(
              icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📋 Đã sao chép')),
                );
              },
            ),
        ],
      ),
    );
  }
}
