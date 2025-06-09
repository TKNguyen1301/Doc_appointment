import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterproject/features/screens/doctor_data.dart';
import 'package:flutterproject/features/screens/home/home.dart';
import 'package:flutterproject/navigation_menu.dart';
import 'package:get/get.dart';

class BookingResultPage extends StatelessWidget {
  final Doctor doctor;
  final DateTime selectedDate;
  final String selectedSlot;
  final Map<String, String> patientProfile;
  final String bookingCode;
  final int sttNumber;
  final String clinicAddress;
  final DateTime bookedAt;

  // Thêm 2 biến sau:
  final String extraInfoText;
  final List<File> extraImages;

  const BookingResultPage({
    Key? key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedSlot,
    required this.patientProfile,
    required this.bookingCode,
    required this.sttNumber,
    required this.clinicAddress,
    required this.bookedAt,
    this.extraInfoText = '',
    this.extraImages = const [],
  }) : super(key: key);

  String _formatDate(DateTime dt) {
    // Ví dụ: T6, 06/06/2025
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
    return '$wd, $d/$m/$y';
  }

  String _formatTimestamp(DateTime dt) {
    // Ví dụ: 16:23:45 06/06/2025
    final hours = dt.hour.toString().padLeft(2, '0');
    final minutes = dt.minute.toString().padLeft(2, '0');
    final seconds = dt.second.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$hours:$minutes:$seconds $d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final String dateLabel = _formatDate(selectedDate);
    final String bookedAtLabel = _formatTimestamp(bookedAt);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            // Nếu muốn chỉ đóng trang này, dùng:
            Navigator.of(context).pop();
          },
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
              // TODO: Xử lý share (ví dụ share screenshot hoặc link)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==============================
            // 1. Thiết kế phần header “Đã đặt lịch” + timestamp
            // ==============================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  // Icon check
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
                    'Đã đặt lịch',
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

            // ==============================
            // 2. Phần STT + QR code
            // ==============================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  // Dòng STT + QR
                  Row(
                    children: [
                      // STT
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'STT',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sttNumber.toString(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          )
                        ],
                      ),

                      const Spacer(),

                      // // QR code (sử dụng qr_flutter)
                      // QrImage(
                      //   data: bookingCode, // bạn có thể encode thêm JSON nếu cần
                      //   version: QrVersions.auto,
                      //   size: 80.0,
                      // ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==============================
            // 3. Phần Thông tin bác sĩ + chi tiết lịch (Mã lịch khám, Ngày, Giờ + Buổi)
            // ==============================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ảnh + Thông tin bác sĩ
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          doctor.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.title, // ex: "BS.CK1"
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.name, // ex: "Vũ Thị Hạnh Thư"
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              clinicAddress, // ex: "333 Huỳnh Tấn Phát, P. Tân Thuận Đông, Q.7, TP.HCM"
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Dòng Mã lịch khám
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
                        onTap: () {
                          // TODO: copy bookingCode vào clipboard
                        },
                        child: Icon(
                          Icons.copy,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Dòng Ngày khám
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

                  // Dòng Giờ khám
                  Row(
                    children: [
                      Text(
                        'Giờ khám',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Text(
                        selectedSlot, // ex: "17:40 - 17:50 (Buổi chiều)"
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==============================
            // 4. Phần Thông tin bệnh nhân (có nút "Xem chi tiết")
            // ==============================
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

                  // Họ và tên
                  Row(
                    children: [
                      Text(
                        'Họ và tên',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Text(
                        patientProfile['name']!,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ngày sinh
                  Row(
                    children: [
                      Text(
                        'Ngày sinh',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Text(
                        patientProfile['birthdate']!,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Giới tính
                  Row(
                    children: [
                      Text(
                        'Giới tính',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      Text(
                        patientProfile['gender']!,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Số điện thoại
                  Row(
                    children: [
                      Text(
                        'Số điện thoại',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
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
                              // TODO: copy số điện thoại, gọi điện, v.v...
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

                  // Nút “Xem chi tiết”
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: điều hướng sang trang chi tiết hồ sơ bệnh nhân
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
            
            const SizedBox(height: 24),
          ],
        ),
      ),

      // ==============================
      // 5. Hai nút “Về trang chủ” + “Chat với bác sĩ” ở bottom
      // ==============================
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Nút Về trang chủ
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
                    // Quay về trang chính (popUntil isFirst)
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
              const SizedBox(width: 12),

              // // Nút Chat với bác sĩ
              // Expanded(
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blue.shade600,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       padding: const EdgeInsets.symmetric(vertical: 14),
              //     ),
              //     onPressed: () {
              //       // TODO: điều hướng sang màn chat với bác sĩ
              //     },
              //     child: const Text(
              //       'Chat với bác sĩ',
              //       style: TextStyle(
              //         fontSize: 14,
              //         color: Colors.white,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}