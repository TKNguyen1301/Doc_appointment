import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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

class PaymentService {
  final String baseUrl;
  final http.Client _client;

  PaymentService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Helper methods for logging
  void _logApiCall(String method, String endpoint,
      {Map<String, String>? headers, String? body}) {
    print('🌐 Payment API Call: $method $endpoint');
    if (headers != null) {
      print('📋 Headers: ${headers.keys.join(', ')}');
    }
    if (body != null) {
      print('📤 Request Body: $body');
    }
  }

  void _logApiResponse(String endpoint, int statusCode, String responseBody) {
    print('📥 Payment API Response: $endpoint');
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

  /// Retrieve payment details for a specific appointment
  Future<Map<String, dynamic>> paymentForAppointment({
    required int appointmentId,
    String? token,
  }) async {
    final endpoint = '$baseUrl/appointment/payment/$appointmentId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    _logApiCall('GET', endpoint, headers: headers);

    try {
      final response = await _client.get(uri, headers: headers);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('✅ Successfully fetched payment for appointment $appointmentId');
        // Return the whole response since we don't know the exact structure
        return body as Map<String, dynamic>;
      }

      _handleApiError(endpoint, response);
      throw ApiException('This should not be reached');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Create a MoMo payment session for an appointment
  Future<Map<String, dynamic>> createMomoPayment({
    required int appointmentId,
    String? token,
  }) async {
    final endpoint = '$baseUrl/payments/momo/$appointmentId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    _logApiCall('POST', endpoint, headers: headers);

    try {
      final response = await _client.post(uri, headers: headers);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print(
            '✅ Successfully created MoMo payment for appointment $appointmentId');
        return responseData;
      }

      _handleApiError(endpoint, response);
      throw ApiException('This should not be reached');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  void dispose() {
    _client.close();
  }
}

class MomoService {
  final String baseUrl;
  final http.Client _client;

  MomoService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Helper methods for logging
  void _logApiCall(String method, String endpoint,
      {Map<String, String>? headers, String? body}) {
    print('🌐 MoMo API Call: $method $endpoint');
    if (headers != null) {
      print('📋 Headers: ${headers.keys.join(', ')}');
    }
    if (body != null) {
      print('📤 Request Body: $body');
    }
  }

  void _logApiResponse(String endpoint, int statusCode, String responseBody) {
    print('📥 MoMo API Response: $endpoint');
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

  /// Handle MoMo payment result callback with query parameters
  Future<Map<String, dynamic>> handlePaymentResult({
    required Map<String, String> queryParams,
    String? token,
  }) async {
    final endpoint = '$baseUrl/payments/momo/result';
    final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    _logApiCall('GET', endpoint, headers: headers);

    try {
      final response = await _client.get(uri, headers: headers);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 302) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Successfully handled MoMo payment result');
        return responseData;
      }

      _handleApiError(endpoint, response);
      throw ApiException('This should not be reached');
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  void dispose() {
    _client.close();
  }
}
