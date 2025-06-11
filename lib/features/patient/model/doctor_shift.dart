import 'doctor.dart';

class DoctorShift {
  final int shiftId;
  final int doctorId;
  final DateTime shiftDate;
  final String shiftType; // "morning" or "afternoon"
  final String startTime; // format "HH:mm:ss"
  final String endTime;   // format "HH:mm:ss"
  final Doctor? doctor;

  DoctorShift({
    required this.shiftId,
    required this.doctorId,
    required this.shiftDate,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    this.doctor,
  });

  factory DoctorShift.fromJson(Map<String, dynamic> json) {
    return DoctorShift(
      shiftId: json['shift_id'] as int,
      doctorId: json['doctor_id'] as int,
      shiftDate: DateTime.parse(json['shift_date'] as String),
      shiftType: json['shift_type'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      doctor: json['doctor'] != null
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift_id': shiftId,
      'doctor_id': doctorId,
      'shift_date': shiftDate.toIso8601String().split('T').first,
      'shift_type': shiftType,
      'start_time': startTime,
      'end_time': endTime,
      if (doctor != null) 'doctor': doctor!.toJson(),
    };
  }
}
