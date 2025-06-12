import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterproject/features/booking/view/booking_result_page.dart';
import 'package:flutterproject/features/booking/model_view/appointment_controller.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/features/booking/model/appointment.dart';
import 'package:flutterproject/features/booking/widget/appointment_progress_indicator.dart';
import 'package:flutterproject/features/booking/widget/doctor_appointment_card.dart';
import 'package:flutterproject/features/booking/widget/patient_profile_card.dart';
import 'package:flutterproject/features/booking/widget/extra_info_display.dart';
import 'package:flutterproject/utils/formatters/date_formatter.dart';

import 'package:provider/provider.dart';
import 'package:flutterproject/utils/constants/colors.dart';

class ConfirmationPage extends StatefulWidget {
  final Doctor doctor;
  final DateTime selectedDate;
  final String selectedSlot;
  final Map<String, String> patientProfile;
  final DateTime appointmentDateTime;
  final String extraInfoText;
  final List<File> extraImages;

  const ConfirmationPage({
    Key? key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedSlot,
    required this.patientProfile,
    required this.appointmentDateTime,
    this.extraInfoText = '',
    this.extraImages = const [],
  }) : super(key: key);

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final AppointmentController _appointmentController = AppointmentController();
  bool _isBooking = false;

  // Thêm method để tính fee
  int get _calculatedFee {
    if (widget.doctor.specialization?.fees != null &&
        widget.doctor.specialization!.fees > 0) {
      return widget.doctor.specialization!.fees;
    }
    return 0;
  }

