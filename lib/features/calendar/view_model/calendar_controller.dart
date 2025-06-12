import 'package:flutter/material.dart';
import '../../booking/model/appointment.dart';
import '../../booking/model_view/appointment_controller.dart';
import '../../authentication/model_view/patient_controller.dart';
import '../../patient/model_view/feedback_controller.dart';
import '../../patient/model_view/payment_controller.dart';
import '../../patient/model_view/medicalrecord_controller.dart';
import '../../patient/model_view/prescription_controller.dart';

class CalendarController extends ChangeNotifier {
  final AppointmentController _appointmentController;
  final PatientController _patientController;
  final FeedbackService _feedbackService;
  final PaymentService _paymentService;
  final MedicalRecordService _medicalRecordService;
  final PrescriptionService _prescriptionService;

  CalendarController({
    AppointmentController? appointmentController,
    PatientController? patientController,
    FeedbackService? feedbackService,
    PaymentService? paymentService,
    MedicalRecordService? medicalRecordService,
    PrescriptionService? prescriptionService,
  })  : _appointmentController =
            appointmentController ?? AppointmentController(),
        _patientController = patientController ?? PatientController(),
        _feedbackService = feedbackService ?? FeedbackService(),
        _paymentService = paymentService ?? PaymentService(),
        _medicalRecordService = medicalRecordService ?? MedicalRecordService(),
        _prescriptionService = prescriptionService ?? PrescriptionService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  List<Appointment> _filteredAppointments = [];
  List<Appointment> get filteredAppointments => _filteredAppointments;

  String? _error;
  String? get error => _error;

  // Filter states
  String _selectedStatus = 'Tất cả';
  String get selectedStatus => _selectedStatus;

  String _selectedPaymentStatus = 'Tất cả';
  String get selectedPaymentStatus => _selectedPaymentStatus;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  final List<String> _statuses = [
    'Tất cả',
    'scheduled',
    'completed',
    'cancelled',
    'no_show',
  ];
  List<String> get statuses => _statuses;

  final List<String> _paymentStatuses = [
    'Tất cả',
    'paid',
    'pending',
  ];
  List<String> get paymentStatuses => _paymentStatuses;

