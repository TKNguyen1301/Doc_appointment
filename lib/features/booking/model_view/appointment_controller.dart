import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/appointment.dart';

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

class AppointmentController {
  final String baseUrl;
  final http.Client _client;

  AppointmentController({
    this.baseUrl = 'http://localhost:5001/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Helper method for logging API calls
  void _logApiCall(String method, String endpoint,
      {Map<String, String>? headers, String? body}) {
    print('🌐 API Call: $method $endpoint');
    if (headers != null) {
      print('📋 Headers: ${headers.keys.join(', ')}');
    }
    if (body != null) {
      print('📤 Request Body: $body');
    }
  }

  // Helper method for logging API responses
  void _logApiResponse(String endpoint, int statusCode, String responseBody) {
    print('📥 API Response: $endpoint');
    print('📊 Status Code: $statusCode');
    print('📄 Response Body: $responseBody');
  }

  // Helper method for error handling
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

  /// Get all appointments (admin only)
  Future<List<Appointment>> getAllAppointments({String? token}) async {
    final endpoint = '$baseUrl/all';
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
        final data = jsonDecode(response.body);
        final appointmentsList = data['appointments'] as List;
        print('✅ Successfully fetched ${appointmentsList.length} appointments');
        return appointmentsList
            .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      _handleApiError(endpoint, response);
      return []; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get appointments with pagination and filters
  Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    String? date,
    String? token,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) queryParams['status'] = status;
    if (date != null) queryParams['date'] = date;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final endpoint = uri.toString();

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    _logApiCall('GET', endpoint, headers: headers);

    try {
      final response = await _client.get(uri, headers: headers);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final appointmentsList = data['appointments'] as List;
        print(
            '✅ Successfully fetched ${appointmentsList.length} appointments (page $page)');
        final appointments = appointmentsList
            .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'appointments': appointments,
          'pagination': data['pagination'],
        };
      }

      _handleApiError(endpoint, response);
      return {}; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get appointment details by ID
  Future<Appointment> getAppointmentDetails(int appointmentId,
      {String? token}) async {
    final endpoint = '$baseUrl/appointment/details/$appointmentId';
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
        final data = jsonDecode(response.body);
        print(
            '✅ Successfully fetched appointment details for ID: $appointmentId');
        return Appointment.fromJson(
            data['appointmentDetails'] as Map<String, dynamic>);
      }

      _handleApiError(endpoint, response);
      throw ApiException(
          'This should not be reached'); // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Check doctor availability before booking
  Future<Map<String, dynamic>> checkDoctorAvailability({
    required int doctorId,
    required String appointmentDatetime,
    String? token,
  }) async {
    // This is a diagnostic endpoint to help debug booking issues
    final endpoint = '$baseUrl/../doctor/shifts';
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
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Successfully checked doctor availability');
        return responseData;
      } else if (response.statusCode == 401) {
        print('⚠️ Unauthorized to check doctor shifts - need doctor token');
        return {
          'error': 'unauthorized',
          'message': 'Need doctor authentication'
        };
      } else {
        print('⚠️ Could not check doctor availability: ${response.statusCode}');
        return {
          'error': 'unavailable',
          'message': 'Could not verify availability'
        };
      }
    } catch (e) {
      print('❌ Network Error checking availability: $e');
      return {'error': 'network', 'message': 'Network error: $e'};
    }
  }

  /// Enhanced booking with pre-check
  Future<Map<String, dynamic>> bookAppointmentOnlineWithCheck({
    required int doctorId,
    required String appointmentDatetime,
    String? reason,
    String? token,
  }) async {
    print('🔍 Pre-checking doctor availability...');

    // First check doctor availability
    final availabilityCheck = await checkDoctorAvailability(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      token: token,
    );

    if (availabilityCheck.containsKey('error')) {
      print('⚠️ Availability check failed: ${availabilityCheck['message']}');
      print('📋 Proceeding with booking attempt anyway...');
    }

    // Proceed with normal booking - this returns Future<Map<String, dynamic>>
    return await bookAppointmentOnline(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      reason: reason,
      token: token,
    );
  }

  /// Book appointment online
  Future<Map<String, dynamic>> bookAppointmentOnline({
    required int doctorId,
    required String appointmentDatetime,
    String? reason,
    String? token,
  }) async {
    final endpoint = '$baseUrl/appointment/book_online';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    // Fix date format - remove milliseconds to match backend expectation
    String formattedDateTime = appointmentDatetime;
    if (appointmentDatetime.contains('.')) {
      // Remove milliseconds: 2025-06-14T08:00:00.000 → 2025-06-14T08:00:00
      formattedDateTime = appointmentDatetime.split('.')[0];
    }

    final requestBody = {
      'doctor_id': doctorId,
      'appointment_datetime': formattedDateTime, // Use corrected format
      if (reason != null) 'reason': reason,
    };

    final body = jsonEncode(requestBody);

    _logApiCall('POST', endpoint, headers: headers, body: body);
    print('📋 Booking Details:');
    print('   Doctor ID: $doctorId');
    print('   DateTime (Original): $appointmentDatetime');
    print('   DateTime (Formatted): $formattedDateTime');
    print('   Reason: ${reason ?? 'N/A'}');

    try {
      final response = await _client.post(uri, headers: headers, body: body);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Successfully booked appointment!');
        print('📄 Response data keys: ${responseData.keys.toList()}');
        return responseData;
      }

      // Enhanced error handling for booking specific errors
      if (response.statusCode == 400) {
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ??
              errorData['error'] ??
              'Unknown booking error';

          // Add specific suggestions based on error message
          if (errorMessage.contains('not available')) {
            print(
                '💡 Suggestion: Check if the doctor has availability for this time slot');
            print('💡 Alternative: Try a different time slot or date');
          } else if (errorMessage.contains('date') ||
              errorMessage.contains('time')) {
            print(
                '💡 Date Format Issue: Backend expects format like 2025-06-10T09:10:00');
            print('💡 Sent format: $formattedDateTime');
          }
        } catch (e) {
          errorMessage = 'Booking failed: ${response.body}';
        }

        throw ApiException(
          errorMessage,
          statusCode: response.statusCode,
          responseBody: response.body,
          endpoint: endpoint,
        );
      }

      _handleApiError(endpoint, response);
      return {}; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Cancel appointment by patient
  Future<Map<String, dynamic>> cancelAppointmentByPatient(int appointmentId,
      {String? token}) async {
    final endpoint =
        '$baseUrl/appointment/cancel_appointment_patient/$appointmentId';
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
        print('✅ Successfully cancelled appointment ID: $appointmentId');
        return responseData;
      }

      _handleApiError(endpoint, response);
      return {}; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Complete appointment (doctor only)
  Future<Map<String, dynamic>> completeAppointment(int appointmentId,
      {String? token}) async {
    final endpoint = '$baseUrl/completed/$appointmentId';
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
        print('✅ Successfully completed appointment ID: $appointmentId');
        return responseData;
      }

      _handleApiError(endpoint, response);
      return {}; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Mark patient as no show (doctor only)
  Future<Map<String, dynamic>> markPatientNotComing(int appointmentId,
      {String? token}) async {
    final endpoint = '$baseUrl/no_show/$appointmentId';
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
            '✅ Successfully marked appointment ID: $appointmentId as no show');
        return responseData;
      }

      _handleApiError(endpoint, response);
      return {}; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get appointment for payment
  Future<Appointment> getAppointmentForPayment(int appointmentId,
      {String? token}) async {
    final endpoint = '$baseUrl/payment/$appointmentId';
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
        final data = jsonDecode(response.body);
        print(
            '✅ Successfully fetched appointment for payment ID: $appointmentId');
        return Appointment.fromJson(
            data['appointment'] as Map<String, dynamic>);
      }

      _handleApiError(endpoint, response);
      throw ApiException(
          'This should not be reached'); // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get appointments stats (admin only)
  Future<Map<String, dynamic>> getAppointmentsStats({String? token}) async {
    final endpoint = '$baseUrl/stats';
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
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Successfully fetched appointment stats');
        return responseData;
      }

      _handleApiError(endpoint, response);
      return {}; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get paid appointments (admin only)
  Future<List<Appointment>> getPaidAppointments({String? token}) async {
    final endpoint = '$baseUrl/paid';
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
        final data = jsonDecode(response.body);
        final appointmentsList = data['paidAppointments'] as List;
        print(
            '✅ Successfully fetched ${appointmentsList.length} paid appointments');
        return appointmentsList
            .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      _handleApiError(endpoint, response);
      return []; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get user appointments (from patient controller)
  Future<List<Appointment>> getUserAppointments({String? token}) async {
    // Update: Backend DOES have /api/patient/appointments endpoint
    // From patient service: getPatientAppointments function exists
    final patientEndpoint = 'http://localhost:5001/api/patient/appointments';
    final uri = Uri.parse(patientEndpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    _logApiCall('GET', patientEndpoint, headers: headers);

    try {
      final response = await _client.get(uri, headers: headers);
      _logApiResponse(patientEndpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final appointmentsList = data['appointments'] as List? ?? [];
        print(
            '✅ Successfully fetched ${appointmentsList.length} user appointments');

        // Parse appointments with better error handling
        final List<Appointment> appointments = [];
        for (int i = 0; i < appointmentsList.length; i++) {
          try {
            final appointmentData = appointmentsList[i] as Map<String, dynamic>;
            final appointment = Appointment.fromJson(appointmentData);
            appointments.add(appointment);
          } catch (e) {
            print('⚠️ Warning: Failed to parse appointment at index $i: $e');
            print('📄 Raw appointment data: ${appointmentsList[i]}');
            // Continue with other appointments instead of failing completely
          }
        }

        print(
            '✅ Successfully parsed ${appointments.length} out of ${appointmentsList.length} appointments');
        return appointments;
      }

      _handleApiError(patientEndpoint, response);
      return []; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e',
          endpoint: patientEndpoint);
    }
  }

  /// Get doctor appointments for specific user
  Future<List<Appointment>> getDoctorAppointments(int userId,
      {String? token}) async {
    final endpoint = '$baseUrl/patient/doctor_appointments/$userId';
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
        final data = jsonDecode(response.body);
        final appointmentsList = data['appointments'] as List? ?? [];
        print(
            '✅ Successfully fetched ${appointmentsList.length} doctor appointments for user $userId');

        // Parse appointments with better error handling
        final List<Appointment> appointments = [];
        for (int i = 0; i < appointmentsList.length; i++) {
          try {
            final appointmentData = appointmentsList[i] as Map<String, dynamic>;
            final appointment = Appointment.fromJson(appointmentData);
            appointments.add(appointment);
          } catch (e) {
            print('⚠️ Warning: Failed to parse appointment at index $i: $e');
            print('📄 Raw appointment data: ${appointmentsList[i]}');
            // Continue with other appointments instead of failing completely
          }
        }

        print(
            '✅ Successfully parsed ${appointments.length} out of ${appointmentsList.length} appointments');
        return appointments;
      }

      _handleApiError(endpoint, response);
      return []; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Update feedback
  Future<Map<String, dynamic>> updateFeedback(
    int feedbackId, {
    int? rating,
    String? comment,
    String? token,
  }) async {
    final endpoint = '$baseUrl/feedback/update/$feedbackId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final requestBody = <String, dynamic>{};
    if (rating != null) requestBody['rating'] = rating;
    if (comment != null) requestBody['comment'] = comment;

    final body = jsonEncode(requestBody);

    _logApiCall('PUT', endpoint, headers: headers, body: body);

    try {
      final response = await _client.put(uri, headers: headers, body: body);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Successfully updated feedback ID: $feedbackId');
        return responseData;
      }

      _handleApiError(endpoint, response);
      return {}; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get user payments
  Future<List<Map<String, dynamic>>> getUserPayments({String? token}) async {
    final endpoint = '$baseUrl/patient/payments';
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
        final data = jsonDecode(response.body);
        final paymentsList =
            data['payments'] as List? ?? data['data'] as List? ?? [];
        print('✅ Successfully fetched ${paymentsList.length} user payments');

        return paymentsList
            .map((payment) => payment as Map<String, dynamic>)
            .toList();
      }

      _handleApiError(endpoint, response);
      return []; // This line won't be reached due to exception above
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Alternative booking method that tries different endpoints and approaches
  Future<Map<String, dynamic>> bookAppointmentAlternative({
    required int doctorId,
    required String appointmentDatetime,
    String? reason,
    String? token,
  }) async {
    print('🔄 TRYING ALTERNATIVE BOOKING METHODS...');

    // Try 1: Original endpoint with detailed debugging
    print('📍 Method 1: Original endpoint with full debugging');
    try {
      final result = await bookAppointmentOnline(
        doctorId: doctorId,
        appointmentDatetime: appointmentDatetime,
        reason: reason,
        token: token,
      );
      print('✅ Method 1 succeeded!');
      return result;
    } catch (e) {
      print('❌ Method 1 failed: $e');
    }

    // Try 2: Different endpoint variations
    final alternativeEndpoints = [
      'http://localhost:5001/api/appointments/book_online',
      'http://localhost:5001/api/appointment/create',
      'http://localhost:5001/api/appointment/book-online',
      'http://localhost:5001/api/appointment/bookonline',
    ];

    for (int i = 0; i < alternativeEndpoints.length; i++) {
      print('📍 Method ${i + 2}: ${alternativeEndpoints[i]}');
      try {
        final result = await _tryAlternativeEndpoint(
          endpoint: alternativeEndpoints[i],
          doctorId: doctorId,
          appointmentDatetime: appointmentDatetime,
          reason: reason,
          token: token,
        );
        if (result.isNotEmpty) {
          print('✅ Method ${i + 2} succeeded!');
          return result;
        }
      } catch (e) {
        print('❌ Method ${i + 2} failed: $e');
      }
    }

    // Try 3: Mock booking for testing
    print('📍 Final Method: Mock booking for testing');
    return _createMockBookingResponse(doctorId, appointmentDatetime, reason);
  }

  /// Try alternative endpoint
  Future<Map<String, dynamic>> _tryAlternativeEndpoint({
    required String endpoint,
    required int doctorId,
    required String appointmentDatetime,
    String? reason,
    String? token,
  }) async {
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final requestBody = {
      'doctor_id': doctorId,
      'appointment_datetime': appointmentDatetime,
      if (reason != null) 'reason': reason,
    };

    final body = jsonEncode(requestBody);
    _logApiCall('POST', endpoint, headers: headers, body: body);

    final response = await _client.post(uri, headers: headers, body: body);
    _logApiResponse(endpoint, response.statusCode, response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      print('✅ Alternative endpoint worked: $endpoint');
      return responseData;
    }

    throw ApiException(
      'Alternative endpoint failed: ${response.body}',
      statusCode: response.statusCode,
      responseBody: response.body,
      endpoint: endpoint,
    );
  }

  /// Create mock booking response for testing
  Map<String, dynamic> _createMockBookingResponse(
    int doctorId,
    String appointmentDatetime,
    String? reason,
  ) {
    print('🎭 Creating mock booking response for testing...');
    print('⚠️ This is for testing only - no actual booking is made!');

    return {
      'message': 'Mock booking successful (for testing only)',
      'appointment': {
        'appointment_id': DateTime.now().millisecondsSinceEpoch,
        'doctor_id': doctorId,
        'appointment_datetime': appointmentDatetime,
        'reason': reason,
        'status': 'scheduled',
        'booking_source': 'online',
        'mock': true,
      },
    };
  }

  /// Get detailed appointment information by ID (Raw API response)
  Future<Map<String, dynamic>> getAppointmentDetailsRaw({
    required int appointmentId,
    String? token,
  }) async {
    final endpoint =
        'http://localhost:5001/api/appointment/details/$appointmentId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    _logApiCall('GET', endpoint, headers: headers);
    print('📋 Getting appointment details for ID: $appointmentId');

    try {
      final response = await _client.get(uri, headers: headers);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Successfully fetched appointment details!');

        // Extract appointmentDetails from the response
        final appointmentDetails =
            responseData['appointmentDetails'] as Map<String, dynamic>?;
        if (appointmentDetails != null) {
          print(
              '📄 Appointment details keys: ${appointmentDetails.keys.toList()}');
          return appointmentDetails;
        } else {
          print('⚠️ No appointmentDetails found in response');
          return responseData;
        }
      }

      if (response.statusCode == 401) {
        throw ApiException(
          'Unauthorized: Token is required or invalid',
          statusCode: response.statusCode,
          responseBody: response.body,
          endpoint: endpoint,
        );
      }

      _handleApiError(endpoint, response);
      return {};
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get all user appointments with pagination (Raw API response)
  Future<List<Map<String, dynamic>>> getAllUserAppointmentsRaw({
    String? token,
    int limit = 10,
  }) async {
    final List<Map<String, dynamic>> allAppointments = [];
    int page = 1;
    int? totalPages;

    print('📋 ===============================');
    print('📋 STARTING PAGINATION FETCH');
    print('📋 Limit per page: $limit');
    print('📋 ===============================');

    while (true) {
      try {
        print('\n🔄 === FETCHING PAGE $page ===');

        final response = await getUserAppointmentsWithPaginationInfo(
          token: token,
          page: page,
          limit: limit,
        );

        final List<Map<String, dynamic>> appointments =
            response['appointments'] ?? [];
        final Map<String, dynamic>? paginationInfo = response['pagination'];

        if (appointments.isEmpty) {
          print(
              '📄 ❌ No appointments found on page $page. Stopping pagination.');
          break;
        }

        // Add appointments to collection
        allAppointments.addAll(appointments);
        print('📄 ✅ Page $page: Found ${appointments.length} appointments');
        print('📊 Total collected so far: ${allAppointments.length}');

        // Show sample appointments from this page
        print('📝 Sample appointments from page $page:');
        for (int i = 0; i < appointments.length.clamp(0, 3); i++) {
          final apt = appointments[i];
          print(
              '   ${i + 1}. ID: ${apt['appointment_id']}, Status: ${apt['status']}, Date: ${apt['appointment_datetime']}');
        }
        if (appointments.length > 3) {
          print('   ... and ${appointments.length - 3} more');
        }

        // Get total pages from pagination info
        if (paginationInfo != null && totalPages == null) {
          totalPages = paginationInfo['totalPages'] as int?;
          final total = paginationInfo['total'] as int?;
          print('📊 Pagination info discovered:');
          print('    - Total appointments: $total');
          print('    - Total pages: $totalPages');
          print('    - Current page: ${paginationInfo['page']}');
          print('    - Limit: ${paginationInfo['limit']}');
        }

        // Check if we've reached the last page
        if (totalPages != null && page >= totalPages) {
          print('\n🏁 === PAGINATION COMPLETE ===');
          print('📄 Reached last page ($page/$totalPages)');
          print('📊 Final total appointments: ${allAppointments.length}');
          print('🏁 ==============================');
          break;
        }

        print('➡️  Moving to next page: ${page + 1}');
        page++;

        // Small delay to avoid overwhelming the server
        await Future.delayed(Duration(milliseconds: 200));
      } catch (e) {
        print('❌ Error fetching page $page: $e');
        print(
            '📊 Partial result: ${allAppointments.length} appointments collected before error');
        break;
      }
    }

    print('\n📋 PAGINATION SUMMARY:');
    print('📋 Total pages fetched: ${page - 1}');
    print('📋 Total appointments collected: ${allAppointments.length}');
    print('📋 ===============================');

    return allAppointments;
  }

  /// Get user appointments with pagination info (Raw API response with pagination details)
  Future<Map<String, dynamic>> getUserAppointmentsWithPaginationInfo({
    String? token,
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint =
        'http://localhost:5001/api/patient/appointments?page=$page&limit=$limit';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    _logApiCall('GET', endpoint, headers: headers);
    print(
        '📋 Getting user appointments with pagination - Page: $page, Limit: $limit');

    try {
      final response = await _client.get(uri, headers: headers);
      _logApiResponse(endpoint, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract appointments and pagination info
        final List<dynamic> appointmentsList =
            responseData['appointments'] ?? [];
        final Map<String, dynamic>? pagination = responseData['pagination'];

        final appointments = appointmentsList.cast<Map<String, dynamic>>();

        print(
            '✅ Successfully fetched ${appointments.length} appointments for page $page');
        if (pagination != null) {
          print(
              '📊 Pagination: Page ${pagination['page']}/${pagination['totalPages']}, Total: ${pagination['total']}');
        }

        return {
          'appointments': appointments,
          'pagination': pagination,
        };
      }

      if (response.statusCode == 401) {
        throw ApiException(
          'Unauthorized: Token is required or invalid',
          statusCode: response.statusCode,
          responseBody: response.body,
          endpoint: endpoint,
        );
      }

      if (response.statusCode == 404) {
        print('📄 No appointments found for page $page');
        return {
          'appointments': <Map<String, dynamic>>[],
          'pagination': null,
        };
      }

      _handleApiError(endpoint, response);
      return {
        'appointments': <Map<String, dynamic>>[],
        'pagination': null,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      print('❌ Network Error: $e');
      throw ApiException('Network error occurred: $e', endpoint: endpoint);
    }
  }

  /// Get user appointments with pagination (Raw API response) - Keep for backward compatibility
  Future<List<Map<String, dynamic>>> getUserAppointmentsRaw({
    String? token,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getUserAppointmentsWithPaginationInfo(
      token: token,
      page: page,
      limit: limit,
    );

    return response['appointments'] ?? <Map<String, dynamic>>[];
  }

  /// Demo pagination for debugging - Call this from UI to see how it works
  Future<void> demoPagination({String? token}) async {
    print('\n🧪 === DEMO: Testing Pagination API ===');

    try {
      // Test the pagination
      final allAppointments = await getAllUserAppointmentsRaw(
        token: token,
        limit: 10, // You can change this to test different page sizes
      );

      print('\n✅ === DEMO RESULTS ===');
      print('📊 Total appointments fetched: ${allAppointments.length}');

      if (allAppointments.isNotEmpty) {
        print('\n📝 First 5 appointments:');
        for (int i = 0; i < allAppointments.length.clamp(0, 5); i++) {
          final apt = allAppointments[i];
          print(
              '${i + 1}. ID: ${apt['appointment_id']}, Status: ${apt['status']}, Date: ${apt['appointment_datetime']}');
        }

        // Show status distribution
        final statusCount = <String, int>{};
        for (final apt in allAppointments) {
          final status = apt['status'] as String;
          statusCount[status] = (statusCount[status] ?? 0) + 1;
        }

        print('\n📊 Status distribution:');
        statusCount.forEach((status, count) {
          print('   $status: $count appointments');
        });
      }

      print('🧪 === DEMO COMPLETE ===\n');
    } catch (e) {
      print('❌ Demo failed: $e');
    }
  }

  /// Test the pagination API with detailed logging
  Future<void> testPaginationAPI({String? token}) async {
    print('🧪 === Testing Pagination API ===');

    try {
      // Test single page first
      print('\n📄 Testing single page fetch...');
      final firstPageResponse = await getUserAppointmentsWithPaginationInfo(
        token: token,
        page: 1,
        limit: 10,
      );

      final firstPageAppointments =
          firstPageResponse['appointments'] as List<Map<String, dynamic>>;
      final paginationInfo =
          firstPageResponse['pagination'] as Map<String, dynamic>?;

      print('✅ First page: ${firstPageAppointments.length} appointments');
      if (paginationInfo != null) {
        print('📊 Pagination info: ${paginationInfo}');
        print('📊 Total pages: ${paginationInfo['totalPages']}');
        print('📊 Total appointments: ${paginationInfo['total']}');
      }

      // Test getting all appointments
      print('\n📋 Testing get all appointments...');
      final allAppointments = await getAllUserAppointmentsRaw(
        token: token,
        limit: 10,
      );

      print('✅ Total appointments fetched: ${allAppointments.length}');

      // Show sample appointments
      if (allAppointments.isNotEmpty) {
        print('\n📝 Sample appointments:');
        for (int i = 0; i < allAppointments.length.clamp(0, 3); i++) {
          final apt = allAppointments[i];
          print(
              '  ${i + 1}. ID: ${apt['appointment_id']}, Date: ${apt['appointment_datetime']}, Status: ${apt['status']}');
        }
      }

      print('\n🧪 === Pagination Test Complete ===');
    } catch (e) {
      print('❌ Pagination test failed: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
