import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl;
  final http.Client _client;

  PaymentService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Retrieve payment details for a specific appointment
  Future<Map<String, dynamic>> paymentForAppointment({
    required int appointmentId,
  }) async {
    final uri = Uri.parse('$baseUrl/payments/\$appointmentId');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // The controller wraps result in { result }
      return body['result'] as Map<String, dynamic>;
    }
    throw HttpException('Failed to fetch payment: \${response.body}');
  }

  /// Create a MoMo payment session for an appointment
  Future<Map<String, dynamic>> createMomoPayment({
    required int appointmentId,
  }) async {
    final uri = Uri.parse('$baseUrl/payments/momo/\$appointmentId');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to create MoMo payment: \${response.body}');
  }
}

class MomoService {
  final String baseUrl;
  final http.Client _client;

  MomoService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Handle MoMo payment result callback with query parameters
  Future<Map<String, dynamic>> handlePaymentResult({
    required Map<String, String> queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl/payments/momo/result')
        .replace(queryParameters: queryParams);
    final response = await _client.get(uri);
    if (response.statusCode == 200 || response.statusCode == 302) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw HttpException('Failed to handle MoMo result: \${response.body}');
  }
}
