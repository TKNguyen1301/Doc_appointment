import 'patient.dart';
import 'doctor.dart';
import 'feedback.dart';
import 'prescription.dart';
import 'payment.dart';
import 'medicalrecord.dart';

class Appointment {
  final int appointmentId;
  final int patientId;
  final int doctorId;
  final String bookingSource; // "online" or "offline"
  final String? reason;
  final DateTime appointmentDatetime;
  final String status; // "scheduled", "completed", "cancelled", "no_show"
  final String arrivalStatus; // "pending", "arrived", "no_show"
  final DateTime? checkinTime;
  final int fees;

  final Patient? patient;
  final Doctor? doctor;
  final Feedback? feedback;
  final Prescription? prescription;
  final Payment? payment;
  final MedicalRecord? medicalRecord;

  Appointment({
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.bookingSource,
    this.reason,
    required this.appointmentDatetime,
    required this.status,
    required this.arrivalStatus,
    this.checkinTime,
    required this.fees,
    this.patient,
    this.doctor,
    this.feedback,
    this.prescription,
    this.payment,
    this.medicalRecord,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'] as int,
      patientId: json['patient_id'] as int,
      doctorId: json['doctor_id'] as int,
      bookingSource: json['booking_source'] as String,
      reason: json['reason'] as String?,
      appointmentDatetime: DateTime.parse(json['appointment_datetime'] as String),
      status: json['status'] as String,
      arrivalStatus: json['arrival_status'] as String,
      checkinTime: json['checkin_time'] != null
          ? DateTime.parse(json['checkin_time'] as String)
          : null,
      fees: json['fees'] as int,
      patient: json['patient'] != null
          ? Patient.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
      doctor: json['doctor'] != null
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      feedback: json['feedback'] != null
          ? Feedback.fromJson(json['feedback'] as Map<String, dynamic>)
          : null,
      prescription: json['prescription'] != null
          ? Prescription.fromJson(json['prescription'] as Map<String, dynamic>)
          : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      medicalRecord: json['medical_record'] != null
          ? MedicalRecord.fromJson(json['medical_record'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'booking_source': bookingSource,
      'reason': reason,
      'appointment_datetime': appointmentDatetime.toIso8601String(),
      'status': status,
      'arrival_status': arrivalStatus,
      'checkin_time': checkinTime?.toIso8601String(),
      'fees': fees,
      if (patient != null) 'patient': patient!.toJson(),
      if (doctor != null) 'doctor': doctor!.toJson(),
      if (feedback != null) 'feedback': feedback!.toJson(),
      if (prescription != null) 'prescription': prescription!.toJson(),
      if (payment != null) 'payment': payment!.toJson(),
      if (medicalRecord != null) 'medical_record': medicalRecord!.toJson(),
    };
  }
}
