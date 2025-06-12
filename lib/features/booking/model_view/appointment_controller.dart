import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/appointment.dart';

class AppointmentController {
  final String baseUrl;
  final http.Client _client;

  AppointmentController({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Appointment> createAppointment({
    required int userId,
    required int doctorId,
    required DateTime appointmentDatetime,
    String? reason,
    String? token,
    int? fees,
  }) async {
    final uri = Uri.parse('$baseUrl/appointments/book_online');
    
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final body = {
      'user_id': userId,
      'doctor_id': doctorId,
      'appointment_datetime': appointmentDatetime.toIso8601String(),
      'reason': reason,
    };
    
    if (fees != null) {
      body['fees'] = fees;
    }

    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      // Xử lý response mới từ backend
      if (responseData['appointment'] != null) {
        return Appointment.fromJson(responseData['appointment']);
      } else {
        throw HttpException('No appointment data in response');
      }
    }
    throw HttpException('Failed to create appointment: ${response.body}');
  }

  Future<List<Appointment>> getUserAppointments({String? token}) async {
    final uri = Uri.parse('$baseUrl/appointments/user');
    
    final headers = <String, String>{
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final response = await _client.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Appointment.fromJson(e)).toList();
    }
    throw HttpException('Failed to fetch user appointments: ${response.body}');
  }

  Future<Appointment> getAppointmentDetails(int appointmentId, {String? token}) async {
    final uri = Uri.parse('$baseUrl/appointments/$appointmentId');
    
    final headers = <String, String>{
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final response = await _client.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to fetch appointment details: ${response.body}');
  }

  void dispose() {
    _client.close();
  }
}