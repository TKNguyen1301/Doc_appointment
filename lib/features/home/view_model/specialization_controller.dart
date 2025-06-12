import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/specialization.dart';

class SpecializationService {
  final String baseUrl;
  final http.Client _client;

  SpecializationService({
    this.baseUrl = 'http://localhost:5001/api/specialization',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Fetch all specializations (public endpoint - no auth required)
  Future<List<Specialization>> getAllSpecializations({String? token}) async {
    final uri = Uri.parse('$baseUrl/all'); // Use the /all endpoint
    
    try {
      // No authentication headers needed for public endpoint
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Specializations API Response: ${response.body}');
        }
        
        final dynamic responseBody = jsonDecode(response.body);
        
        // Based on your backend, the response format is: { message: "Success", specializations: [...] }
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('specializations')) {
            final List specializationsList = responseBody['specializations'] as List;
            return specializationsList.map((e) => Specialization.fromJson(e as Map<String, dynamic>)).toList();
          }
        }
        
        // If we reach here, return empty list with warning
        if (kDebugMode) {
          print('Unexpected response format, returning empty list. Response: $responseBody');
        }
        return <Specialization>[];
        
      } else {
        throw HttpException('Failed to fetch specializations (status: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching specializations: $e');
      }
      rethrow;
    }
  }

  /// Fetch paginated specializations (requires admin authentication)
  Future<List<Specialization>> getSpecializations({
    int page = 1,
    int limit = 10,
    String? token,
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    
    try {
      Map<String, String> headers = {};
      if (token != null) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
      
      final response = await _client.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Paginated Specializations API Response: ${response.body}');
        }
        
        final dynamic responseBody = jsonDecode(response.body);
        
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('specializations')) {
            final List data = responseBody['specializations'] as List;
            return data.map((e) => Specialization.fromJson(e as Map<String, dynamic>)).toList();
          }
        }
        
        return <Specialization>[];
      } else {
        throw HttpException('Failed to fetch paginated specializations (status: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching paginated specializations: $e');
      }
      rethrow;
    }
  }

  /// Create a new specialization (requires admin authentication)
  Future<Specialization> createSpecialization({
    required String name,
    required int fees,
    String? image,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/create');
    final body = {
      'name': name,
      'fees': fees,
      if (image != null) 'image': image,
    };
    
    try {
      final response = await _client.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201) {
        final dynamic responseBody = jsonDecode(response.body);
        
        // Handle wrapped response
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('specialization')) {
            return Specialization.fromJson(responseBody['specialization'] as Map<String, dynamic>);
          } else {
            return Specialization.fromJson(responseBody);
          }
        }
        
        return Specialization.fromJson(responseBody as Map<String, dynamic>);
      } else {
        throw HttpException('Failed to create specialization (status: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating specialization: $e');
      }
      rethrow;
    }
  }

  /// Update an existing specialization (requires admin authentication)
  Future<Specialization> updateSpecialization({
    required int specializationId,
    String? name,
    int? fees,
    String? image,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/update/$specializationId');
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (fees != null) body['fees'] = fees;
    if (image != null) body['image'] = image;

    try {
      final response = await _client.patch(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        
        // Handle wrapped response
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('specialization')) {
            return Specialization.fromJson(responseBody['specialization'] as Map<String, dynamic>);
          } else {
            return Specialization.fromJson(responseBody);
          }
        }
        
        return Specialization.fromJson(responseBody as Map<String, dynamic>);
      } else {
        throw HttpException('Failed to update specialization (status: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating specialization: $e');
      }
      rethrow;
    }
  }

  /// Delete a specialization by ID (requires admin authentication)
  Future<void> deleteSpecialization({
    required int specializationId,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/delete/$specializationId');
    
    try {
      final response = await _client.delete(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
      
      if (response.statusCode != 200) {
        throw HttpException('Failed to delete specialization (status: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting specialization: $e');
      }
      rethrow;
    }
  }
}
