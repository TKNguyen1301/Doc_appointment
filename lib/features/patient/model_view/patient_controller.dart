import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/patient.dart';

class PatientService {
  final String baseUrl;
  final http.Client _client;

  PatientService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Patient> registerPatient({
    required String username,
    required String password,
    required String email,
  }) async {
    final uri = Uri.parse('$baseUrl/patients/register');
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );
    if (response.statusCode == 201) {
      return Patient.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to register patient: ${response.body}');
  }

  Future<bool> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/patients/verify?email=$email&otp_code=$otpCode',
    );
    final response = await _client.get(uri);
    if (response.statusCode == 302) {
      // redirected to login
      return true;
    }
    if (response.statusCode == 400) {
      return false;
    }
    throw HttpException('Email verification error: ${response.body}');
  }

  Future<Map<String, dynamic>> loginPatient({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/patients/login');
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to login: ${response.body}');
  }

  Future<void> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/patients/change-password');
    final response = await _client.put(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      throw HttpException('Password change failed: ${response.body}');
    }
  }

  Future<List<Patient>> getAllPatients() async {
    final uri = Uri.parse('$baseUrl/patients');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => Patient.fromJson(e)).toList();
    }
    throw HttpException('Failed to fetch patients: ${response.body}');
  }

  Future<Patient> getPatientProfile({required int userId}) async {
    final uri = Uri.parse('$baseUrl/patients/profile');
    final response = await _client.get(uri,
      headers: {HttpHeaders.authorizationHeader: 'Bearer <token>'},
    );
    if (response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to fetch profile: ${response.body}');
  }

  Future<Patient> updatePatientProfile({
    required int userId,
    Map<String, dynamic>? data,
    File? avatarFile,
  }) async {
    if (avatarFile != null) {
      final uri = Uri.parse('$baseUrl/patients/profile');
      final request = http.MultipartRequest('PUT', uri)
        ..headers[HttpHeaders.authorizationHeader] = 'Bearer <token>'
        ..fields.addAll(data?.map((k, v) => MapEntry(k, v.toString())) ?? {})
        ..files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
            filename: avatarFile.path.split('/').last,
          ),
        );
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        return Patient.fromJson(jsonDecode(res.body));
      }
      throw HttpException('Profile update failed: ${res.body}');
    } else {
      final uri = Uri.parse('$baseUrl/patients/profile');
      final response = await _client.put(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return Patient.fromJson(jsonDecode(response.body));
      }
      throw HttpException('Profile update failed: ${response.body}');
    }
  }

  Future<List<dynamic>> getPatientAppointments({
    required int userId,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/patients/appointments'
      '${queryParams != null ? '?' + Uri(queryParameters: queryParams).query : ''}',
    );
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }
    throw HttpException('Failed to load appointments: ${response.body}');
  }

  Future<List<dynamic>> getPatientPayments({
    required int userId,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/patients/payments'
      '${queryParams != null ? '?' + Uri(queryParameters: queryParams).query : ''}',
    );
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }
    throw HttpException('Failed to load payments: ${response.body}');
  }

  Future<Map<String, dynamic>> getDoctorProfileByPatient({
    required int doctorUserId,
  }) async {
    final uri = Uri.parse('$baseUrl/patients/$doctorUserId/doctor-profile');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to load doctor profile: ${response.body}');
  }

  Future<List<dynamic>> getDoctorAppointmentsByPatient({
    required int doctorUserId,
  }) async {
    final uri = Uri.parse('$baseUrl/patients/$doctorUserId/doctor-appointments');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }
    throw HttpException('Failed to load doctor appointments: ${response.body}');
  }

  Future<Map<String, dynamic>> getPaymentById({
    required int paymentId,
  }) async {
    final uri = Uri.parse('$baseUrl/patients/payments/$paymentId');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to load payment: ${response.body}');
  }
}
