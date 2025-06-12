import '../../booking/model/appointment.dart';

class Prescription {
  final int prescriptionId;
  final int appointmentId;
  final String medicineDetails;
  final Appointment? appointment;

  Prescription({
    required this.prescriptionId,
    required this.appointmentId,
    required this.medicineDetails,
    this.appointment,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      prescriptionId: json['prescription_id'] as int,
      appointmentId: json['appointment_id'] as int,
      medicineDetails: json['medicine_details'] as String,
      appointment: json['appointment'] != null
          ? Appointment.fromJson(json['appointment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'prescription_id': prescriptionId,
      'appointment_id': appointmentId,
      'medicine_details': medicineDetails,
    };
    if (appointment != null) {
      data['appointment'] = appointment!.toJson();
    }
    return data;
  }
}