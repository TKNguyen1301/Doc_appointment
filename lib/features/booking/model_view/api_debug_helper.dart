import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'appointment_controller.dart';

class ApiDebugHelper {
  /// Test different date formats to see which one backend accepts
  Future<void> testDateFormats({
    required int doctorId,
    String? token, // Allow passing token
  }) async {
    print('\n🗓️ ===== TESTING DATE FORMATS =====');

    final baseDate = DateTime(2025, 6, 10, 9, 10, 0);

    final formats = [
      baseDate.toIso8601String(), // 2025-06-10T09:10:00.000Z
      baseDate.toIso8601String().split('.')[0], // 2025-06-10T09:10:00
      '2025-06-10T09:10:00', // Exact format user mentioned
      '2025-06-10T09:10:00+07:00', // With timezone
      '2025-06-10 09:10:00', // Space instead of T
    ];

    final formatNames = [
      'ISO8601 with milliseconds',
      'ISO8601 without milliseconds',
      'Exact format (2025-06-10T09:10:00)',
      'With timezone (+07:00)',
      'Space format (YYYY-MM-DD HH:mm:ss)',
    ];

    final controller = AppointmentController();

    print(
        '🔑 Token: ${token != null ? '${token.substring(0, 20)}...' : 'NOT PROVIDED'}');
    print('👨‍⚕️ Doctor ID: $doctorId');

    for (int i = 0; i < formats.length; i++) {
      print('\n📅 Testing format ${i + 1}: ${formatNames[i]}');
      print('   Format: "${formats[i]}"');

      try {
        final result = await controller.bookAppointmentOnline(
          doctorId: doctorId,
          appointmentDatetime: formats[i],
          reason: 'Date format test #${i + 1}',
          token: token,
        );

        print('✅ Format ACCEPTED! Response keys: ${result.keys.toList()}');
        print('📄 First 200 chars: ${result.toString().substring(0, 200)}...');

        // If successful, this is the correct format
        print('\n🎯 WINNER! Format "${formats[i]}" works!');
        return;
      } catch (e) {
        print('❌ Format REJECTED: ${e.toString().substring(0, 100)}...');

        if (e.toString().contains('available')) {
          print(
              '   💡 Note: This might be availability issue, not format issue');
        } else if (e.toString().contains('date') ||
            e.toString().contains('time') ||
            e.toString().contains('format')) {
          print('   💡 Note: This is likely a date format issue');
        } else if (e.toString().contains('401') ||
            e.toString().contains('403')) {
          print('   💡 Note: Authentication issue');
        } else if (e.toString().contains('404')) {
          print('   💡 Note: Endpoint not found');
        }
      }

      // Wait a bit between requests
      await Future.delayed(Duration(milliseconds: 500));
    }

    print('\n📊 Date format testing completed! None of the formats worked.');
  }
}
