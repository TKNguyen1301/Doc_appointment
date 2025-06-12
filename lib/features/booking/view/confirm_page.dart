import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterproject/features/booking/view/booking_result_page.dart';
import 'package:flutterproject/features/booking/model_view/appointment_controller.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
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
    if (widget.doctor.specialization?.fees != null && widget.doctor.specialization!.fees > 0) {
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

    try {
      final patientController = Provider.of<PatientController>(context, listen: false);
      final token = patientController.token;
      final userId = patientController.profile?.user?.userId;

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final appointment = await _appointmentController.createAppointment(
        userId: userId,
        doctorId: widget.doctor.doctorId,
        appointmentDatetime: widget.appointmentDateTime,
        reason: widget.extraInfoText.isNotEmpty ? widget.extraInfoText : null,
        token: token,
        fees: _calculatedFee, // Truyền fee đã tính toán
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingResultPage(
              appointment: appointment,
              doctor: widget.doctor,
              selectedDate: widget.selectedDate,
              selectedSlot: widget.selectedSlot,
              patientProfile: widget.patientProfile,
              extraInfoText: widget.extraInfoText,
              extraImages: widget.extraImages,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đặt lịch: ${e.toString()}'),
            backgroundColor: Colors.red,
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
                              _formattedFee,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Phí tiện ích', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            const Spacer(),
                            const Text(
                              'Miễn phí',
                              style: TextStyle(fontSize: 14, color: Colors.black87),
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            const Spacer(),
                            Text(
                              _formattedFee,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isBooking ? null : _confirmBooking,
                  child: _isBooking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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