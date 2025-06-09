import 'package:flutter/material.dart';
import 'package:flutterproject/features/screens/User_info/user_data.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _bhyteCtrl;
  late TextEditingController _cccdCtrl;
  late TextEditingController _ethnicityCtrl;
  late TextEditingController _occupationCtrl;

  DateTime? _birthDate;
  String _gender = 'Nam';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _emailCtrl = TextEditingController(text: widget.user.email ?? '');
    _streetCtrl = TextEditingController(text: widget.user.address ?? '');
    _bhyteCtrl = TextEditingController(text: widget.user.healthInsurance ?? '');
    _cccdCtrl = TextEditingController(text: widget.user.citizenId ?? '');
    _ethnicityCtrl = TextEditingController(text: widget.user.ethnicity ?? '');
    _occupationCtrl = TextEditingController(text: widget.user.occupation ?? '');
    _birthDate = DateFormat('dd/MM/yyyy').parse(widget.user.birthdate);
    _gender = widget.user.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _streetCtrl.dispose();
    _bhyteCtrl.dispose();
    _cccdCtrl.dispose();
    _ethnicityCtrl.dispose();
    _occupationCtrl.dispose();
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

  void _saveProfile() {
    widget.user
      ..name = _nameCtrl.text
      ..phone = _phoneCtrl.text
      ..email = _emailCtrl.text
      ..birthdate = DateFormat('dd/MM/yyyy').format(_birthDate!)
      ..gender = _gender
      ..address = _streetCtrl.text
      ..healthInsurance = _bhyteCtrl.text
      ..citizenId = _cccdCtrl.text
      ..ethnicity = _ethnicityCtrl.text
      ..occupation = _occupationCtrl.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Đã lưu thông tin thành công!')),
    );
    Navigator.pop(context);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCardField(_nameCtrl, 'Họ và tên *', Icons.person),
            _buildCardField(_phoneCtrl, 'Số điện thoại *', Icons.phone, inputType: TextInputType.phone),
            _buildDatePickerField('Ngày sinh *'),
            _buildGenderSelection(),
            _buildCardField(_emailCtrl, 'Email', Icons.email, inputType: TextInputType.emailAddress),
            _buildCardField(_streetCtrl, 'Địa chỉ', Icons.home),
            _buildCardField(_bhyteCtrl, 'Số BHYT', Icons.credit_card),
            _buildCardField(_cccdCtrl, 'CCCD', Icons.badge),
            _buildCardField(_ethnicityCtrl, 'Dân tộc', Icons.flag),
            _buildCardField(_occupationCtrl, 'Nghề nghiệp', Icons.work),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                '💾 Lưu thông tin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardField(TextEditingController controller, String label, IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label) {
    return GestureDetector(
      onTap: _pickBirthDate,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _birthDate == null
                    ? 'Chọn ngày sinh'
                    : DateFormat('dd/MM/yyyy').format(_birthDate!),
                style: TextStyle(
                  color: _birthDate == null ? Colors.grey : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGenderRadio('Nam', Icons.male, Colors.blue),
          const SizedBox(width: 20),
          _buildGenderRadio('Nữ', Icons.female, Colors.pink),
        ],
      ),
    );
  }

  Widget _buildGenderRadio(String value, IconData icon, Color color) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _gender,
          onChanged: (val) => setState(() => _gender = val!),
          activeColor: color,
        ),
        Icon(icon, color: color),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }
}
