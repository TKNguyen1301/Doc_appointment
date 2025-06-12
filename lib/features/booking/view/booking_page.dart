import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterproject/features/authentication/model/patient.dart';
import 'package:flutterproject/features/booking/view/confirm_page.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/features/home/view_model/doctor_controller.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';
import 'package:flutterproject/features/authentication/screens.onboarding/login/login.dart';
import 'package:flutterproject/features/booking/widget/appointment_progress_indicator.dart';
import 'package:flutterproject/features/booking/widget/doctor_appointment_card.dart';
import 'package:flutterproject/features/booking/widget/patient_info_section.dart';
import 'package:flutterproject/features/booking/widget/date_selector.dart';
import 'package:flutterproject/features/booking/widget/time_slot_section.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/formatters/date_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  final int doctorId;
  const BookingPage({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final DoctorController _doctorController = DoctorController();

  Doctor? _doctor;
  bool _isLoading = true;
  String? _error;
  bool _isUserLoggedIn = false;

  Map<String, String> _patientProfile = {
    'name': 'Chưa đăng nhập',
    'gender': '--',
    'birthdate': '--',
    'phone': '--',
  };

  late DateTime _displayedMonth;
  List<Map<String, dynamic>> _dates = [];
  int _selectedDateIndex = 0;
  String _selectedSession = 'morning';
  int _selectedTimeIndex = -1;

  final Map<String, List<String>> _bookedSlots = {
    '2025-06-20': ['07:30 - 07:40', '08:00 - 08:10', '17:30 - 17:40'],
    '2025-06-21': ['07:40 - 07:50', '08:20 - 08:30', '18:10 - 18:20'],
  };

  final List<String> _morningSlots = [
    '07:00',
    '07:10',
    '07:20',
    '07:30',
    '07:40',
    '07:50',
    '08:00',
    '08:10',
    '08:20',
    '08:30',
    '08:40',
    '08:50',
    '09:00',
    '09:10',
    '09:20',
    '09:30',
    '09:40',
    '09:50',
    '10:00',
    '10:10',
    '10:20',
    '10:30',
    '10:40',
    '10:50',
    '11:00',
    '11:10',
    '11:20',
    '11:30',
    '11:40',
    '11:50',
    '12:00',
  ];

  final List<String> _afternoonSlots = [
    '13:30',
    '13:40',
    '13:50',
    '14:00',
    '14:10',
    '14:20',
    '14:30',
    '14:40',
    '14:50',
    '15:00',
    '15:10',
    '15:20',
    '15:30',
    '15:40',
    '15:50',
    '16:00',
    '16:10',
    '16:20',
    '16:30',
    '16:40',
    '16:50',
  ];

  String _extraInfoText = '';
  List<File> _extraImages = [];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _generateDatesForMonth(_displayedMonth);
    _fetchDoctorInfo();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final patientController =
        Provider.of<PatientController>(context, listen: false);
    final isAuth = await patientController.isAuthenticated();

    if (isAuth && patientController.profile == null) {
      try {
        await patientController.fetchProfile();
      } catch (e) {
        print('Failed to fetch profile: $e');
      }
    }

    setState(() {
      _isUserLoggedIn = patientController.profile != null;

      if (_isUserLoggedIn && patientController.profile != null) {
        final profile = patientController.profile!;
        _patientProfile = {
          'name': profile.user?.username ?? 'Không có tên',
          'gender': profile.gender != null
              ? (profile.gender == Gender.male
                  ? 'Nam'
                  : profile.gender == Gender.female
                      ? 'Nữ'
                      : 'Khác')
              : '--',
          'birthdate': profile.dateOfBirth != null
              ? '${profile.dateOfBirth!.day.toString().padLeft(2, '0')}/${profile.dateOfBirth!.month.toString().padLeft(2, '0')}/${profile.dateOfBirth!.year}'
              : '--',
          'phone': profile.phoneNumber ?? '--',
        };
      }
    });
  }

  Future<void> _fetchDoctorInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final patientController =
          Provider.of<PatientController>(context, listen: false);
      await patientController.isAuthenticated();
      final token = patientController.token;

      final List<Doctor> doctors =
          await _doctorController.fetchAllDoctors(token: token);
      final Doctor? foundDoctor =
          doctors.where((d) => d.doctorId == widget.doctorId).firstOrNull;

      if (foundDoctor != null) {
        setState(() {
          _doctor = foundDoctor;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Doctor not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _generateDatesForMonth(DateTime monthYear) {
    final int year = monthYear.year;
    final int month = monthYear.month;
    final DateTime now = DateTime.now();

    final int daysInMonth = DateTime(year, month + 1, 0).day;

    int startDay;
    if (year == now.year && month == now.month) {
      startDay = now.day;
    } else if (DateTime(year, month).isAfter(DateTime(now.year, now.month))) {
      startDay = 1;
    } else {
      startDay = daysInMonth + 1; // No available dates in past months
    }

    List<Map<String, dynamic>> tempDates = [];
    for (int d = startDay; d <= daysInMonth; d++) {
      final dateObj = DateTime(year, month, d);
      final String weekdayStr =
          dateObj.weekday == 7 ? 'CN' : 'T${dateObj.weekday + 1}';
      int availableSlots = _calculateAvailableSlots(dateObj);
      tempDates.add({
        'weekday': weekdayStr,
        'day': d,
        'dateObj': dateObj,
        'slots': availableSlots,
      });
    }

    _dates = tempDates;
    // Fix: Ensure selectedDateIndex is within bounds
    if (_selectedDateIndex >= _dates.length) {
      _selectedDateIndex = _dates.isNotEmpty ? 0 : -1;
    }
    setState(() {});
  }

  int _calculateAvailableSlots(DateTime dateObj) {
    final String key = DateFormatter.formatDateKey(dateObj);
    final List<String> bookedForDay = _bookedSlots[key] ?? [];

    final int totalSlots = _morningSlots.length + _afternoonSlots.length;
    int pastCount = 0;

    DateTime now = DateTime.now();

    if (dateObj.year == now.year &&
        dateObj.month == now.month &&
        dateObj.day == now.day) {
      for (String slot in _morningSlots) {
        DateTime slotEnd = DateFormatter.parseSlotEndTime(dateObj, slot);
        if (slotEnd.isBefore(now) || slotEnd.isAtSameMomentAs(now)) {
          pastCount++;
        }
      }
      for (String slot in _afternoonSlots) {
        DateTime slotEnd = DateFormatter.parseSlotEndTime(dateObj, slot);
        if (slotEnd.isBefore(now) || slotEnd.isAtSameMomentAs(now)) {
          pastCount++;
        }
      }
    }

    int bookedCount = bookedForDay.length;
    int available = totalSlots - pastCount - bookedCount;
    if (available < 0) available = 0;
    return available;
  }

  Future<void> _pickMonthYear() async {
    final DateTime now = DateTime.now();
    final int currentYear = now.year;
    int tempSelectedYear = _displayedMonth.year;
    int tempSelectedMonth = _displayedMonth.month;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Chọn tháng và năm',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tháng',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: tempSelectedMonth,
                                  isExpanded: true,
                                  items: List.generate(
                                    12,
                                    (index) => DropdownMenuItem(
                                      value: index + 1,
                                      child: Text(
                                          'Tháng ${(index + 1).toString().padLeft(2, '0')}'),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      // Kiểm tra tháng không được trong quá khứ
                                      final DateTime selectedMonth =
                                          DateTime(tempSelectedYear, value, 1);
                                      final DateTime currentMonth =
                                          DateTime(now.year, now.month, 1);
                                      if (selectedMonth
                                          .isBefore(currentMonth)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Không thể chọn tháng trong quá khứ')),
                                        );
                                        return;
                                      }
                                      setModalState(
                                          () => tempSelectedMonth = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Năm',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: tempSelectedYear,
                                  isExpanded: true,
                                  items: List.generate(
                                    3, // Chỉ cho phép chọn năm hiện tại và 2 năm tới
                                    (index) => DropdownMenuItem(
                                      value: currentYear + index,
                                      child: Text('${currentYear + index}'),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setModalState(
                                          () => tempSelectedYear = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16), // thêm padding chuẩn
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _displayedMonth = DateTime(tempSelectedYear, tempSelectedMonth, 1);
                            _generateDatesForMonth(_displayedMonth);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16), // đảm bảo text không bị cắt
                          ),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Yêu cầu đăng nhập',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: const Text(
          'Bạn cần đăng nhập để đặt lịch khám.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              )
                  .then((_) {
                _checkLoginStatus();
              });
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  // Thêm method để tính fee
  int get _calculatedFee {
    // Ưu tiên: Specialization fees > Default
    if (_doctor?.specialization?.fees != null &&
        _doctor!.specialization!.fees > 0) {
      return _doctor!.specialization!.fees;
    }
    return 0; // Default fee
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Đặt lịch khám',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _doctor == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Đặt lịch khám',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Không tìm thấy thông tin bác sĩ',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDoctorInfo,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            const Text('Đặt lịch khám', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AppointmentProgressIndicator(currentStep: 1),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorAppointmentCard(doctor: _doctor!),
                  const SizedBox(height: 16),
                  PatientInfoSection(
                    isUserLoggedIn: _isUserLoggedIn,
                    patientProfile: _patientProfile,
                    onLogin: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      )
                          .then((_) {
                        _checkLoginStatus();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DateSelector(
                    displayedMonth: _displayedMonth,
                    dates: _dates,
                    selectedDateIndex: _selectedDateIndex,
                    onDateSelected: (index) {
                      setState(() {
                        _selectedDateIndex = index;
                        _selectedTimeIndex = -1;
                      });
                    },
                    onMonthYearPick: _pickMonthYear,
                  ),
                  const SizedBox(height: 16),
                  if (_dates.isNotEmpty &&
                      _selectedDateIndex < _dates.length) ...[
                    TimeSlotsSection(
                      selectedSession: _selectedSession,
                      selectedTimeIndex: _selectedTimeIndex,
                      morningSlots: _morningSlots,
                      afternoonSlots: _afternoonSlots,
                      dates: _dates,
                      selectedDateIndex: _selectedDateIndex,
                      bookedSlots: _bookedSlots,
                      onTimeSlotSelected: (session, index) {
                        setState(() {
                          _selectedSession = session;
                          _selectedTimeIndex = index;
                        });
                      },
                      onSessionChanged: (session) {
                        setState(() {
                          _selectedSession = session;
                          _selectedTimeIndex = -1;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_isUserLoggedIn) ...[
                    const Text(
                      'Thông tin bổ sung (không bắt buộc)',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Lý do khám, triệu chứng...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (val) =>
                          setState(() => _extraInfoText = val.trim()),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (!_isUserLoggedIn) {
                    _showLoginRequiredDialog();
                    return;
                  }

                  if (_selectedTimeIndex < 0 ||
                      _dates.isEmpty ||
                      _selectedDateIndex >= _dates.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vui lòng chọn khung giờ khám')),
                    );
                    return;
                  }

                  final Map<String, dynamic> dayInfo =
                      _dates[_selectedDateIndex];
                  final DateTime dateObj = dayInfo['dateObj'] as DateTime;

                  final bool isMorning = (_selectedSession == 'morning');
                  final List<String> currentSlots =
                      isMorning ? _morningSlots : _afternoonSlots;
                  final String chosenSlot = currentSlots[_selectedTimeIndex];

                  // Tạo datetime cho appointment từ slot được chọn
                  final DateTime slotTime =
                      DateFormatter.parseSlotStartTime(dateObj, chosenSlot);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ConfirmationPage(
                        doctor: _doctor!,
                        selectedDate: dateObj,
                        selectedSlot: chosenSlot,
                        patientProfile: _patientProfile,
                        appointmentDateTime: slotTime,
                        extraInfoText: _extraInfoText,
                        extraImages: _extraImages,
                      ),
                    ),
                  );
                },
                child: Text(
                  _isUserLoggedIn ? 'Tiếp tục' : 'Đăng nhập để đặt lịch',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
