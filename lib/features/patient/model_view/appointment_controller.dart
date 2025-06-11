import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/appointment.dart';

class AppointmentService {
  final String baseUrl;
  final http.Client _client;

  AppointmentService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Appointment> bookAppointmentOnline({
    required int userId,
    required int doctorId,
    required DateTime appointmentDatetime,
    String? reason,
  }) async {
    final uri = Uri.parse('$baseUrl/appointments/book-online');
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'doctor_id': doctorId,
        'appointment_datetime': appointmentDatetime.toIso8601String(),
        'reason': reason,
      }),
    );
    if (response.statusCode == 201) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to book online: \${response.body}');
  }

  Future<Appointment> acceptAppointment(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/appointments/\$appointmentId/accept');
    final response = await _client.put(uri);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to accept appointment: \${response.body}');
  }

  Future<Appointment> cancelAppointmentByPatient(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/appointments/\$appointmentId/cancel-patient');
    final response = await _client.put(uri);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to cancel by patient: \${response.body}');
  }

  Future<Appointment> cancelAppointmentByDoctor(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/appointments/\$appointmentId/cancel-doctor');
    final response = await _client.put(uri);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to cancel by doctor: \${response.body}');
  }

  Future<Appointment> completeAppointment(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/appointments/\$appointmentId/complete');
    final response = await _client.put(uri);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to complete appointment: \${response.body}');
  }

  Future<Appointment> markPatientNotComing(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/appointments/\$appointmentId/no-show');
    final response = await _client.put(uri);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to mark no-show: \${response.body}');
  }

  Future<List<Appointment>> getAllAppointments() async {
    final uri = Uri.parse('$baseUrl/appointments');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Appointment.fromJson(e)).toList();
    }
    throw HttpException('Failed to fetch appointments: \${response.body}');
  }

  Future<List<Appointment>> getPaidAppointments() async {
    final uri = Uri.parse('$baseUrl/appointments/paid');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Appointment.fromJson(e)).toList();
    }
    throw HttpException('Failed to fetch paid appointments: \${response.body}');
  }

  Future<Appointment> getAppointmentDetails(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/appointments/\$appointmentId');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to fetch details: \${response.body}');
  }

  Future<List<Appointment>> getAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    DateTime? date,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
      if (date != null) 'date': date.toIso8601String().split('T').first,
    };
    final uri = Uri.parse('$baseUrl/appointments').replace(queryParameters: params);
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Appointment.fromJson(e)).toList();
    }
    throw HttpException('Failed to fetch paginated appointments: \${response.body}');
  }

  Future<Map<String, dynamic>> getAppointmentsStats() async {
    final uri = Uri.parse('$baseUrl/appointments/stats');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to fetch stats: \${response.body}');
  }

  Future<Appointment> bookAppointmentOffline({
    required int patientId,
    required int doctorId,
    String? reason,
  }) async {
    final uri = Uri.parse('$baseUrl/appointments/book-offline');
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'patient_id': patientId,
        'doctor_id': doctorId,
        'reason': reason,
      }),
    );
    if (response.statusCode == 201) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to book offline: \${response.body}');
  }

  Future<void> payAppointment(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/appointments/\$appointmentId/pay');
    final response = await _client.post(uri);
    if (response.statusCode != 200) {
      throw HttpException('Payment failed: \${response.body}');
    }
  }
}