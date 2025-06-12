// appointment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutterproject/features/booking/model/appointment.dart';
import 'package:flutterproject/features/booking/model_view/appointment_controller.dart';
import 'package:flutterproject/features/booking/view/booking_page.dart';
import 'package:flutterproject/features/calendar/view_model/calendar_controller.dart';
import 'package:flutterproject/features/authentication/model/patient.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
// import 'package:flutterproject/features/screens/User_info/user_data.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:provider/provider.dart';

/// Chi tiết phiếu khám (Phiếu khám)
class AppointmentDetailPage extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailPage({Key? key, required this.appointment})
      : super(key: key);

  @override
  _AppointmentDetailPageState createState() => _AppointmentDetailPageState();
}

/// Chi tiết phiếu khám (Phiếu khám)
class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final AppointmentController _appointmentController = AppointmentController();

  late int _rating;
  late String _comment;

  // Detailed appointment data from API
  Map<String, dynamic>? _detailedAppointment;
  bool _isLoadingDetails = true;
  String? _errorMessage;

  // Cache for all user appointments
  static List<Map<String, dynamic>>? _cachedUserAppointments;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _rating = widget.appointment.feedback?.rating ?? 0;
    _comment = widget.appointment.feedback?.comment ?? '';
    _loadAppointmentDetails();
    _loadAllUserAppointments();
  }

  /// Load detailed appointment information from API
  Future<void> _loadAppointmentDetails() async {
    try {
      setState(() {
        _isLoadingDetails = true;
        _errorMessage = null;
      });

      final patientController =
          Provider.of<PatientController>(context, listen: false);
      final token = patientController.token;

      print(
          '📋 Loading appointment details for ID: ${widget.appointment.appointmentId}');

      final detailsResponse =
          await _appointmentController.getAppointmentDetailsRaw(
        appointmentId: widget.appointment.appointmentId,
        token: token,
      );

      setState(() {
        _detailedAppointment = detailsResponse;
        _isLoadingDetails = false;

        // Update rating and comment from API response if available
        if (detailsResponse['feedback'] != null) {
          final feedbackData =
              detailsResponse['feedback'] as Map<String, dynamic>;
          _rating = feedbackData['rating'] ?? _rating;
          _comment = feedbackData['comment']?.toString() ?? _comment;
        }
      });

      print('✅ Appointment details loaded successfully');
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải chi tiết cuộc hẹn: $e';
        _isLoadingDetails = false;
      });
      print('❌ Error loading appointment details: $e');
    }
  }

  /// Load all user appointments with pagination and cache them
  Future<void> _loadAllUserAppointments() async {
    try {
      // Check if cache is still valid
      if (_cachedUserAppointments != null &&
          _cacheTimestamp != null &&
          DateTime.now().difference(_cacheTimestamp!) < _cacheExpiry) {
        print(
            '📋 Using cached user appointments (${_cachedUserAppointments!.length} total)');
        return;
      }

      final patientController =
          Provider.of<PatientController>(context, listen: false);
      final token = patientController.token;

      print('📋 Loading all user appointments...');

      final allAppointments =
          await _appointmentController.getAllUserAppointmentsRaw(
        token: token,
        limit:
            10, // Get 10 appointments per page, but automatically fetch all pages
      );

      // Cache the results
      _cachedUserAppointments = allAppointments;
      _cacheTimestamp = DateTime.now();

      print('✅ Loaded and cached ${allAppointments.length} user appointments');
    } catch (e) {
      print('❌ Error loading all user appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Phiếu khám'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: chia sẻ phiếu khám
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointmentDetails,
          ),
          // Debug button for pagination testing
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testPagination,
          ),
        ],
      ),
      body: _isLoadingDetails
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải chi tiết cuộc hẹn...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAppointmentDetails,
                        child: Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAppointmentContent(appointment),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appointment.status == 'scheduled'
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: Colors.red.shade400),
                      ),
                      onPressed: () => _showCancelConfirmation(),
                      child: const Text('Hủy lịch khám',
                          style: TextStyle(color: Colors.red)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48)),
                      onPressed: () {
                        if (appointment.status == 'completed') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingPage(
                                doctorId: appointment.doctor?.doctorId ?? 1,
                              ),
                            ),
                          );
                        } else {
                          _showPaymentDialog();
                        }
                      },
                      child: Text(
                        appointment.status == 'completed'
                            ? 'Đặt lịch khám khác'
                            : _getDisplayStatus(appointment.status),
                      ),
                    ),
              const SizedBox(height: 8),
              Column(
                children: const [
                  Text('Tổng đài hỗ trợ chăm sóc khách hàng',
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('1900-2805',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build appointment content using detailed data if available
  Widget _buildAppointmentContent(Appointment appointment) {
    // Use detailed appointment data if available, otherwise use original data
    final displayData = _detailedAppointment ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // HEADER: Bs. name, QR, STT, Status
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  _getStringValue(
                          displayData['doctor']?['user']?['username']) ??
                      appointment.doctor?.user?.username ??
                      'Unknown Doctor',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('STT',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Text(
                    (displayData['appointment_id'] ?? appointment.appointmentId)
                        .toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(
                          _getStringValue(displayData['status']) ??
                              appointment.status),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _statusColor(
                            _getStringValue(displayData['status']) ??
                                appointment.status)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getDisplayStatus(_getStringValue(displayData['status']) ??
                        appointment.status),
                    style: TextStyle(
                      color: _statusColor(
                          _getStringValue(displayData['status']) ??
                              appointment.status),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Thông tin cơ bản
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(
                  'Ngày khám',
                  _formatDate(
                      _parseDateTime(displayData['appointment_datetime']) ??
                          appointment.appointmentDatetime)),
              const SizedBox(height: 12),
              _infoRow(
                  'Giờ khám',
                  _formatTime(
                      _parseDateTime(displayData['appointment_datetime']) ??
                          appointment.appointmentDatetime)),
              if (_getStringValue(displayData['reason'])?.isNotEmpty == true ||
                  appointment.reason?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _infoRow(
                    'Lý do khám',
                    _getStringValue(displayData['reason']) ??
                        appointment.reason),
              ],
              if (displayData['fees'] != null || appointment.fees != null) ...[
                const SizedBox(height: 12),
                _infoRow('Phí khám',
                    '${_formatCurrency(displayData['fees']) ?? _formatCurrency(appointment.fees)} VND'),
              ],
              if (_getStringValue(displayData['booking_source'])?.isNotEmpty ==
                  true) ...[
                const SizedBox(height: 12),
                _infoRow(
                    'Nguồn đặt lịch',
                    _formatBookingSource(
                        _getStringValue(displayData['booking_source']))),
              ],
              // if (_getStringValue(displayData['arrival_status'])?.isNotEmpty ==
              //     true) ...[
              //   const SizedBox(height: 12),
              //   _infoRow(
              //       'Trạng thái có mặt',
              //       _formatArrivalStatus(
              //           _getStringValue(displayData['arrival_status']))),
              // ],
              if (displayData['checkin_time'] != null) ...[
                const SizedBox(height: 12),
                _infoRow(
                    'Thời gian check-in',
                    _formatDateTime(
                        _parseDateTime(displayData['checkin_time']))),
              ],
            ],
          ),
        ),

        // Rest of the content...
        _buildPatientInfo(displayData, appointment),
        _buildDoctorInfo(displayData, appointment),

        if (_getStringValue(displayData['status']) == 'completed' ||
            appointment.status == 'completed')
          _buildCompletedAppointmentDetails(displayData, appointment),
      ],
    );
  }

  /// Build patient information section
  Widget _buildPatientInfo(
      Map<String, dynamic> displayData, Appointment appointment) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin bệnh nhân',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    _getStringValue(displayData['patient']?['user']?['avatar'])
                                    ?.isNotEmpty ==
                                true ||
                            appointment.patient?.user?.avatar?.isNotEmpty ==
                                true
                        ? NetworkImage(_getStringValue(
                                displayData['patient']?['user']?['avatar']) ??
                            appointment.patient!.user!.avatar)
                        : null,
                child:
                    _getStringValue(displayData['patient']?['user']?['avatar'])
                                    ?.isEmpty !=
                                false &&
                            appointment.patient?.user?.avatar?.isEmpty != false
                        ? const Icon(Icons.person)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStringValue(
                              displayData['patient']?['user']?['username']) ??
                          appointment.patient?.user?.username ??
                          'Không có tên',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    if (_getStringValue(displayData['patient']?['phone_number'])
                                ?.isNotEmpty ==
                            true ||
                        appointment.patient?.phoneNumber?.isNotEmpty == true)
                      Text(
                        'SĐT: ${_getStringValue(displayData['patient']?['phone_number']) ?? appointment.patient!.phoneNumber}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 4),
                    if (_getStringValue(displayData['patient']?['gender'])
                                ?.isNotEmpty ==
                            true ||
                        appointment.patient?.gender != null)
                      Text(
                        'Giới tính: ${_formatGender(_getStringValue(displayData['patient']?['gender'])) ?? _formatGenderEnum(appointment.patient?.gender)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    if (_getStringValue(
                                    displayData['patient']?['date_of_birth'])
                                ?.isNotEmpty ==
                            true ||
                        appointment.patient?.dateOfBirth != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Ngày sinh: ${_formatBirthDate(_getStringValue(displayData['patient']?['date_of_birth'])) ?? _formatBirthDateFromDateTime(appointment.patient?.dateOfBirth)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build doctor information section
  Widget _buildDoctorInfo(
      Map<String, dynamic> displayData, Appointment appointment) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bác sĩ khám',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 22,
              backgroundImage:
                  _getStringValue(displayData['doctor']?['user']?['avatar'])
                                  ?.isNotEmpty ==
                              true ||
                          appointment.doctor?.user?.avatar?.isNotEmpty == true
                      ? NetworkImage(_getStringValue(
                              displayData['doctor']?['user']?['avatar']) ??
                          appointment.doctor!.user!.avatar)
                      : null,
              child: _getStringValue(displayData['doctor']?['user']?['avatar'])
                              ?.isEmpty !=
                          false &&
                      appointment.doctor?.user?.avatar?.isEmpty != false
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              _getStringValue(displayData['doctor']?['user']?['username']) ??
                  appointment.doctor?.user?.username ??
                  'Unknown Doctor',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _getStringValue(
                      displayData['doctor']?['specialization']?['name']) ??
                  appointment.doctor?.specialization?.name ??
                  'General',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  /// Build completed appointment details (medical records, prescriptions, payments, feedback)
  Widget _buildCompletedAppointmentDetails(
      Map<String, dynamic> displayData, Appointment appointment) {
    return Column(
      children: [
        // Medical Record Section
        _sectionHeader(context, Icons.description, 'Medical Record'),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(
                  'Diagnosis',
                  _getStringValue(
                          displayData['medical_record']?['diagnosis']) ??
                      appointment.medicalRecord?.diagnosis),
              const SizedBox(height: 8),
              _infoRow(
                  'Treatment',
                  _getStringValue(
                          displayData['medical_record']?['treatment']) ??
                      appointment.medicalRecord?.treatment),
              const SizedBox(height: 8),
              _infoRow(
                  'Notes',
                  _getStringValue(displayData['medical_record']?['notes']) ??
                      appointment.medicalRecord?.notes),
            ],
          ),
        ),

        // Prescription Section
        _sectionHeader(context, Icons.medical_services, 'Prescription'),
        _sectionCard(
          child: _infoRow(
              'Medicine Details',
              _getStringValue(
                      displayData['prescription']?['medicine_details']) ??
                  appointment.prescription?.medicineDetails),
        ),

        // Payment Section
        _sectionHeader(context, Icons.payment, 'Payment'),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(
                  'Amount',
                  _getStringValue(displayData['payment']?['amount']) ??
                      appointment.payment?.amount.toString()),
              const SizedBox(height: 8),
              _infoRow(
                  'Status',
                  _getStringValue(displayData['payment']?['status']) ??
                      appointment.payment?.status),
              const SizedBox(height: 8),
              _infoRow(
                  'Method',
                  _getStringValue(displayData['payment']?['payment_method']) ??
                      appointment.payment?.paymentMethod),
            ],
          ),
        ),

        // Feedback Section
        _sectionHeader(context, Icons.feedback, 'Feedback'),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text('$_rating / 5',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              if (_comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _comment,
                  style: const TextStyle(color: Colors.black87),
                  softWrap: true,
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _showFeedbackDialog,
                  child: const Text('Update Feedback'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper method to safely get string values
  String? _getStringValue(dynamic value) {
    return value?.toString();
  }

  /// Helper method to parse datetime
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      final String dateTimeString = value.toString();

      // Handle API format: "09:30:00 6/4/2025"
      if (dateTimeString.contains(' ') && dateTimeString.contains('/')) {
        final parts = dateTimeString.split(' ');
        if (parts.length == 2) {
          final timePart = parts[0]; // "09:30:00"
          final datePart = parts[1]; // "6/4/2025"

          final dateParts = datePart.split('/');
          if (dateParts.length == 3) {
            final day = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final year = int.parse(dateParts[2]);

            final timeParts = timePart.split(':');
            if (timeParts.length >= 2) {
              final hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);
              final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

              return DateTime(year, month, day, hour, minute, second);
            }
          }
        }
      }

      // Handle ISO format: "2025-04-06T02:25:00.000Z"
      return DateTime.parse(dateTimeString);
    } catch (e) {
      print('❌ Error parsing datetime "$value": $e');
      return null;
    }
  }

  /// Tiêu đề section với icon
  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Widget Card section
  Widget _sectionCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  /// Row đơn giản label-value, với wrap text tránh overflow
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w500),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final ratingController = TextEditingController(text: _rating.toString());
    final commentController = TextEditingController(text: _comment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Feedback'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rating (1-5)'),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRating = int.tryParse(ratingController.text) ?? _rating;
              setState(() {
                _rating = newRating.clamp(1, 5);
                _comment = commentController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Màu badge theo trạng thái
  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'scheduled':
        return AppColors.primary;
      case 'cancelled':
        return Colors.orange;
      case 'no_show':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Map API status to display status
  String _getDisplayStatus(String apiStatus) {
    switch (apiStatus) {
      case 'scheduled':
        return 'Chờ khám';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'no_show':
        return 'Không đến';
      default:
        return apiStatus;
    }
  }

  /// Format date to dd/MM/yyyy
  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  /// Format time to HH:mm-HH:mm (assuming 10 minutes duration)
  String _formatTime(DateTime dateTime) {
    final startHour = dateTime.hour.toString().padLeft(2, '0');
    final startMinute = dateTime.minute.toString().padLeft(2, '0');
    final endTime = dateTime.add(const Duration(minutes: 10));
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute-$endHour:$endMinute';
  }

  /// Show cancel confirmation dialog
  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy lịch'),
        content: const Text(
            'Bạn có chắc chắn muốn hủy lịch khám này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cancelAppointment();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Hủy lịch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Cancel appointment
  Future<void> _cancelAppointment() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call calendar controller to cancel appointment
      final calendarController = CalendarController();
      final success = await calendarController
          .cancelAppointment(widget.appointment.appointmentId);

      Navigator.of(context).pop(); // Close loading

      if (success) {
        // Show success and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy lịch khám thành công')),
        );
        Navigator.of(context).pop(); // Go back to previous screen
      } else {
        throw Exception('Không thể hủy lịch khám');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  /// Show payment dialog
  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Phí khám: ${widget.appointment.fees} VND'),
            const SizedBox(height: 16),
            const Text('Chọn phương thức thanh toán:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment();
            },
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );
  }

  /// Process payment
  Future<void> _processPayment() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // TODO: Implement payment API call
      // await calendarController.getAppointmentForPayment(widget.appointment.appointmentId);

      Navigator.of(context).pop(); // Close loading

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán thành công')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi thanh toán: $e')),
      );
    }
  }

  /// Helper method to format gender string
  String? _formatGender(String? gender) {
    if (gender == null) return null;
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  /// Helper method to format gender enum
  String? _formatGenderEnum(Gender? gender) {
    if (gender == null) return null;
    switch (gender) {
      case Gender.male:
        return 'Nam';
      case Gender.female:
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  /// Helper method to format birth date string
  String? _formatBirthDate(String? birthDate) {
    if (birthDate == null) return null;
    try {
      final date = DateTime.parse(birthDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return birthDate;
    }
  }

  /// Helper method to format birth date from DateTime
  String? _formatBirthDateFromDateTime(DateTime? birthDate) {
    if (birthDate == null) return null;
    return '${birthDate.day.toString().padLeft(2, '0')}/${birthDate.month.toString().padLeft(2, '0')}/${birthDate.year}';
  }

  /// Helper method to format currency
  String? _formatCurrency(dynamic value) {
    if (value == null) return null;
    try {
      final amount = int.parse(value.toString());
      return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } catch (e) {
      return value.toString();
    }
  }

  /// Helper method to format booking source
  String _formatBookingSource(String? source) {
    switch (source?.toLowerCase()) {
      case 'online':
        return 'Đặt lịch online';
      case 'offline':
        return 'Đặt lịch tại bệnh viện';
      case 'phone':
        return 'Đặt lịch qua điện thoại';
      default:
        return source ?? 'Không xác định';
    }
  }

  /// Helper method to format arrival status
  String _formatArrivalStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'arrived':
        return 'Đã có mặt';
      case 'not_arrived':
        return 'Chưa có mặt';
      case 'no_show':
        return 'Không đến';
      default:
        return status ?? 'Không xác định';
    }
  }

  /// Helper method to format full datetime
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  /// Test pagination functionality
  Future<void> _testPagination() async {
    try {
      final patientController =
          Provider.of<PatientController>(context, listen: false);
      final token = patientController.token;

      print('\n🧪 === USER INITIATED PAGINATION TEST ===');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Testing pagination...\nCheck console for details'),
            ],
          ),
        ),
      );

      // Run the demo pagination
      await _appointmentController.demoPagination(token: token);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show result dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pagination Test Complete'),
            content: Text(
                'Check the console output to see detailed pagination logs with page-by-page fetching information.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pagination test failed: $e')),
        );
      }
      print('❌ Pagination test error: $e');
    }
  }
}