  String get _formattedFee {
    return '${_calculatedFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ';
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _isBooking = true;
    });

    print('🚀 Starting appointment booking process...');

    try {
      final patientController =
          Provider.of<PatientController>(context, listen: false);

      // Ensure we have authentication
      if (patientController.token == null) {
        print('🔐 No token found, checking authentication...');
        await patientController.isAuthenticated();
      }

      final token = patientController.token;
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }
      print('✅ Authentication verified');

      // Format datetime to backend expected format (ISO 8601)
      final formattedDatetime = widget.appointmentDateTime.toIso8601String();
      print('📅 Formatted appointment datetime: $formattedDatetime');

      // Call the booking API
      print('📞 Calling booking API...');
      final result = await _appointmentController.bookAppointmentOnline(
        doctorId: widget.doctor.doctorId,
        appointmentDatetime: formattedDatetime,
        reason: widget.extraInfoText.isNotEmpty ? widget.extraInfoText : null,
        token: token,
      );

      print('🎉 Booking API response received successfully!');
      print('📄 Response: $result');

      if (mounted) {
        // Create a temporary appointment object for display purposes
        final tempAppointment = Appointment(
          appointmentId: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          patientId: patientController.profile?.patientId ?? 0,
          doctorId: widget.doctor.doctorId,
          bookingSource: 'online',
          reason: widget.extraInfoText.isNotEmpty ? widget.extraInfoText : null,
          appointmentDatetime: widget.appointmentDateTime,
          status: 'scheduled',
          arrivalStatus: 'pending',
          checkinTime: null,
          fees: _calculatedFee,
          patient: patientController.profile,
          doctor: widget.doctor,
        );

        print('🏥 Navigating to booking result page...');
        // Navigate to success page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingResultPage(
              appointment: tempAppointment,
              doctor: widget.doctor,
              selectedDate: widget.selectedDate,
              selectedSlot: widget.selectedSlot,
              patientProfile: widget.patientProfile,
              extraInfoText: widget.extraInfoText,
              extraImages: widget.extraImages,
              isSuccess: true,
              message: result['message'] ?? 'Appointment booked successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error occurred during booking: $e');

      String errorMessage = 'Lỗi đặt lịch không xác định';
      String debugInfo = '';

      if (e.toString().contains('ApiException')) {
        // Extract detailed error information
        final errorString = e.toString();
        final lines = errorString.split('\n');

        if (lines.isNotEmpty) {
          // Get the main error message
          final mainMessage = lines[0].replaceFirst('ApiException: ', '');

          // Handle specific error cases with user-friendly messages
          if (mainMessage.toLowerCase().contains('not available')) {
            errorMessage =
                'Bác sĩ không có lịch trống vào thời gian này.\nVui lòng chọn thời gian khác.';
          } else if (mainMessage.toLowerCase().contains('authentication') ||
              mainMessage.toLowerCase().contains('unauthorized')) {
            errorMessage =
                'Phiên đăng nhập đã hết hạn.\nVui lòng đăng nhập lại.';
          } else if (mainMessage.toLowerCase().contains('doctor not found')) {
            errorMessage =
                'Không tìm thấy thông tin bác sĩ.\nVui lòng thử lại.';
          } else if (mainMessage.toLowerCase().contains('invalid datetime') ||
              mainMessage.toLowerCase().contains('invalid time')) {
            errorMessage =
                'Thời gian đặt lịch không hợp lệ.\nVui lòng chọn thời gian khác.';
          } else if (mainMessage.toLowerCase().contains('already booked') ||
              mainMessage.toLowerCase().contains('duplicate')) {
            errorMessage =
                'Bạn đã có lịch hẹn vào thời gian này.\nVui lòng kiểm tra lại.';
          } else {
            errorMessage = 'Lỗi đặt lịch: $mainMessage';
          }

          // Extract status code and endpoint for debug
          for (String line in lines) {
            if (line.contains('Status Code:')) {
              debugInfo += line.trim() + '\n';
            } else if (line.contains('Endpoint:')) {
              debugInfo += line.trim() + '\n';
            }
          }
        }
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
        debugInfo = 'Network Error: ${e.toString()}';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Kết nối bị timeout. Vui lòng thử lại.';
        debugInfo = 'Timeout Error: ${e.toString()}';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Lỗi định dạng dữ liệu từ server.';
        debugInfo = 'Format Error: ${e.toString()}';
      } else {
        errorMessage = 'Lỗi đặt lịch: ${e.toString()}';
        debugInfo = 'General Error: ${e.toString()}';
      }

      print('🐛 Debug Info: $debugInfo');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (debugInfo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Debug: $debugInfo',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: _getErrorActionLabel(errorMessage),
              textColor: Colors.white,
              onPressed: () => _handleErrorAction(errorMessage),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  String _getErrorActionLabel(String errorMessage) {
    if (errorMessage.contains('không có lịch trống') ||
        errorMessage.contains('not available')) {
      return 'Chọn lại giờ';
    } else if (errorMessage.contains('đăng nhập') ||
        errorMessage.contains('authentication')) {
      return 'Đăng nhập';
    } else if (errorMessage.contains('kết nối mạng') ||
        errorMessage.contains('network')) {
      return 'Thử lại';
    } else if (errorMessage.contains('timeout')) {
      return 'Thử lại';
    } else {
      return 'Copy Error';
    }
  }

  void _handleErrorAction(String errorMessage) {
    if (errorMessage.contains('không có lịch trống') ||
        errorMessage.contains('not available')) {
      // Show detailed dialog before navigating back
      _showDoctorNotAvailableDialog();
    } else if (errorMessage.contains('đăng nhập') ||
        errorMessage.contains('authentication')) {
      // Navigate to login - you might need to implement this navigation
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (errorMessage.contains('kết nối mạng') ||
        errorMessage.contains('network') ||
        errorMessage.contains('timeout')) {
      // Retry booking
      _confirmBooking();
    } else {
      // Copy error to clipboard for debugging
      print('Full error for debugging: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error copied to debug console'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDoctorNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Bác sĩ không có lịch trống'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bác sĩ ${widget.doctor.user?.username ?? 'Unknown'} không có lịch trống vào:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatDate(widget.selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.selectedSlot,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn có thể:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('• Chọn thời gian khác'),
            const Text('• Chọn ngày khác'),
            const Text('• Thử lại sau'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ở lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to time selection
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Chọn lại giờ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dateLabel = DateFormatter.formatDate(widget.selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
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
          const AppointmentProgressIndicator(currentStep: 2),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorAppointmentCard(
                    doctor: widget.doctor,
                    selectedSlot: widget.selectedSlot,
                    selectedDate: dateLabel,
                    showScheduleInfo: true,
                  ),
                  const SizedBox(height: 16),

                  PatientProfileCard(
                    title: 'Thông tin bệnh nhân',
                    patientProfile: widget.patientProfile,
                    showDetailButton: false,
                  ),

                  const SizedBox(height: 16),

                  ExtraInfoDisplay(
                    title: 'Thông tin bổ sung',
                    extraInfoText: widget.extraInfoText,
                    extraImages: widget.extraImages,
                  ),

                  const SizedBox(height: 16),

                  // Chi tiết thanh toán
                  const Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Phí khám',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            Text(
                              _formattedFee,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Phí tiện ích',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            const Text(
                              'Miễn phí',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Tổng thanh toán',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            const Spacer(),
                            Text(
                              _formattedFee,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isBooking ? null : _confirmBooking,
                  child: _isBooking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Xác nhận đặt lịch',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _appointmentController.dispose();
    super.dispose();
  }
}
