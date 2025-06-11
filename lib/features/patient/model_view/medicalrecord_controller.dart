import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/medicalrecord.dart';

class MedicalRecordService {
  final String baseUrl;
  final http.Client _client;

  MedicalRecordService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Add a new medical record for an appointment
  Future<MedicalRecord> addMedicalRecord({
    required int appointmentId,
    required String diagnosis,
    required String treatment,
    String? notes,
  }) async {
    final uri = Uri.parse('$baseUrl/medical-records');
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'appointment_id': appointmentId,
        'diagnosis': diagnosis,
        'treatment': treatment,
        if (notes != null) 'notes': notes,
      }),
    );
    if (response.statusCode == 201) {
      return MedicalRecord.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to add medical record: \${response.body}');
  }

  /// Update an existing medical record by its ID
  Future<MedicalRecord> updateMedicalRecord({
    required int recordId,
    String? diagnosis,
    String? treatment,
    String? notes,
  }) async {
    final uri = Uri.parse('$baseUrl/medical-records/\$recordId');
    final Map<String, dynamic> body = {};
    if (diagnosis != null) body['diagnosis'] = diagnosis;
    if (treatment != null) body['treatment'] = treatment;
    if (notes != null) body['notes'] = notes;

    final response = await _client.put(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return MedicalRecord.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to update medical record: \${response.body}');
  }
}
