import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterproject/features/authentication/model/patient.dart';
import 'package:flutterproject/features/authentication/model/user.dart';
import 'package:flutterproject/features/booking/model/appointment.dart';
import 'package:flutterproject/features/patient/model/payment.dart';
import 'package:flutterproject/features/home/model/doctor.dart';

class PatientController extends ChangeNotifier {
  final String _baseUrl = 'http://localhost:5001/api/patient';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Patient? _profile;
  Patient? get profile => _profile;

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  Doctor? _doctorProfile;
  Doctor? get doctorProfile => _doctorProfile;

  List<Appointment> _doctorAppointments = [];
  List<Appointment> get doctorAppointments => _doctorAppointments;

  String? _token;
  String? get token => _token;

  // Helper method to get headers with authentication
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Load token from SharedPreferences
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _token = token;
  }

  // Remove token from SharedPreferences
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    await _loadToken();
    return _token != null;
  }

  /// Đăng ký
  Future<void> register(String username, String password, String email) async {
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/register');
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(
              {'username': username, 'password': password, 'email': email}));
      if (res.statusCode != 201) throw Exception('Đăng ký thất bại');
    } finally {
      _setLoading(false);
    }
  }

  /// Xác thực email
  Future<void> verifyEmail(String email, String otpCode) async {
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/verify')
          .replace(queryParameters: {'email': email, 'otp_code': otpCode});
      final res = await http.get(uri);
      if (res.statusCode != 200) throw Exception('Xác thực thất bại');
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/login');
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'password': password}));

      if (res.statusCode == 200) {
        final responseData = json.decode(res.body) as Map<String, dynamic>;

        // Save the JWT token from response
        if (responseData['token'] != null) {
          await _saveToken(responseData['token']);
        }

        return responseData;
      }
      throw Exception('Đăng nhập thất bại');
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _removeToken();
    _profile = null;
    _appointments.clear();
    _payments.clear();
    _doctorProfile = null;
    _doctorAppointments.clear();
    notifyListeners();
  }

  /// Đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/change_password');
      final res = await http.post(uri,
          headers: _headers,
          body: json.encode(
              {'old_password': oldPassword, 'new_password': newPassword}));
      if (res.statusCode != 200) throw Exception('Đổi mật khẩu thất bại');
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy profile hiện tại
  Future<void> fetchProfile() async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/profile');
      final res = await http.get(uri, headers: _headers);
      
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        final responseBody = json.decode(res.body);
        
        // Backend trả về: {"message": "Success", "user": {..., "patient": {...}}}
        final userData = responseBody['user'];
        if (userData != null && userData['patient'] != null) {
          final patientData = userData['patient'] as Map<String, dynamic>;
          
          // Merge user data vào patient data để tạo complete patient object
          final completePatientData = {
            ...patientData,
            'user': userData, // Thêm toàn bộ user data vào patient
          };
          
          _profile = Patient.fromJson(completePatientData);
          
          print('Profile loaded: ${_profile?.user?.username}'); // Debug
          print('Profile email: ${_profile?.user?.email}'); // Debug
        } else {
          throw Exception('No patient data found');
        }
      } else {
        throw Exception('Failed to fetch profile: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Lấy profile thất bại: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Cập nhật profile (có avatar)
  Future<void> updateProfile(Map<String, String> fields, {File? avatar}) async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/update');
      if (avatar != null) {
        final req = http.MultipartRequest('PATCH', uri);
        if (_token != null) {
          req.headers['Authorization'] = 'Bearer $_token';
        }
        req.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
        req.fields.addAll(fields);
        final streamed = await req.send();
        final res = await http.Response.fromStream(streamed);
        if (res.statusCode == 200) {
          final data = json.decode(res.body)['data'];
          _profile = Patient.fromJson(data as Map<String, dynamic>);
        } else {
          throw Exception('Cập nhật thất bại');
        }
      } else {
        final res =
            await http.patch(uri, headers: _headers, body: json.encode(fields));
        if (res.statusCode == 200) {
          final data = json.decode(res.body)['data'];
          _profile = Patient.fromJson(data as Map<String, dynamic>);
        } else {
          throw Exception('Cập nhật thất bại');
        }
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Lấy lịch khám
  Future<void> fetchAppointments({Map<String, String>? queryParams}) async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/appointments')
          .replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final list = json.decode(res.body)['data'] as List;
        _appointments = list
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Lấy lịch thất bại');
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Lấy thanh toán
  Future<void> fetchPayments({Map<String, String>? queryParams}) async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri =
          Uri.parse('$_baseUrl/payments').replace(queryParameters: queryParams);
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final list = json.decode(res.body)['data'] as List;
        _payments = list
            .map((e) => Payment.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Lấy thanh toán thất bại');
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Lấy profile bác sĩ
  Future<void> fetchDoctorProfile(int userId) async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/doctor_profile/$userId');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data'];
        _doctorProfile = Doctor.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Lấy bác sĩ thất bại');
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Lấy lịch của bác sĩ
  Future<void> fetchDoctorAppointments(int userId) async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/doctor_appointments/$userId');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final list = json.decode(res.body)['data'] as List;
        _doctorAppointments = list
            .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Lấy lịch bác sĩ thất bại');
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Lấy chi tiết thanh toán
  Future<Payment> fetchPaymentById(int paymentId) async {
    await _loadToken();
    _setLoading(true);
    try {
      final uri = Uri.parse('$_baseUrl/payments/$paymentId');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data'];
        return Payment.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Lấy chi tiết thất bại');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
