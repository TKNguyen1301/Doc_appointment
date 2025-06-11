import '../../authentication/model/user.dart';
import 'specialization.dart';
import 'doctor_shift.dart';
import 'appointment.dart';

class Doctor {
  final int doctorId;
  final int userId;
  final int? specializationId;
  final String degree;
  final int experienceYears;
  final String description;
  final double rating;

  final User? user;
  final Specialization? specialization;
  final List<DoctorShift>? doctorShifts;
  final List<Appointment>? appointments;

  Doctor({
    required this.doctorId,
    required this.userId,
    this.specializationId,
    required this.degree,
    required this.experienceYears,
    required this.description,
    required this.rating,
    this.user,
    this.specialization,
    this.doctorShifts,
    this.appointments,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctor_id'] as int,
      userId: json['user_id'] as int,
      specializationId: json['specialization_id'] as int?,
      degree: json['degree'] as String,
      experienceYears: json['experience_years'] as int,
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      specialization: json['specialization'] != null
          ? Specialization.fromJson(
              json['specialization'] as Map<String, dynamic>)
          : null,
      doctorShifts: json['doctor_shifts'] != null
          ? (json['doctor_shifts'] as List)
              .map((e) => DoctorShift.fromJson(e))
              .toList()
          : null,
      appointments: json['appointments'] != null
          ? (json['appointments'] as List)
              .map((e) => Appointment.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'user_id': userId,
      'specialization_id': specializationId,
      'degree': degree,
      'experience_years': experienceYears,
      'description': description,
      'rating': rating,
      if (user != null) 'user': user!.toJson(),
      if (specialization != null) 'specialization': specialization!.toJson(),
      if (doctorShifts != null)
        'doctor_shifts': doctorShifts!.map((e) => e.toJson()).toList(),
      if (appointments != null)
        'appointments': appointments!.map((e) => e.toJson()).toList(),
    };
  }
}