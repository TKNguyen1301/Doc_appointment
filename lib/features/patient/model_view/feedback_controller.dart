import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/feedback.dart';

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

class FeedbackService {
  final String baseUrl;
  final http.Client _client;

  FeedbackService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Helper methods for logging
  void _logApiCall(String method, String endpoint,
      {Map<String, String>? headers, String? body}) {
    print('🌐 Feedback API Call: $method $endpoint');
    if (headers != null) {
      print('📋 Headers: ${headers.keys.join(', ')}');
    }
    if (body != null) {
      print('📤 Request Body: $body');
    }
  }

  void _logApiResponse(String endpoint, int statusCode, String responseBody) {
    print('📥 Feedback API Response: $endpoint');
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

  /// Add new feedback for an appointment
  Future<Feedback> addFeedback({
    required int appointmentId,
    required int rating,
    String? comment,
    String? token,
  }) async {
    final endpoint = '$baseUrl/feedbacks/add';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final requestBody = {
      'appointment_id': appointmentId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    };

    final body = jsonEncode(requestBody);

    _logApiCall('POST', endpoint, headers: headers, body: body);

    try {
      final response = await _client.post(uri, headers: headers, body: body);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Successfully added feedback');
        return Feedback.fromJson(responseData as Map<String, dynamic>);
      }

      _handleApiError(endpoint, response);
      throw ApiException('This should not be reached');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Update existing feedback by ID
  Future<Feedback> updateFeedback({
    required int feedbackId,
    int? rating,
    String? comment,
    String? token,
  }) async {
    final endpoint = '$baseUrl/feedbacks/update/$feedbackId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final Map<String, dynamic> requestBody = {};
    if (rating != null) requestBody['rating'] = rating;
    if (comment != null) requestBody['comment'] = comment;

    final body = jsonEncode(requestBody);

    _logApiCall('PATCH', endpoint, headers: headers, body: body);

    try {
      final response = await _client.patch(uri, headers: headers, body: body);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Successfully updated feedback');
        return Feedback.fromJson(responseData as Map<String, dynamic>);
      }

      _handleApiError(endpoint, response);
      throw ApiException('This should not be reached');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get feedback for an appointment - NOT AVAILABLE IN BACKEND
  /// This endpoint doesn't exist in backend, so we'll return null for now
  Future<Feedback?> getFeedbackForAppointment({
    required int appointmentId,
    String? token,
  }) async {
    print(
        '⚠️ Warning: getFeedbackForAppointment endpoint not available in backend');
    print('ℹ️ Backend only has /add and /update endpoints for feedback');
    return null;
  }

  void dispose() {
    _client.close();
  }
}
