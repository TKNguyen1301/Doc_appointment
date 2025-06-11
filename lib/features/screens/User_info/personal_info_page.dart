import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/features/patient/model/patient.dart';
import 'package:flutterproject/features/patient/model_view/patient_controller.dart';
import 'package:flutterproject/features/screens/User_info/edit_profile_page.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatientController()..fetchProfile(),
      child: _PersonalInfoView(), // removed const to allow rebuilds
    );
  }
}

class _PersonalInfoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PatientController>(context);
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      appBar: AppBar(
        title: const Text('👤 Hồ sơ của bạn'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfile(context, controller.profile),
    );
  }

  Widget _buildProfile(BuildContext context, Patient? profile) {
    if (profile == null) {
      return const Center(child: Text('Không thể tải thông tin cá nhân'));
    }
    final user = profile.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
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
                  if (user != null) {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => EditProfilePage(user: user),
                    //   ),
                    // );
                  }
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Điều chỉnh', style: TextStyle(fontSize: 15)),
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
                  _buildRow('🆔 Mã bệnh nhân', profile.patientId.toString(), true),
                  _buildRow('🏥 Mã BHYT', profile.insuranceNumber ?? 'Chưa cập nhật', true),
                  _buildRow('📄 CCCD', profile.idNumber ?? 'Chưa cập nhật', true),
                  _buildRow('👤 Tên đăng nhập', user?.username ?? 'Chưa cập nhật', false),
                  _buildRow('📞 SĐT', profile.phoneNumber ?? 'Chưa cập nhật', false),
                  _buildRow(
                    '🎂 Ngày sinh',
                    profile.dateOfBirth != null
                        ? DateFormat('dd/MM/yyyy').format(profile.dateOfBirth!)
                        : 'Chưa cập nhật',
                    false,
                  ),
                  _buildRow(
                    '⚧ Giới tính',
                    profile.gender != null
                        ? describeEnum(profile.gender!)
                        : 'Chưa cập nhật',
                    false,
                  ),
                  _buildRow('🏠 Địa chỉ', profile.address ?? 'Chưa cập nhật', false),
                  _buildRow('📧 Email', user?.email ?? 'Chưa cập nhật', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, bool copyable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey)),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                // ScaffoldMessenger.of(context)
                //     .showSnackBar(const SnackBar(content: Text('📋 Đã sao chép')));
              },
            ),
        ],
      ),
    );
  }
}
