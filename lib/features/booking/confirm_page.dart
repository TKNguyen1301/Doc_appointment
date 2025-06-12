import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterproject/features/booking/booking_result_page.dart';
import 'package:flutterproject/features/home/model/doctor.dart'; // Sử dụng model Doctor mới

class ConfirmationPage extends StatelessWidget {
  final Doctor doctor;
  final DateTime selectedDate;
  final String selectedSlot;
  final Map<String, String> patientProfile;
  final String healthInsuranceCode;
  final String citizenId;
  final String address;

  final String bookingCode;
  final int sttNumber;
  final String clinicAddress;
  final DateTime bookedAt;

  // Thêm 2 biến mới:
  final String extraInfoText;
  final List<File> extraImages;

  const ConfirmationPage({
    Key? key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedSlot,
    required this.patientProfile,
    this.healthInsuranceCode = '--',
    this.citizenId = 'Chưa cập nhật',
    this.address = '--',
    required this.bookingCode,
    required this.sttNumber,
    required this.clinicAddress,
    required this.bookedAt,
    this.extraInfoText = '',
    this.extraImages = const [],
  }) : super(key: key);

  // Helper để format ngày (ví dụ "T6 06/06/2025")
  String _formatDate(DateTime dt) {
    final weekdayMap = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN',
    };
    final wd = weekdayMap[dt.weekday]!;
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$wd $d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final String dateLabel = _formatDate(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Xác nhận thông tin',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ====== Phần indicator bước (nếu có) ======
          // ... Nếu bạn có indicator "1 – 2 – 3" thì giữ nguyên ...
          // Hoặc bỏ qua nếu không cần.
          // ---------- Phần indicator bước (bắt chước giao diện ở ảnh) ----------
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Bước 1: Chọn lịch khám (đã hoàn thành)
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade400,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Chọn lịch khám',
                        style: TextStyle(fontSize: 13, color: Colors.green),
                      ),
                    ],
                  ),
              
                  // Mũi tên
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              
                  // Bước 2: Xác nhận (đang active)
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '2',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Xác nhận',
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ],
                  ),
              
                  // Mũi tên tiếp theo (chưa đến)
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              
                  // Bước 3: Nhận lịch (chưa hoàn thành)
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '3',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nhận lịch hẹn',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ====== Phần nội dung chính ======
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================
                  // Thông tin bác sĩ + giờ khám + ngày khám - CẬP NHẬT
                  // ===========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: doctor.user?.avatar != null && doctor.user!.avatar.isNotEmpty
                              ? Image.memory(
                                  Uri.parse(doctor.user!.avatar).data!.contentAsBytes(),
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
                                        size: 24,
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
                                    size: 24,
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
                                doctor.degree,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                              const SizedBox(height: 8),
                              Text(
                                'Giờ khám: $selectedSlot',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ngày khám: $dateLabel',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===========================
                  // Thông tin bệnh nhân
                  // ===========================
                  const Text(
                    'Thông tin bệnh nhân',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        Row(
                          children: [
                            const Text('Họ và tên', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            Text(
                              patientProfile['name']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Ngày sinh', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            Text(
                              patientProfile['birthdate']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Giới tính', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            Text(
                              patientProfile['gender']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Số điện thoại', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  patientProfile['phone']!,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    // TODO: copy phone nếu cần
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
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: điều hướng sang trang chi tiết hồ sơ nếu cần
                            },
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
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Xác định chỗ muốn hiển thị (ví dụ, sau “Thông tin bệnh nhân” và trước “Chi tiết thanh toán”)
                  if (extraInfoText.isNotEmpty || extraImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Thông tin bổ sung',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (extraInfoText.isNotEmpty) ...[
                            const Text(
                              'Lý do thăm khám:',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              extraInfoText,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (extraImages.isNotEmpty) ...[
                            const Text(
                              'Ảnh đính kèm:',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
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
                  ],

                  // ===========================
                  // Chi tiết thanh toán (nếu có)
                  // ===========================
                  const Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        Row(
                          children: [
                            const Text('Phí khám', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            Text(
                              '0 đ',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Phí tiện ích', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            Text(
                              'Miễn phí',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Tổng thanh toán',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const Spacer(),
                            Text(
                              '0 đ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                  // Khoảng trống để tránh che nút “Xác nhận đặt lịch”
                ],
              ),
            ),
          ),

          // ================================================
          // Nút "Xác nhận đặt lịch" – CẬP NHẬT
          // ================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingResultPage(
                        doctor: doctor,
                        selectedDate: selectedDate,
                        selectedSlot: selectedSlot,
                        patientProfile: patientProfile,
                        bookingCode: bookingCode,
                        sttNumber: sttNumber,
                        clinicAddress: clinicAddress,
                        bookedAt: bookedAt,
                        extraInfoText: extraInfoText,
                        extraImages: extraImages,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Xác nhận đặt lịch',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}