import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/features/authentication/model/patient.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:flutterproject/features/screens/User_info/edit_profile_page.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  @override
  void initState() {
    super.initState();
    // Ensure profile is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<PatientController>(context, listen: false);
      if (controller.profile == null && !controller.isLoading) {
        controller.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng provider đã có thay vì tạo mới
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      appBar: AppBar(
        title: const Text('👤 Hồ sơ của bạn'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PatientController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không thể tải thông tin cá nhân'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchProfile(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          
          return _buildProfile(context, controller.profile!);
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, Patient profile) {
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
                  // Navigate to edit page if needed
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => EditProfilePage(),
                  //   ),
                  // );
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
                  _buildRow(context, '🆔 Mã bệnh nhân', profile.patientId.toString(), true),
                  _buildRow(context, '🏥 Mã BHYT', profile.insuranceNumber ?? 'Chưa cập nhật', true),
                  _buildRow(context, '📄 CCCD', profile.idNumber ?? 'Chưa cập nhật', true),
                  _buildRow(context, '👤 Tên đăng nhập', user?.username ?? 'Chưa cập nhật', false),
                  _buildRow(context, '📞 SĐT', profile.phoneNumber ?? 'Chưa cập nhật', false),
                  _buildRow(
                    context,
                    '🎂 Ngày sinh',
                    profile.dateOfBirth != null
                        ? DateFormat('dd/MM/yyyy').format(profile.dateOfBirth!)
                        : 'Chưa cập nhật',
                    false,
                  ),
                  _buildRow(
                    context,
                    '⚧ Giới tính',
                    profile.gender != null
                        ? describeEnum(profile.gender!)
                        : 'Chưa cập nhật',
                    false,
                  ),
                  _buildRow(context, '🏠 Địa chỉ', profile.address ?? 'Chưa cập nhật', false),
                  _buildRow(context, '📧 Email', user?.email ?? 'Chưa cập nhật', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, bool copyable) {
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
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('📋 Đã sao chép')));
              },
            ),
        ],
      ),
    );
  }
}
