import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/features/patient/model/appointment.dart';
import 'package:flutterproject/features/patient/model/feedback.dart';

/// Controller for interacting with Doctor-related API endpoints.
class DoctorController {
  /// Base URL for the Doctor API. Adjust host and port as needed.
  static const String _baseUrl = 'http://localhost:5001/api/doctor';

  /// Fetch all doctors, optionally filtered by query parameters.
  Future<List<Doctor>> fetchAllDoctors({
    String? specializationId,
    String? date,
    String? shiftType,
    String? startTime,
    String? endTime,
  }) async {
    final query = <String, String>{
      if (specializationId != null) 'specialization_id': specializationId,
      if (date != null) 'date': date,
      if (shiftType != null) 'shift_type': shiftType,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
    };
    final uri = Uri.parse('$_baseUrl/all').replace(queryParameters: query);
    
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('API Response: ${response.body}');
        }
        
        final dynamic responseBody = jsonDecode(response.body);
        
        // Handle different response formats
        if (responseBody is List) {
          // Direct list response
          return responseBody.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
        } else if (responseBody is Map<String, dynamic>) {
          // Object response - check various possible keys
          List? doctorsList;
          
          if (responseBody.containsKey('data')) {
            doctorsList = responseBody['data'] as List?;
          } else if (responseBody.containsKey('doctors')) {
            doctorsList = responseBody['doctors'] as List?;
          } else if (responseBody.containsKey('result')) {
            doctorsList = responseBody['result'] as List?;
          } else if (responseBody.containsKey('items')) {
            doctorsList = responseBody['items'] as List?;
          }
          
          if (doctorsList != null) {
            return doctorsList.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
          } else {
            // If it's a single doctor object, wrap in list
            if (responseBody.containsKey('id') || responseBody.containsKey('_id')) {
              return [Doctor.fromJson(responseBody)];
            }
          }
        }
        
        // If we reach here, return empty list instead of throwing error
        if (kDebugMode) {
          print('Unexpected response format, returning empty list. Response: $responseBody');
        }
        return <Doctor>[];
        
      } else {
        throw HttpException(
          'Failed to fetch doctors (status: ${response.statusCode}): ${response.body}',
          uri: uri,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching doctors: $e');
      }
      rethrow;
    }
  }

  /// Get the profile of the authenticated doctor.
  Future<Doctor> getDoctorProfile(String token) async {
    final uri = Uri.parse('$_baseUrl/profile');
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Doctor.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw HttpException(
        'Failed to load profile (status: ${response.statusCode})',
        uri: uri,
      );
    }
  }

  /// Fetch appointments for the authenticated doctor.
  Future<List<Appointment>> getDoctorAppointments(
    String token, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final query = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };
    final uri = Uri.parse('$_baseUrl/appointments').replace(queryParameters: query);
    
    try {
      final response = await http.get(
        uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        
        if (responseBody is List) {
          return responseBody.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
        } else if (responseBody is Map<String, dynamic> && responseBody.containsKey('data')) {
          final List data = responseBody['data'] as List;
          return data.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          throw HttpException(
            'Unexpected response format for appointments',
            uri: uri,
          );
        }
      } else {
        throw HttpException(
          'Failed to fetch appointments (status: ${response.statusCode}): ${response.body}',
          uri: uri,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching appointments: $e');
      }
      rethrow;
    }
  }

  /// Fetch patient appointments assigned to a specific doctor.
  Future<List<Appointment>> getPatientAppointmentsByDoctor(
    String userId,
    String token,
  ) async {
    final uri = Uri.parse('$_baseUrl/patient/$userId/appointments');
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw HttpException(
        'Failed to fetch patient appointments (status: ${response.statusCode})',
        uri: uri,
      );
    }
  }

  /// Create a new doctor (admin only).
  Future<Map<String, dynamic>> addDoctor({
    required Map<String, dynamic> doctorData,
    File? avatarFile,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/add');
    final request = http.MultipartRequest('POST', uri)
      ..headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    doctorData.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException(
        'Failed to add doctor (status: ${response.statusCode})',
        uri: uri,
      );
    }
  }

  /// Update an existing doctor's profile.
  Future<void> updateDoctorProfile({
    required Map<String, dynamic> updates,
    File? avatarFile,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/update');
    final request = http.MultipartRequest('PATCH', uri)
      ..headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    updates.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    if (avatarFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path),
      );
    }

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw HttpException(
        'Failed to update profile (status: ${streamed.statusCode})',
        uri: uri,
      );
    }
  }

  /// Delete a doctor by ID (admin only).
  Future<void> deleteDoctor(
    String userId,
    String token,
  ) async {
    final uri = Uri.parse('$_baseUrl/delete/$userId');
    final response = await http.delete(
      uri,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw HttpException(
        'Failed to delete doctor (status: ${response.statusCode})',
        uri: uri,
      );
    }
  }

  /// Fetch feedback for the authenticated doctor.
  Future<List<Feedback>> getDoctorFeedback(String token) async {
    final uri = Uri.parse('$_baseUrl/feedback');
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Feedback.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw HttpException(
        'Failed to fetch feedback (status: ${response.statusCode})',
        uri: uri,
      );
    }
  }

  /// Fetch scheduled shifts for the authenticated doctor.
  Future<Map<String, dynamic>> getDoctorShifts(String token) async {
    final uri = Uri.parse('$_baseUrl/shifts');
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException(
        'Failed to fetch shifts (status: ${response.statusCode})',
        uri: uri,
      );
    }
  }
}