  /// Fetch appointments from API
  Future<void> fetchAppointments() async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;
      _appointments =
          await _appointmentController.getUserAppointments(token: token);
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      _appointments = [];
      _filteredAppointments = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Get appointment details
  Future<Appointment?> getAppointmentDetails(int appointmentId) async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;
      return await _appointmentController.getAppointmentDetails(appointmentId,
          token: token);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update feedback for an appointment
  Future<bool> updateFeedback({
    required int appointmentId,
    required int rating,
    String? comment,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;

      // Check if feedback exists, if not create new one
      await _feedbackService.addFeedback(
        appointmentId: appointmentId,
        rating: rating,
        comment: comment,
        token: token,
      );

      // Refresh appointments to get updated data
      await fetchAppointments();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get detailed appointment information with all related data
  Future<Appointment?> getDetailedAppointmentInfo(int appointmentId) async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;

      // Get basic appointment details first
      final appointment = await _appointmentController
          .getAppointmentDetails(appointmentId, token: token);

      // For completed appointments, try to fetch additional details
      if (appointment.status == 'completed') {
        try {
          // Try to fetch medical record
          final medicalRecord =
              await _medicalRecordService.getMedicalRecordForAppointment(
            appointmentId: appointmentId,
            token: token,
          );

          // Try to fetch prescription
          final prescription =
              await _prescriptionService.getPrescriptionForAppointment(
            appointmentId: appointmentId,
            token: token,
          );

          // Try to fetch feedback
          final feedback = await _feedbackService.getFeedbackForAppointment(
            appointmentId: appointmentId,
            token: token,
          );

          // Create enhanced appointment with additional data
          return Appointment(
            appointmentId: appointment.appointmentId,
            patientId: appointment.patientId,
            doctorId: appointment.doctorId,
            bookingSource: appointment.bookingSource,
            reason: appointment.reason,
            appointmentDatetime: appointment.appointmentDatetime,
            status: appointment.status,
            arrivalStatus: appointment.arrivalStatus,
            checkinTime: appointment.checkinTime,
            fees: appointment.fees,
            patient: appointment.patient,
            doctor: appointment.doctor,
            feedback: feedback,
            prescription: prescription,
            payment: appointment.payment,
            medicalRecord: medicalRecord,
          );
        } catch (e) {
          print('⚠️ Warning: Could not fetch some additional details: $e');
          // Return the basic appointment if we can't fetch additional details
          return appointment;
        }
      }

      return appointment;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get payment information for an appointment
  Future<Map<String, dynamic>?> getPaymentInfo(int appointmentId) async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;

      final paymentInfo = await _paymentService.paymentForAppointment(
        appointmentId: appointmentId,
        token: token,
      );

      return paymentInfo;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel appointment by patient
  Future<bool> cancelAppointment(int appointmentId) async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;

      await _appointmentController.cancelAppointmentByPatient(appointmentId,
          token: token);

      // Refresh appointments to get updated data
      await fetchAppointments();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Book appointment online
  Future<bool> bookAppointmentOnline({
    required int doctorId,
    required DateTime appointmentDatetime,
    String? reason,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;

      // Format datetime to backend expected format
      final formattedDatetime = appointmentDatetime.toIso8601String();

      await _appointmentController.bookAppointmentOnline(
        doctorId: doctorId,
        appointmentDatetime: formattedDatetime,
        reason: reason,
        token: token,
      );

      // Refresh appointments to get updated data
      await fetchAppointments();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get appointment for payment
  Future<Appointment?> getAppointmentForPayment(int appointmentId) async {
    _setLoading(true);
    _error = null;

    try {
      // Ensure we have token
      if (_patientController.token == null) {
        await _patientController.isAuthenticated();
      }
      final token = _patientController.token;

      return await _appointmentController
          .getAppointmentForPayment(appointmentId, token: token);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Set status filter
  void setStatusFilter(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  /// Set payment status filter
  void setPaymentStatusFilter(String paymentStatus) {
    _selectedPaymentStatus = paymentStatus;
    _applyFilters();
  }

  /// Set date filter
  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
  }

  /// Clear date filter
  void clearDateFilter() {
    _selectedDate = null;
    _applyFilters();
  }

  /// Apply all filters
  void _applyFilters() {
    _filteredAppointments = _appointments.where((appointment) {
      // Status filter
      final statusMatch = _selectedStatus == 'Tất cả' ||
          _mapApiStatusToDisplayStatus(appointment.status) == _selectedStatus;

      // Date filter
      final dateMatch = _selectedDate == null ||
          _isSameDay(appointment.appointmentDatetime, _selectedDate!);

      // Payment status filter
      final paymentMatch = _selectedPaymentStatus == 'Tất cả' ||
          (appointment.payment != null &&
              appointment.payment!.status == _selectedPaymentStatus);

      return statusMatch && dateMatch && paymentMatch;
    }).toList();

    notifyListeners();
  }

  /// Map API status to display status
  String _mapApiStatusToDisplayStatus(String apiStatus) {
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

  /// Map display status to API status
  String _mapDisplayStatusToApiStatus(String displayStatus) {
    switch (displayStatus) {
      case 'Chờ khám':
        return 'scheduled';
      case 'Hoàn thành':
        return 'completed';
      case 'Đã hủy':
        return 'cancelled';
      case 'Không đến':
        return 'no_show';
      default:
        return displayStatus;
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Format date to dd/MM/yyyy
  String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  /// Format time to HH:mm
  String formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Get appointment time range (assuming 10 minutes duration)
  String getTimeRange(DateTime dateTime) {
    final startTime = formatTime(dateTime);
    final endTime = formatTime(dateTime.add(const Duration(minutes: 10)));
    return '$startTime-$endTime';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _appointmentController.dispose();
    super.dispose();
  }
}
