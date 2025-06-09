import 'package:flutter/material.dart';
import 'package:flutterproject/utils/constants/colors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: kết nối API hoặc logic thay đổi mật khẩu
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Đổi mật khẩu thành công!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      appBar: AppBar(
        title: const Text('🔐 Đổi mật khẩu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                controller: _oldCtrl,
                label: 'Mật khẩu cũ',
                icon: Icons.lock_outline,
                obscureText: _obscureOld,
                toggle: () => setState(() => _obscureOld = !_obscureOld),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newCtrl,
                label: 'Mật khẩu mới',
                icon: Icons.lock_reset,
                obscureText: _obscureNew,
                toggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Mật khẩu mới ít nhất 6 ký tự' : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmCtrl,
                label: 'Xác nhận mật khẩu mới',
                icon: Icons.verified_user,
                obscureText: _obscureConfirm,
                toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) =>
                    v != _newCtrl.text ? '❗ Không khớp mật khẩu' : null,
              ),
              const SizedBox(height: 100), // tránh che bàn phím
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _changePassword,
            style: ElevatedButton.styleFrom(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.save),
            label: const Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback toggle,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator ??
            (v) => v == null || v.isEmpty ? 'Vui lòng nhập $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
