import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/specialization.dart';

class SpecializationService {
  final String baseUrl;
  final http.Client _client;

  SpecializationService({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Fetch all specializations
  Future<List<Specialization>> getAllSpecializations() async {
    final uri = Uri.parse('\$baseUrl/specializations');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Specialization.fromJson(e)).toList();
    }
    throw HttpException('Failed to fetch specializations: \${response.body}');
  }

  /// Fetch paginated specializations
  Future<List<Specialization>> getSpecializations({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse('\$baseUrl/specializations')
        .replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Specialization.fromJson(e)).toList();
    }
    throw HttpException('Failed to fetch paginated specializations: \${response.body}');
  }

  /// Create a new specialization
  Future<Specialization> createSpecialization({
    required String name,
    required int fees,
    String? imageData,
  }) async {
    final uri = Uri.parse('\$baseUrl/specializations');
    final body = {
      'name': name,
      'fees': fees,
      if (imageData != null) 'image': imageData,
    };
    final response = await _client.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      return Specialization.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to create specialization: \${response.body}');
  }

  /// Update an existing specialization
  Future<Specialization> updateSpecialization({
    required int specializationId,
    String? name,
    int? fees,
    String? imageData,
  }) async {
    final uri = Uri.parse('\$baseUrl/specializations/\$specializationId');
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (fees != null) body['fees'] = fees;
    if (imageData != null) body['image'] = imageData;

    final response = await _client.put(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return Specialization.fromJson(jsonDecode(response.body));
    }
    throw HttpException('Failed to update specialization: \${response.body}');
  }

  /// Delete a specialization by ID
  Future<void> deleteSpecialization({
    required int specializationId,
  }) async {
    final uri = Uri.parse('\$baseUrl/specializations/\$specializationId');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) {
      throw HttpException('Failed to delete specialization: \${response.body}');
    }
  }
}
