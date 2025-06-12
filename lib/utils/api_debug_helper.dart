import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiDebugHelper {
  static const String baseUrl = 'http://localhost:5001/api';

  /// Test booking API với thông tin chi tiết
  static Future<void> testBookingApi({
    required int doctorId,
    required String appointmentDatetime,
    String? reason,
    String? token,
  }) async {
    print('🧪 TESTING BOOKING API');
    print('=' * 50);

    final endpoint = '$baseUrl/appointment/book_online';
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

    print('📤 REQUEST:');
    print('   URL: $endpoint');
    print('   Method: POST');
    print('   Headers: ${headers.keys.join(', ')}');
    print('   Body: $body');
    print('-' * 30);

    try {
      final response = await http.post(uri, headers: headers, body: body);
      print('📥 RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');
      print('=' * 50);
    } catch (e) {
      print('❌ ERROR: $e');
      print('=' * 50);
    }
  }

  /// Test patient appointments API
  static Future<void> testPatientAppointmentsApi({String? token}) async {
    print('🧪 TESTING PATIENT APPOINTMENTS API');
    print('=' * 50);

    final endpoint = '$baseUrl/appointment/user';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    print('📤 REQUEST:');
    print('   URL: $endpoint');
    print('   Method: GET');
    print('   Headers: ${headers.keys.join(', ')}');
    print('-' * 30);

    try {
      final response = await http.get(uri, headers: headers);
      print('📥 RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final appointments = data['appointments'] as List?;
        print('   Number of appointments: ${appointments?.length ?? 0}');

        if (appointments != null && appointments.isNotEmpty) {
          final firstAppointment = appointments.first;
          print(
              '   First appointment patient data: ${firstAppointment['patient']}');
          print(
              '   First appointment doctor data: ${firstAppointment['doctor']}');
        }
      }
      print('=' * 50);
    } catch (e) {
      print('❌ ERROR: $e');
      print('=' * 50);
    }
  }

  /// Test appointment details API
  static Future<void> testAppointmentDetailsApi({
    required int appointmentId,
    String? token,
  }) async {
    print('🧪 TESTING APPOINTMENT DETAILS API');
    print('=' * 50);

    final endpoint = '$baseUrl/appointment/details/$appointmentId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    print('📤 REQUEST:');
    print('   URL: $endpoint');
    print('   Method: GET');
    print('   Headers: ${headers.keys.join(', ')}');
    print('-' * 30);

    try {
      final response = await http.get(uri, headers: headers);
      print('📥 RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final appointmentDetails = data['appointmentDetails'];
        print('   Patient data: ${appointmentDetails['patient']}');
        print('   Doctor data: ${appointmentDetails['doctor']}');
        print('   Medical record: ${appointmentDetails['medical_record']}');
        print('   Prescription: ${appointmentDetails['prescription']}');
        print('   Payment: ${appointmentDetails['payment']}');
        print('   Feedback: ${appointmentDetails['feedback']}');
      }
      print('=' * 50);
    } catch (e) {
      print('❌ ERROR: $e');
      print('=' * 50);
    }
  }

  /// Test feedback API - NOTE: Backend doesn't have GET by appointment endpoint
  static Future<void> testFeedbackApi({
    required int appointmentId,
    String? token,
  }) async {
    print('🧪 TESTING FEEDBACK API');
    print('=' * 50);
    print(
        'ℹ️ NOTE: Backend only has /feedbacks/add and /feedbacks/update endpoints');
    print('ℹ️ No GET endpoint to fetch feedback by appointment_id exists');
    print('=' * 50);
  }

  /// Test medical record API - NOTE: Backend doesn't have GET by appointment endpoint
  static Future<void> testMedicalRecordApi({
    required int appointmentId,
    String? token,
  }) async {
    print('🧪 TESTING MEDICAL RECORD API');
    print('=' * 50);
    print(
        'ℹ️ NOTE: Backend only has /medical-records/add and /medical-records/update endpoints');
    print(
        'ℹ️ No GET endpoint to fetch medical record by appointment_id exists');
    print('=' * 50);
  }

  /// Test prescription API - NOTE: Backend doesn't have GET by appointment endpoint
  static Future<void> testPrescriptionApi({
    required int appointmentId,
    String? token,
  }) async {
    print('🧪 TESTING PRESCRIPTION API');
    print('=' * 50);
    print(
        'ℹ️ NOTE: Backend only has /prescriptions/add and /prescriptions/update endpoints');
    print('ℹ️ No GET endpoint to fetch prescription by appointment_id exists');
    print('=' * 50);
  }

  /// Test payment API with correct endpoint
  static Future<void> testPaymentApi({
    required int appointmentId,
    String? token,
  }) async {
    print('🧪 TESTING PAYMENT API');
    print('=' * 50);

    final endpoint = '$baseUrl/appointment/payment/$appointmentId';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    print('📤 REQUEST:');
    print('   URL: $endpoint');
    print('   Method: GET');
    print('   Headers: ${headers.keys.join(', ')}');
    print('-' * 30);

    try {
      final response = await http.get(uri, headers: headers);
      print('📥 RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');
      print('=' * 50);
    } catch (e) {
      print('❌ ERROR: $e');
      print('=' * 50);
    }
  }

  /// Run comprehensive API tests
  static Future<void> runAllTests({
    String? token,
    int? testAppointmentId,
  }) async {
    print('🚀 RUNNING COMPREHENSIVE API TESTS');
    print('=' * 60);

    // Test patient appointments
    await testPatientAppointmentsApi(token: token);

    // Test appointment details if we have an appointment ID
    if (testAppointmentId != null) {
      await testAppointmentDetailsApi(
          appointmentId: testAppointmentId, token: token);
      await testFeedbackApi(appointmentId: testAppointmentId, token: token);
      await testMedicalRecordApi(
          appointmentId: testAppointmentId, token: token);
      await testPrescriptionApi(appointmentId: testAppointmentId, token: token);
      await testPaymentApi(appointmentId: testAppointmentId, token: token);
    }

    print('✅ TESTS COMPLETED');
    print('=' * 60);
  }

  /// Test multiple potential patient appointment endpoints
  static Future<void> discoverPatientAppointmentEndpoints(
      {String? token}) async {
    print('🔍 DISCOVERING PATIENT APPOINTMENT ENDPOINTS');
    print('=' * 60);

    final potentialEndpoints = [
      'http://localhost:5001/api/patient/appointments',
      'http://localhost:5001/api/appointment/patient',
      'http://localhost:5001/api/appointment/user',
      'http://localhost:5001/api/appointment/my',
      'http://localhost:5001/api/patient/my-appointments',
    ];

    for (String endpoint in potentialEndpoints) {
      print('🧪 Testing: $endpoint');
      await _testEndpoint(endpoint, 'GET', token: token);
      print('-' * 30);
    }
    print('=' * 60);
  }

  /// Helper method to test individual endpoints
  static Future<void> _testEndpoint(String endpoint, String method,
      {String? token, Map<String, dynamic>? body}) async {
    final uri = Uri.parse(endpoint);
    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri,
              headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        default:
          throw UnsupportedError('Method $method not supported');
      }

      print('   Status: ${response.statusCode}');
      if (response.statusCode < 500) {
        print('   ✅ Endpoint exists');
        if (response.statusCode == 200) {
          final responseBody = response.body;
          if (responseBody.length > 100) {
            print('   Body preview: ${responseBody.substring(0, 100)}...');
          } else {
            print('   Body: $responseBody');
          }
        }
      } else {
        print('   ❌ Server error');
      }
    } catch (e) {
      print('   ❌ Connection failed: $e');
    }
  }

  /// Test booking endpoints with real data
  static Future<void> testBookingEndpoints({
    required int doctorId,
    required String appointmentDatetime,
    String? token,
  }) async {
    print('🧪 TESTING BOOKING ENDPOINTS');
    print('=' * 50);

    // Test current booking endpoint
    final bookingData = {
      'doctor_id': doctorId,
      'appointment_datetime': appointmentDatetime,
    };

    print('📋 Booking data: $bookingData');
    print('-' * 30);

    final endpoint = 'http://localhost:5001/api/appointment/book_online';
    print('🎯 Testing: $endpoint');
    await _testEndpoint(endpoint, 'POST', token: token, body: bookingData);

    print('=' * 50);
  }

  /// Check doctor availability and shifts
  static Future<void> checkDoctorAvailability({
    required int doctorId,
    required String appointmentDatetime,
    String? token,
  }) async {
    print('🔍 CHECKING DOCTOR AVAILABILITY');
    print('=' * 60);
    print('👨‍⚕️ Doctor ID: $doctorId');
    print('📅 Requested Time: $appointmentDatetime');
    print('-' * 30);

    // Parse datetime to check date and time
    final requestedDateTime = DateTime.parse(appointmentDatetime);
    final requestedDate =
        "${requestedDateTime.year}-${requestedDateTime.month.toString().padLeft(2, '0')}-${requestedDateTime.day.toString().padLeft(2, '0')}";
    final requestedTime =
        "${requestedDateTime.hour.toString().padLeft(2, '0')}:${requestedDateTime.minute.toString().padLeft(2, '0')}";

    print('📅 Requested Date: $requestedDate');
    print('🕒 Requested Time: $requestedTime');
    print('-' * 30);

    // Check doctor shifts
    await _checkDoctorShifts(doctorId, requestedDate, token: token);

    // Check existing appointments for that doctor
    await _checkDoctorExistingAppointments(doctorId, requestedDate,
        token: token);

    // Test the actual booking endpoint
    await testBookingEndpoints(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      token: token,
    );

    print('=' * 60);
  }

  /// Check doctor shifts for a specific date
  static Future<void> _checkDoctorShifts(int doctorId, String date,
      {String? token}) async {
    print('📋 CHECKING DOCTOR SHIFTS FOR $date');

    final endpoint = 'http://localhost:5001/api/doctor/shifts';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);
      print('   Doctor Shifts Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('   ✅ Doctor shifts found');
        print('   📄 Shifts data: ${response.body}');

        // Parse and analyze shifts for the requested date
        final shifts = data['shifts'] ?? data['data'] ?? [];
        if (shifts is List) {
          final dateShifts = shifts.where((shift) {
            return shift['shift_date']?.toString().contains(date) == true &&
                shift['doctor_id'] == doctorId;
          }).toList();

          print(
              '   📊 Shifts for Doctor $doctorId on $date: ${dateShifts.length}');

          if (dateShifts.isEmpty) {
            print('   ❌ NO SHIFTS FOUND - This is why booking fails!');
            print('   💡 Doctor needs shifts created in database');
          } else {
            for (var shift in dateShifts) {
              print(
                  '   📅 Shift: ${shift['shift_type']} (${shift['start_time']} - ${shift['end_time']})');
            }
          }
        }
      } else if (response.statusCode == 401) {
        print('   ⚠️ Unauthorized - need doctor authentication to see shifts');
        print('   💡 Try getting doctor token or check as admin');
      } else {
        print('   ❌ Failed to get shifts: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Error checking shifts: $e');
    }
    print('-' * 30);
  }

  /// Check doctor's existing appointments for a date
  static Future<void> _checkDoctorExistingAppointments(
      int doctorId, String date,
      {String? token}) async {
    print('📋 CHECKING DOCTOR EXISTING APPOINTMENTS FOR $date');

    final endpoint = 'http://localhost:5001/api/doctor/appointments';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);
      print('   Doctor Appointments Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('   ✅ Doctor appointments found');

        // Try to find appointments for the requested date
        final appointments = data['appointments'] ?? data['data'] ?? [];
        if (appointments is List) {
          final dateAppointments = appointments.where((apt) {
            final aptDate = apt['appointment_datetime']?.toString() ?? '';
            return aptDate.contains(date);
          }).toList();

          print(
              '   📊 Total appointments on $date: ${dateAppointments.length}');
          for (var apt in dateAppointments) {
            print(
                '   📅 ${apt['appointment_datetime']} - Status: ${apt['status']}');
          }
        }
      } else if (response.statusCode == 401) {
        print('   ⚠️ Unauthorized - need doctor token');
      } else {
        print('   ❌ Failed to get appointments: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Error checking appointments: $e');
    }
    print('-' * 30);
  }

  /// Get doctor information
  static Future<void> checkDoctorInfo(int doctorId, {String? token}) async {
    print('🔍 CHECKING DOCTOR INFO');
    print('=' * 50);

    final endpoint = 'http://localhost:5001/api/doctor/all';
    final uri = Uri.parse(endpoint);

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);
      print('   All Doctors Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final doctors = data['doctors'] ?? data['data'] ?? [];

        if (doctors is List) {
          final doctor = doctors.firstWhere(
            (d) => d['doctor_id'] == doctorId,
            orElse: () => null,
          );

          if (doctor != null) {
            print('   ✅ Doctor found:');
            print('   👨‍⚕️ Name: ${doctor['user']?['username'] ?? 'N/A'}');
            print(
                '   🏥 Specialization: ${doctor['specialization']?['name'] ?? 'N/A'}');
            print('   ⭐ Rating: ${doctor['rating'] ?? 'N/A'}');
            print(
                '   📋 Experience: ${doctor['experience_years'] ?? 'N/A'} years');
          } else {
            print('   ❌ Doctor ID $doctorId not found in doctors list');
          }
        }
      } else {
        print('   ❌ Failed to get doctors: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Error checking doctor info: $e');
    }
    print('=' * 50);
  }

  /// Comprehensive booking test - run this to debug the exact issue user is facing
  static Future<void> runBookingDiagnostics({
    required int doctorId,
    required String appointmentDatetime,
    String? token,
  }) async {
    print('🚀 RUNNING COMPREHENSIVE BOOKING DIAGNOSTICS');
    print('=' * 70);
    print('🎯 Testing scenario: Doctor ID $doctorId at $appointmentDatetime');
    print('=' * 70);

    // Step 1: Check doctor info
    print('STEP 1: Doctor Information');
    await checkDoctorInfo(doctorId, token: token);

    // Step 2: Analyze booking failure with backend logic
    print('STEP 2: Booking Failure Analysis');
    await analyzeBookingFailure(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      token: token,
    );

    // Step 3: Check doctor availability/shifts
    print('STEP 3: Doctor Availability Check');
    await checkDoctorAvailability(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      token: token,
    );

    // Step 4: Check all doctor shifts (to see if any doctor has shifts)
    print('STEP 4: All Doctor Shifts Check');
    await checkAllDoctorShifts(token: token);

    // Step 5: Test actual booking
    print('STEP 5: Actual Booking Test');
    await testBookingEndpoints(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      token: token,
    );

    print('🏁 DIAGNOSTICS COMPLETE');
    print('=' * 70);
    print('📋 LIKELY ISSUES FOUND:');
    print('   1. ❌ Doctor has no DoctorShift records in database');
    print('   2. ❌ Shift times don\'t cover requested appointment time');
    print(
        '   3. ❌ Shift type doesn\'t match hour logic (morning ≤12, afternoon >12)');
    print('');
    print('🔧 SOLUTIONS:');
    print('   1. 🗄️ Add DoctorShift records to database');
    print('   2. 📅 Ensure shift dates match booking dates');
    print('   3. ⏰ Verify start_time ≤ appointment_time < end_time');
    print('   4. 🌅🌆 Check shift_type matches hour (morning/afternoon)');
    print('=' * 70);
  }

  /// Quick test for user's exact scenario - UPDATED
  static Future<void> testUserScenario({String? token}) async {
    await runBookingDiagnostics(
      doctorId: 4,
      appointmentDatetime: '2025-06-15T08:20:00.000',
      token: token,
    );
  }

  /// Check all doctors to see who has shifts
  static Future<void> checkAllDoctorShifts({String? token}) async {
    print('🔍 CHECKING ALL DOCTOR SHIFTS');
    print('=' * 50);

    // First get all doctors
    final doctorsEndpoint = 'http://localhost:5001/api/doctor/all';
    final doctorsUri = Uri.parse(doctorsEndpoint);

    try {
      final doctorsResponse = await http.get(doctorsUri);
      if (doctorsResponse.statusCode == 200) {
        final doctorsData = jsonDecode(doctorsResponse.body);
        final doctors = doctorsData['doctors'] ?? doctorsData['data'] ?? [];

        print('📊 Found ${doctors.length} doctors');

        // Check shifts for each doctor
        for (var doctor in doctors) {
          final doctorId = doctor['doctor_id'];
          final doctorName = doctor['user']?['username'] ?? 'Unknown';
          print('-' * 30);
          print('👨‍⚕️ Doctor $doctorId: $doctorName');

          // Try to get doctor shifts (might need doctor token)
          await _checkDoctorShifts(doctorId, '2025-06-15', token: token);
        }
      }
    } catch (e) {
      print('❌ Error getting doctors: $e');
    }

    print('=' * 50);
  }

  /// Analyze specific booking failure
  static Future<void> analyzeBookingFailure({
    required int doctorId,
    required String appointmentDatetime,
    String? token,
  }) async {
    print('🔬 ANALYZING BOOKING FAILURE');
    print('=' * 60);

    final requestedDateTime = DateTime.parse(appointmentDatetime);
    final shiftDate =
        "${requestedDateTime.year}-${requestedDateTime.month.toString().padLeft(2, '0')}-${requestedDateTime.day.toString().padLeft(2, '0')}";
    final shiftTime =
        "${requestedDateTime.hour.toString().padLeft(2, '0')}:${requestedDateTime.minute.toString().padLeft(2, '0')}:00";
    final hour = requestedDateTime.hour;
    final shiftType = hour <= 12 ? 'morning' : 'afternoon';

    print('📋 Request Analysis:');
    print('   Doctor ID: $doctorId');
    print('   Date: $shiftDate');
    print('   Time: $shiftTime');
    print('   Hour: $hour');
    print('   Expected Shift Type: $shiftType');
    print('-' * 30);

    print('🔍 Backend Logic Requirements:');
    print('   1. DoctorShift record must exist where:');
    print('      - doctor_id = $doctorId');
    print('      - shift_date = "$shiftDate"');
    print('      - shift_type = "$shiftType"');
    print('      - start_time <= "$shiftTime"');
    print('      - end_time > "$shiftTime"');
    print('-' * 30);

    // Check if any shifts exist for this doctor
    await _checkDoctorShifts(doctorId, shiftDate, token: token);

    print('🔧 Solutions:');
    print('   1. Add DoctorShift records to database');
    print('   2. Ensure shifts cover requested time');
    print('   3. Check shift_type matches hour logic');
    print('=' * 60);
  }

  /// Test server connection and basic endpoints
  static Future<void> testServerConnection() async {
    print('🌐 TESTING SERVER CONNECTION');
    print('=' * 50);

    final testEndpoints = [
      'http://localhost:5001/',
      'http://localhost:5001/api',
      'http://localhost:5001/api/appointment',
      'http://localhost:5001/api/appointment/book_online',
      'http://localhost:5001/api/patient',
      'http://localhost:5001/api/doctor',
    ];

    for (String endpoint in testEndpoints) {
      try {
        print('📡 Testing: $endpoint');
        final response =
            await http.get(Uri.parse(endpoint)).timeout(Duration(seconds: 5));
        print('   Status: ${response.statusCode}');
        if (response.statusCode == 404) {
          print('   ❌ Not Found - Check server routing');
        } else if (response.statusCode < 500) {
          print('   ✅ Endpoint accessible');
        }
      } catch (e) {
        print('   ❌ Connection failed: $e');
      }
      print('-' * 20);
    }
    print('=' * 50);
  }

  /// Test booking endpoint with different HTTP methods
  static Future<void> testBookingEndpointMethods({String? token}) async {
    print('🧪 TESTING BOOKING ENDPOINT METHODS');
    print('=' * 50);

    final endpoint = 'http://localhost:5001/api/appointment/book_online';
    final methods = ['GET', 'POST', 'PUT', 'DELETE'];

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final testBody = {
      'doctor_id': 2,
      'appointment_datetime': '2025-06-14T08:00:00.000',
    };

    for (String method in methods) {
      try {
        print('📤 Testing $method: $endpoint');

        http.Response response;
        switch (method) {
          case 'GET':
            response = await http.get(Uri.parse(endpoint), headers: headers);
            break;
          case 'POST':
            response = await http.post(Uri.parse(endpoint),
                headers: headers, body: jsonEncode(testBody));
            break;
          case 'PUT':
            response = await http.put(Uri.parse(endpoint),
                headers: headers, body: jsonEncode(testBody));
            break;
          case 'DELETE':
            response = await http.delete(Uri.parse(endpoint), headers: headers);
            break;
          default:
            continue;
        }

        print('   Status: ${response.statusCode}');
        print(
            '   Body: ${response.body.substring(0, min(100, response.body.length))}');

        if (response.statusCode == 404) {
          print('   ❌ Route not found for $method');
        } else if (response.statusCode == 405) {
          print('   ❌ Method not allowed');
        } else if (response.statusCode < 500) {
          print('   ✅ Method accepted');
        }
      } catch (e) {
        print('   ❌ Error: $e');
      }
      print('-' * 20);
    }
    print('=' * 50);
  }

  /// Test alternative booking endpoints
  static Future<void> testAlternativeBookingEndpoints({
    required int doctorId,
    required String appointmentDatetime,
    String? token,
  }) async {
    print('🔄 TESTING ALTERNATIVE BOOKING ENDPOINTS');
    print('=' * 60);

    final alternativeEndpoints = [
      'http://localhost:5001/api/appointment/book_online',
      'http://localhost:5001/api/appointment/book-online',
      'http://localhost:5001/api/appointment/bookonline',
      'http://localhost:5001/api/appointment/create',
      'http://localhost:5001/api/appointment/new',
      'http://localhost:5001/api/appointment/',
      'http://localhost:5001/api/appointments/book_online',
      'http://localhost:5001/api/appointments/create',
    ];

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    final requestBody = {
      'doctor_id': doctorId,
      'appointment_datetime': appointmentDatetime,
    };

    for (String endpoint in alternativeEndpoints) {
      try {
        print('🎯 Testing: $endpoint');
        final response = await http.post(
          Uri.parse(endpoint),
          headers: headers,
          body: jsonEncode(requestBody),
        );

        print('   Status: ${response.statusCode}');
        if (response.statusCode == 404) {
          print('   ❌ Not found');
        } else if (response.statusCode == 400) {
          print('   ⚠️ Bad request: ${response.body}');
        } else if (response.statusCode < 500) {
          print('   ✅ Endpoint found: ${response.body}');
        }
      } catch (e) {
        print('   ❌ Error: $e');
      }
      print('-' * 30);
    }
    print('=' * 60);
  }

  /// Comprehensive server diagnostics
  static Future<void> runServerDiagnostics({
    String? token,
    int doctorId = 2,
    String appointmentDatetime = '2025-06-14T08:00:00.000',
  }) async {
    print('🚀 RUNNING COMPREHENSIVE SERVER DIAGNOSTICS');
    print('=' * 70);

    // Step 1: Test server connection
    await testServerConnection();

    // Step 2: Test booking endpoint methods
    await testBookingEndpointMethods(token: token);

    // Step 3: Test alternative endpoints
    await testAlternativeBookingEndpoints(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      token: token,
    );

    // Step 4: Test original booking diagnosis
    await testBookingEndpoints(
      doctorId: doctorId,
      appointmentDatetime: appointmentDatetime,
      token: token,
    );

    print('🏁 SERVER DIAGNOSTICS COMPLETE');
    print('=' * 70);
    print('📋 CHECK RESULTS ABOVE FOR:');
    print('   1. Server connectivity issues');
    print('   2. Correct endpoint URLs');
    print('   3. HTTP method compatibility');
    print('   4. Authentication problems');
    print('=' * 70);
  }
}
