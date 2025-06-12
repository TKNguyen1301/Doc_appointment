import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:flutterproject/features/authentication/model/patient.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() { _avatarFile = File(picked.path); });
    }
  }

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _insuranceCtrl;
  late TextEditingController _idCtrl;
  DateTime? _birthDate;
  String _gender = 'male';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final ctrl = Provider.of<PatientController>(context, listen: false);
      final profile = ctrl.profile;
      if (profile != null) {
        final user = profile.user!;
        _usernameCtrl = TextEditingController(text: user.username);
        _emailCtrl    = TextEditingController(text: user.email);
        _phoneCtrl    = TextEditingController(text: profile.phoneNumber ?? '');
        _addressCtrl  = TextEditingController(text: profile.address ?? '');
        _insuranceCtrl= TextEditingController(text: profile.insuranceNumber ?? '');
        _idCtrl       = TextEditingController(text: profile.idNumber ?? '');
        _birthDate    = profile.dateOfBirth;
        _gender       = profile.gender != null ? describeEnum(profile.gender!).toLowerCase() : 'male';
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _usernameCtrl.dispose();
      _emailCtrl.dispose();
      _phoneCtrl.dispose();
      _addressCtrl.dispose();
      _insuranceCtrl.dispose();
      _idCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) setState(() => _birthDate = date);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = Provider.of<PatientController>(context, listen: false);
    final fields = <String, String>{
      'username': _usernameCtrl.text,
      'email': _emailCtrl.text,
      'phone_number': _phoneCtrl.text,
      'address': _addressCtrl.text,
      'insurance_number': _insuranceCtrl.text,
      'id_number': _idCtrl.text,
      'gender': _gender,
      if (_birthDate != null)
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_birthDate!),
    };
    try {
      await ctrl.updateProfile(fields, avatar: _avatarFile);
      await ctrl.fetchProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Cập nhật thành công!'))
      );
    } catch (_) {
      // ignore errors
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      appBar: AppBar(
        title: const Text('📝 Chỉnh sửa hồ sơ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<PatientController>(
        builder: (context, ctrl, child) {
          if (ctrl.isLoading || !_initialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : NetworkImage(ctrl.profile!.user?.avatar ?? '') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(_usernameCtrl, 'Tên đăng nhập *', Icons.person),
                  _buildField(_emailCtrl, 'Email *', Icons.email,
                    inputType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Không được để trống' : null
                  ),
                  _buildField(_phoneCtrl, 'SĐT *', Icons.phone,
                    inputType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Không được để trống' : null
                  ),
                  _buildDatePicker(),
                  _buildGenderSelector(),
                  _buildField(_addressCtrl, 'Địa chỉ', Icons.home),
                  _buildField(_insuranceCtrl, 'Số BHYT', Icons.credit_card),
                  _buildField(_idCtrl, 'CCCD', Icons.badge),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
    {TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickBirthDate,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _birthDate == null ? 'Chọn ngày sinh' : DateFormat('dd/MM/yyyy').format(_birthDate!),
                style: TextStyle(color: _birthDate==null?Colors.grey:Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Gender.values.map((g) {
          final label = describeEnum(g).toLowerCase();
          return Expanded(
            child: Row(
              children: [
                Radio<String>(
                  value: label,
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender=v!),
                  activeColor: AppColors.primary,
                ),
                Text(label[0].toUpperCase() + label.substring(1)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
