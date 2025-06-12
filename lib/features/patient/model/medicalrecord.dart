import '../../booking/model/appointment.dart';

class MedicalRecord {
  final int recordId;
  final int appointmentId;
  final String diagnosis;
  final String treatment;
  final String? notes;
  final Appointment? appointment;

  MedicalRecord({
    required this.recordId,
    required this.appointmentId,
    required this.diagnosis,
    required this.treatment,
    this.notes,
    this.appointment,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      recordId: json['record_id'] as int,
      appointmentId: json['appointment_id'] as int,
      diagnosis: json['diagnosis'] as String,
      treatment: json['treatment'] as String,
      notes: json['notes'] as String?,
      appointment: json['appointment'] != null
          ? Appointment.fromJson(json['appointment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_id': recordId,
      'appointment_id': appointmentId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
      if (appointment != null) 'appointment': appointment!.toJson(),
    };
  }
}