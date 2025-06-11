import 'package:flutter/foundation.dart';
import 'user.dart';
import 'appointment.dart';
import 'medicalrecord.dart';
import 'prescription.dart';
import 'feedback.dart';
import 'payment.dart';

enum Gender { male, female, other }

class Patient {
  final int patientId;
  final int userId;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? address;
  final String? phoneNumber;
  final String? insuranceNumber;
  final String? idNumber;
  final String? otpCode;
  final DateTime? otpExpiry;

  // Associations
  final User? user;
  final List<Appointment>? appointments;
  final List<MedicalRecord>? medicalRecords;
  final List<Prescription>? prescriptions;
  final List<Feedback>? feedbacks;
  final List<Payment>? payments;

  Patient({
    required this.patientId,
    required this.userId,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.phoneNumber,
    this.insuranceNumber,
    this.idNumber,
    this.otpCode,
    this.otpExpiry,
    this.user,
    this.appointments,
    this.medicalRecords,
    this.prescriptions,
    this.feedbacks,
    this.payments,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        patientId: json['patient_id'] as int,
        userId: json['user_id'] as int,
        dateOfBirth: json['date_of_birth'] != null
            ? DateTime.parse(json['date_of_birth'] as String)
            : null,
        gender: json['gender'] != null
            ? Gender.values.firstWhere(
                (g) => describeEnum(g) == json['gender'],
                orElse: () => Gender.other,
              )
            : null,
        address: json['address'] as String?,
        phoneNumber: json['phone_number'] as String?,
        insuranceNumber: json['insurance_number'] as String?,
        idNumber: json['id_number'] as String?,
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
        medicalRecords: json['medical_records'] != null
            ? (json['medical_records'] as List)
                .map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        prescriptions: json['prescriptions'] != null
            ? (json['prescriptions'] as List)
                .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        feedbacks: json['feedbacks'] != null
            ? (json['feedbacks'] as List)
                .map((e) => Feedback.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        payments: json['payments'] != null
            ? (json['payments'] as List)
                .map((e) => Payment.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'user_id': userId,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'gender': gender != null ? describeEnum(gender!) : null,
        'address': address,
        'phone_number': phoneNumber,
        'insurance_number': insuranceNumber,
        'id_number': idNumber,
        'otp_code': otpCode,
        'otp_expiry': otpExpiry?.toIso8601String(),
        'user': user?.toJson(),
        'appointments': appointments?.map((e) => e.toJson()).toList(),
        'medical_records': medicalRecords?.map((e) => e.toJson()).toList(),
        'prescriptions': prescriptions?.map((e) => e.toJson()).toList(),
        'feedbacks': feedbacks?.map((e) => e.toJson()).toList(),
        'payments': payments?.map((e) => e.toJson()).toList(),
      };
}
