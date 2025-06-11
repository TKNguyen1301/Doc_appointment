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

  /// Fetch all specializations
  Future<List<Specialization>> getAllSpecializations({String? token}) async {
    final uri = Uri.parse(baseUrl);
    
    try {
      Map<String, String> headers = {};
      if (token != null) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
      
      final response = await _client.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Specializations API Response: ${response.body}');
        }
        
        final dynamic responseBody = jsonDecode(response.body);
        
        // Handle different response formats
        if (responseBody is List) {
          // Direct list response
          return responseBody.map((e) => Specialization.fromJson(e as Map<String, dynamic>)).toList();
        } else if (responseBody is Map<String, dynamic>) {
          // Object response - check various possible keys
          List? specializationsList;
          
          if (responseBody.containsKey('data')) {
            specializationsList = responseBody['data'] as List?;
          } else if (responseBody.containsKey('specializations')) {
            specializationsList = responseBody['specializations'] as List?;
          } else if (responseBody.containsKey('result')) {
            specializationsList = responseBody['result'] as List?;
          } else if (responseBody.containsKey('items')) {
            specializationsList = responseBody['items'] as List?;
          }
          
          if (specializationsList != null) {
            return specializationsList.map((e) => Specialization.fromJson(e as Map<String, dynamic>)).toList();
          } else {
            // If it's a single specialization object, wrap in list
            if (responseBody.containsKey('specialization_id') || responseBody.containsKey('id')) {
              return [Specialization.fromJson(responseBody)];
            }
          }
        }
        
        // If we reach here, return empty list with warning
        if (kDebugMode) {
          print('Unexpected response format, returning empty list. Response: $responseBody');
        }
        return <Specialization>[];
        
      } else if (response.statusCode == 401) {
        // Authentication error - try without token for public endpoints
        if (token != null) {
          if (kDebugMode) {
            print('Authentication failed, trying without token...');
          }
          return getAllSpecializations(); // Retry without token
        } else {
          throw HttpException('Authentication required for specializations endpoint');
        }
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

  /// Fetch paginated specializations
  Future<List<Specialization>> getSpecializations({
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    
    try {
      final response = await _client.get(uri);
      
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Paginated Specializations API Response: ${response.body}');
        }
        
        final dynamic responseBody = jsonDecode(response.body);
        
        if (responseBody is List) {
          return responseBody.map((e) => Specialization.fromJson(e as Map<String, dynamic>)).toList();
        } else if (responseBody is Map<String, dynamic>) {
          List? data;
          
          if (responseBody.containsKey('data')) {
            data = responseBody['data'] as List?;
          } else if (responseBody.containsKey('specializations')) {
            data = responseBody['specializations'] as List?;
          } else if (responseBody.containsKey('result')) {
            data = responseBody['result'] as List?;
          }
          
          if (data != null) {
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

  /// Create a new specialization
  Future<Specialization> createSpecialization({
    required String name,
    required int fees,
    String? image,
  }) async {
    final uri = Uri.parse(baseUrl);
    final body = {
      'name': name,
      'fees': fees,
      if (image != null) 'image': image,
    };
    
    try {
      final response = await _client.post(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201) {
        final dynamic responseBody = jsonDecode(response.body);
        
        // Handle wrapped response
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('data')) {
            return Specialization.fromJson(responseBody['data'] as Map<String, dynamic>);
          } else if (responseBody.containsKey('specialization')) {
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

  /// Update an existing specialization
  Future<Specialization> updateSpecialization({
    required int specializationId,
    String? name,
    int? fees,
    String? image,
  }) async {
    final uri = Uri.parse('$baseUrl/$specializationId');
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (fees != null) body['fees'] = fees;
    if (image != null) body['image'] = image;

    try {
      final response = await _client.put(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        
        // Handle wrapped response
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('data')) {
            return Specialization.fromJson(responseBody['data'] as Map<String, dynamic>);
          } else if (responseBody.containsKey('specialization')) {
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

  /// Delete a specialization by ID
  Future<void> deleteSpecialization({
    required int specializationId,
  }) async {
    final uri = Uri.parse('$baseUrl/$specializationId');
    
    try {
      final response = await _client.delete(uri);
      
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
