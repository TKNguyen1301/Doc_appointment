import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/features/booking/model/appointment.dart';
import 'package:flutterproject/features/booking/widget/appointment_progress_indicator.dart';
import 'package:flutterproject/utils/formatters/date_formatter.dart';
import 'package:flutterproject/navigation_menu.dart';
import 'package:get/get.dart';

class BookingResultPage extends StatelessWidget {
  final Appointment appointment;
  final Doctor doctor;
  final DateTime selectedDate;
  final String selectedSlot;
  final Map<String, String> patientProfile;
  final String extraInfoText;
  final List<File> extraImages;

  const BookingResultPage({
    Key? key,
    required this.appointment,
    required this.doctor,
    required this.selectedDate,
    required this.selectedSlot,
    required this.patientProfile,
    this.extraInfoText = '',
    this.extraImages = const [],
  }) : super(key: key);

  String get bookingCode {
    final now = DateTime.now();
    return 'YMA${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${appointment.appointmentId.toString().padLeft(4, '0')}';
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Thêm method để lấy fee đúng
  int get _actualFee {
    // Ưu tiên: Appointment fees > Specialization fees
    if (appointment.fees > 0) {
      return appointment.fees;
    }
    if (doctor.specialization?.fees != null && doctor.specialization!.fees > 0) {
      return doctor.specialization!.fees;
    }
    return 0;
  }

  String get _formattedFee {
    return '${_actualFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final String dateLabel = DateFormatter.formatDate(selectedDate);
    final String bookedAtLabel = DateFormatter.formatTimestamp(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Get.to(() => const NavigationMenu()),
        ),
        title: const Text(
          'Kết quả đặt khám',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black54),
            onPressed: () {
              // TODO: Share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const AppointmentProgressIndicator(currentStep: 3),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.check,
                            size: 36,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Đã đặt lịch thành công',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bookedAtLabel,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Doctor & Appointment Details section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Doctor info
                        Row(
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
                                  Text(
                                    'BÁC SĨ',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Appointment code
                        Row(
                          children: [
                            Text(
                              'Mã lịch khám',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            Text(
                              bookingCode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _copyToClipboard(context, bookingCode),
                              child: Icon(
                                Icons.copy,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Appointment date
                        Row(
                          children: [
                            Text(
                              'Ngày khám',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            Text(
                              dateLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Appointment time
                        Row(
                          children: [
                            Text(
                              'Giờ khám',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            Text(
                              selectedSlot,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Status
                        Row(
                          children: [
                            Text(
                              'Trạng thái',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Chờ khám',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Patient info section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THÔNG TIN BỆNH NHÂN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Name
                        _buildInfoRow('Họ và tên', patientProfile['name']!),
                        const SizedBox(height: 12),

                        // Birthdate
                        _buildInfoRow('Ngày sinh', patientProfile['birthdate']!),
                        const SizedBox(height: 12),

                        // Gender
                        _buildInfoRow('Giới tính', patientProfile['gender']!),
                        const SizedBox(height: 12),

                        // Phone
                        _buildPhoneRow('Số điện thoại', patientProfile['phone']!),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Extra info section (if any)
                  if (extraInfoText.isNotEmpty || extraImages.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'THÔNG TIN BỔ SUNG',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (extraInfoText.isNotEmpty) ...[
                            Text(
                              'Lý do thăm khám:',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              extraInfoText,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            if (extraImages.isNotEmpty) const SizedBox(height: 12),
                          ],
                          if (extraImages.isNotEmpty) ...[
                            Text(
                              'Ảnh đính kèm:',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: extraImages.map((file) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    file,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Payment info
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THANH TOÁN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Phí khám',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            Text(
                              _formattedFee,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Trạng thái',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Chưa thanh toán',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Home button
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.to(() => const NavigationMenu());
                      },
                      child: Text(
                        'Về trang chủ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
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
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}