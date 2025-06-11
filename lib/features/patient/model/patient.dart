import 'user.dart';
import 'appointment.dart';

class Patient {
  final int patientId;
  final int userId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? phoneNumber;
  final String? insuranceNumber;
  final String? idNumber;
  final bool isVerified;
  final String? otpCode;
  final DateTime? otpExpiry;

  final User? user;
  final List<Appointment>? appointments;

  Patient({
    required this.patientId,
    required this.userId,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.phoneNumber,
    this.insuranceNumber,
    this.idNumber,
    required this.isVerified,
    this.otpCode,
    this.otpExpiry,
    this.user,
    this.appointments,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'] as int,
      userId: json['user_id'] as int,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      insuranceNumber: json['insurance_number'] as String?,
      idNumber: json['id_number'] as String?,
      isVerified: json['is_verified'] as bool,
      otpCode: json['otp_code'] as String?,
      otpExpiry: json['otp_expiry'] != null
          ? DateTime.parse(json['otp_expiry'] as String)
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      appointments: json['appointments'] != null
          ? (json['appointments'] as List)
              .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'patient_id': patientId,
      'user_id': userId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'phone_number': phoneNumber,
      'insurance_number': insuranceNumber,
      'id_number': idNumber,
      'is_verified': isVerified,
      'otp_code': otpCode,
      'otp_expiry': otpExpiry?.toIso8601String(),
    };
    if (user != null) {
      data['user'] = user?.toJson();
    }
    if (appointments != null) {
      data['appointments'] = appointments?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
