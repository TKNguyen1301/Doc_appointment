import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/prescription.dart';

class PrescriptionService {
  final String baseUrl;
  final http.Client _client;

  PrescriptionService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Add a new prescription for an appointment
  Future<Prescription> addPrescription({
    required int appointmentId,
    required String medicineDetails,
  }) async {
    final uri = Uri.parse('$baseUrl/prescriptions');
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'appointment_id': appointmentId,
        'medicine_details': medicineDetails,
      }),
    );
    if (response.statusCode == 201) {
      return Prescription.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to add prescription: \${response.body}');
  }

  /// Update an existing prescription by its ID
  Future<Prescription> updatePrescription({
    required int prescriptionId,
    required String medicineDetails,
  }) async {
    final uri = Uri.parse('$baseUrl/prescriptions/\$prescriptionId');
    final response = await _client.put(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'medicine_details': medicineDetails,
      }),
    );
    if (response.statusCode == 200) {
      return Prescription.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to update prescription: \${response.body}');
  }
}
