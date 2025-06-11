import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/feedback.dart';

class FeedbackService {
  final String baseUrl;
  final http.Client _client;

  FeedbackService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Add new feedback for an appointment
  Future<Feedback> addFeedback({
    required int appointmentId,
    required int rating,
    String? comment,
  }) async {
    final uri = Uri.parse('$baseUrl/feedbacks');
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'appointment_id': appointmentId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      }),
    );
    if (response.statusCode == 201) {
      return Feedback.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to add feedback: \${response.body}');
  }

  /// Update existing feedback by ID
  Future<Feedback> updateFeedback({
    required int feedbackId,
    int? rating,
    String? comment,
  }) async {
    final uri = Uri.parse('$baseUrl/feedbacks/\$feedbackId');
    final Map<String, dynamic> body = {};
    if (rating != null) body['rating'] = rating;
    if (comment != null) body['comment'] = comment;

    final response = await _client.put(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return Feedback.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to update feedback: \${response.body}');
  }
}
