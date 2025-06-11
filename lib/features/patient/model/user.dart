import 'patient.dart';
import 'doctor.dart';
// import 'admin_model.dart';

class User {
  final int userId;
  final String username;
  final String email;
  final String? password;
  final String avatar;
  final String role; // "patient", "doctor", "admin"

  final Patient? patient;
  final Doctor? doctor;
  //final Admin? admin;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.password,
    required this.avatar,
    required this.role,
    this.patient,
    this.doctor,
    // this.admin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      avatar: json['avatar'] as String,
      role: json['role'] as String,
      patient: json['patient'] != null
          ? Patient.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
      doctor: json['doctor'] != null
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      // admin: json['admin'] != null
      //     ? Admin.fromJson(json['admin'] as Map<String, dynamic>)
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'user_id': userId,
      'username': username,
      'email': email,
      if (password != null) 'password': password,
      'avatar': avatar,
      'role': role,
    };
    if (patient != null) data['patient'] = patient!.toJson();
    if (doctor != null) data['doctor'] = doctor!.toJson();
    // if (admin != null) data['admin'] = admin!.toJson();
    return data;
  }
}