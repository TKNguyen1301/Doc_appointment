import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/medicalrecord.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;
  final String? endpoint;

  ApiException(this.message,
      {this.statusCode, this.responseBody, this.endpoint});

  @override
  String toString() {
    return 'ApiException: $message\n'
        'Status Code: $statusCode\n'
        'Endpoint: $endpoint\n'
        'Response: $responseBody';
  }
}

class MedicalRecordService {
  final String baseUrl;
  final http.Client _client;

  MedicalRecordService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Helper methods for logging
  void _logApiCall(String method, String endpoint,
      {Map<String, String>? headers, String? body}) {
    print('🌐 Medical Record API Call: $method $endpoint');
    if (headers != null) {
      print('📋 Headers: ${headers.keys.join(', ')}');
    }
    if (body != null) {
      print('📤 Request Body: $body');
    }
  }

  void _logApiResponse(String endpoint, int statusCode, String responseBody) {
    print('📥 Medical Record API Response: $endpoint');
    print('📊 Status Code: $statusCode');
    print('📄 Response Body: $responseBody');
  }

  void _handleApiError(String endpoint, http.Response response) {
    _logApiResponse(endpoint, response.statusCode, response.body);

    String errorMessage;
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['message'] ??
          errorData['error'] ??
          'Unknown error occurred';
    } catch (e) {
      errorMessage = 'Failed to parse error response: ${response.body}';
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      responseBody: response.body,
      endpoint: endpoint,
    );
  }

  /// Add a new medical record for an appointment
  Future<MedicalRecord> addMedicalRecord({
    required int appointmentId,
    required String diagnosis,
    required String treatment,
    String? notes,
    String? token,
  }) async {
    final endpoint = '$baseUrl/medical-records/add';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final requestBody = {
      'appointment_id': appointmentId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      if (notes != null) 'notes': notes,
    };

    final body = jsonEncode(requestBody);

    _logApiCall('POST', endpoint, headers: headers, body: body);

    try {
      final response = await _client.post(uri, headers: headers, body: body);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Successfully added medical record');
        return MedicalRecord.fromJson(responseData as Map<String, dynamic>);
      }

      _handleApiError(endpoint, response);
      throw ApiException('This should not be reached');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Update an existing medical record by its ID
  Future<MedicalRecord> updateMedicalRecord({
    required int recordId,
    String? diagnosis,
    String? treatment,
    String? notes,
    String? token,
  }) async {
    final endpoint = '$baseUrl/medical-records/update/$recordId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final Map<String, dynamic> requestBody = {};
    if (diagnosis != null) requestBody['diagnosis'] = diagnosis;
    if (treatment != null) requestBody['treatment'] = treatment;
    if (notes != null) requestBody['notes'] = notes;

    final body = jsonEncode(requestBody);

    _logApiCall('PATCH', endpoint, headers: headers, body: body);

    try {
      final response = await _client.patch(uri, headers: headers, body: body);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Successfully updated medical record');
        return MedicalRecord.fromJson(responseData as Map<String, dynamic>);
      }

      _handleApiError(endpoint, response);
      throw ApiException('This should not be reached');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get medical record for an appointment - NOT AVAILABLE IN BACKEND
  /// This endpoint doesn't exist in backend, so we'll return null for now
  Future<MedicalRecord?> getMedicalRecordForAppointment({
    required int appointmentId,
    String? token,
  }) async {
    print(
        '⚠️ Warning: getMedicalRecordForAppointment endpoint not available in backend');
    print('ℹ️ Backend only has /add and /update endpoints for medical records');
    return null;
  }

  void dispose() {
    _client.close();
  }
}
