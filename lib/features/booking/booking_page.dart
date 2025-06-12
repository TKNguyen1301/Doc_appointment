import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterproject/features/booking/confirm_page.dart';
import 'package:flutterproject/features/home/model/doctor.dart'; // Sử dụ
import 'package:image_picker/image_picker.dart';

class BookingPage extends StatefulWidget {
  final Doctor doctor;
  const BookingPage({Key? key, required this.doctor}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  /// Mô phỏng dữ liệu hồ sơ bệnh nhân cố định. Bạn có thể thay bằng API hoặc dữ liệu thật.
  final Map<String, String> _patientProfile = {
    'name': 'Trần Khánh Nguyên',
    'gender': 'Nam',
    'birthdate': '13/01/2003',
    'phone': '0896 204 571',
  };

  /// Tháng-năm đang hiển thị trong selector (lưu ngày = 1).
  late DateTime _displayedMonth;

  /// Danh sách ngày còn lại trong tháng (_dates) theo thời gian thực: mỗi phần tử chứa weekday, day, slots, dateObj.
  List<Map<String, dynamic>> _dates = [];

  int _selectedDateIndex = 0;
  String _selectedSession = 'morning'; // 'morning' hoặc 'afternoon'
  int _selectedTimeIndex = -1;         // index của khung giờ đã chọn (trong buổi tương ứng)

  /// Giả lập dữ liệu các khung giờ đã được đặt cho mỗi ngày.
  /// Key: 'yyyy-MM-dd', Value: List of slot strings (ví dụ '07:30 - 07:40') đã bị đặt.
  /// Trong thực tế, bạn gọi API để lấy data này.
  final Map<String, List<String>> _bookedSlots = {
    '2025-06-20': ['07:30 - 07:40', '08:00 - 08:10', '17:30 - 17:40'],
    '2025-06-21': ['07:40 - 07:50', '08:20 - 08:30', '18:10 - 18:20'],
    // Thêm ví dụ cho các ngày khác nếu cần
  };

  /// Các khung giờ cho buổi sáng / buổi chiều. Bạn có thể fetch động
  final List<String> _morningSlots = [
    '07:30 - 07:40',
    '07:40 - 07:50',
    '07:50 - 08:00',
    '08:00 - 08:10',
    '08:10 - 08:20',
    '08:20 - 08:30',
    '08:30 - 08:40',
    '08:40 - 08:50',
    '08:50 - 09:00',
  ];

  final List<String> _afternoonSlots = [
    '17:30 - 17:40',
    '17:40 - 17:50',
    '17:50 - 18:00',
    '18:00 - 18:10',
    '18:10 - 18:20',
    '18:20 - 18:30',
    '18:30 - 18:40',
    '18:40 - 18:50',
    '18:50 - 19:00',
    '19:00 - 19:10',
    '19:10 - 19:20',
    '19:20 - 19:30',
    '19:30 - 19:40',
    '19:40 - 19:50',
    '19:50 - 20:00',
  ];

  /// Dữ liệu phụ: lý do thăm khám và hình ảnh toa thuốc do người dùng thêm.
  String _extraInfoText = '';
  List<File> _extraImages = [];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _generateDatesForMonth(_displayedMonth);
    _selectedDateIndex = 0;
  }

  /// Tạo danh sách ngày còn lại trong tháng dựa trên monthYear, kèm số slots khả dụng.
  void _generateDatesForMonth(DateTime monthYear) {
    final int year = monthYear.year;
    final int month = monthYear.month;
    final DateTime now = DateTime.now();

    // Tính số ngày trong tháng
    final int daysInMonth = DateTime(year, month + 1, 0).day;

    // Xác định ngày bắt đầu:
    int startDay;
    if (year == now.year && month == now.month) {
      // Nếu là tháng hiện tại, bắt đầu từ ngày hôm nay
      startDay = now.day;
    } else if (DateTime(year, month).isAfter(DateTime(now.year, now.month))) {
      // Nếu chọn tháng sau tháng hiện tại, bắt đầu từ ngày 1
      startDay = 1;
    } else {
      // Nếu chọn tháng đã qua, không có ngày nào còn lại
      startDay = daysInMonth + 1;
    }

    // Tạo danh sách ngày
    List<Map<String, dynamic>> tempDates = [];
    for (int d = startDay; d <= daysInMonth; d++) {
      final dateObj = DateTime(year, month, d);
      final String weekdayStr =
          dateObj.weekday == 7 ? 'CN' : 'T${dateObj.weekday + 1}';
      // Tính số slots khả dụng cho ngày dateObj
      int availableSlots = _calculateAvailableSlots(dateObj);
      tempDates.add({
        'weekday': weekdayStr,
        'day': d,
        'dateObj': dateObj,
        'slots': availableSlots,
      });
    }

    _dates = tempDates;
    if (_selectedDateIndex >= _dates.length) {
      _selectedDateIndex = 0;
    }
    setState(() {});
  }

  /// Tính số slots khả dụng cho ngày dateObj
  int _calculateAvailableSlots(DateTime dateObj) {
    final String key = _formatDateKey(dateObj);
    final List<String> bookedForDay = _bookedSlots[key] ?? [];

    // Tổng khung giờ: chiều + sáng
    final int totalSlots = _morningSlots.length + _afternoonSlots.length;
    int pastCount = 0;

    DateTime now = DateTime.now();

    // Nếu date là hôm nay, đếm các khung giờ buổi sáng và chiều đã qua
    if (dateObj.year == now.year &&
        dateObj.month == now.month &&
        dateObj.day == now.day) {
      // Duyệt morning
      for (String slot in _morningSlots) {
        DateTime slotEnd = _parseSlotEndTime(dateObj, slot);
        if (slotEnd.isBefore(now) || slotEnd.isAtSameMomentAs(now)) {
          pastCount++;
        }
      }
      // Duyệt afternoon
      for (String slot in _afternoonSlots) {
        DateTime slotEnd = _parseSlotEndTime(dateObj, slot);
        if (slotEnd.isBefore(now) || slotEnd.isAtSameMomentAs(now)) {
          pastCount++;
        }
      }
    }

    // Số booked
    int bookedCount = bookedForDay.length;

    int available = totalSlots - pastCount - bookedCount;
    if (available < 0) available = 0;
    return available;
  }

  /// Parse lấy thời gian kết thúc của một slot (chuỗi 'HH:mm - HH:mm')
  DateTime _parseSlotEndTime(DateTime dateObj, String slot) {
    // Ví dụ slot = '07:30 - 07:40'
    final parts = slot.split('-');
    final endPart = parts[1].trim(); // '07:40'
    final hm = endPart.split(':');
    final int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);
    return DateTime(dateObj.year, dateObj.month, dateObj.day, hour, minute);
  }

  /// Parse lấy thời gian bắt đầu của một slot (chuỗi 'HH:mm - HH:mm')
  DateTime _parseSlotStartTime(DateTime dateObj, String slot) {
    // Ví dụ slot = '07:30 - 07:40'
    final parts = slot.split('-');
    final startPart = parts[0].trim(); // '07:30'
    final hm = startPart.split(':');
    final int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);
    return DateTime(dateObj.year, dateObj.month, dateObj.day, hour, minute);
  }

  /// Format DateTime thành key 'yyyy-MM-dd'
  String _formatDateKey(DateTime dateObj) {
    final y = dateObj.year.toString().padLeft(4, '0');
    final m = dateObj.month.toString().padLeft(2, '0');
    final d = dateObj.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Hiển thị popup chỉ để chọn tháng-năm (không chọn ngày cụ thể)
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
    int selectedMonth = tempSelectedMonth;
    int selectedYear = tempSelectedYear;

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
                  // Chọn Tháng
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tháng', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedMonth,
                              isExpanded: true,
                              items: List.generate(
                                12,
                                (index) => DropdownMenuItem(
                                  value: index + 1,
                                  child: Text('Tháng ${(index + 1).toString().padLeft(2, '0')}'),
                                ),
                              ),
                              onChanged: (value) {
                                setModalState(() => selectedMonth = value!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Chọn Năm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Năm', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedYear,
                              isExpanded: true,
                              items: List.generate(
                                5,
                                (index) => DropdownMenuItem(
                                  value: currentYear - 2 + index,
                                  child: Text('${currentYear - 2 + index}'),
                                ),
                              ),
                              onChanged: (value) {
                                setModalState(() => selectedYear = value!);
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        child: Text('Hủy'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        tempSelectedMonth = selectedMonth;
                        tempSelectedYear = selectedYear;
                        _displayedMonth = DateTime(tempSelectedYear, tempSelectedMonth, 1);
                        _generateDatesForMonth(_displayedMonth);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  /// Hiển thị modal bottom sheet để nhập "Lý do thăm khám" và upload hình ảnh.
  Future<void> _showExtraInfoModal() async {
    final TextEditingController symptomController =
        TextEditingController(text: _extraInfoText);
    List<XFile> pickedImages = _extraImages.map((file) => XFile(file.path)).toList();
    final ImagePicker picker = ImagePicker();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool canSubmit = symptomController.text.trim().isNotEmpty || pickedImages.isNotEmpty;

            Future<void> _pickImage() async {
              if (pickedImages.length >= 5) return;
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setModalState(() {
                  pickedImages.add(image);
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Lý do thăm khám',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 24),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Triệu chứng',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: symptomController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Lý do khám, triệu chứng, trạng thái, tiền sử bệnh...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {}); // cập nhật trạng thái nút
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Toa thuốc, hình ảnh',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toa (đơn) thuốc đang dùng gần đây, tối đa 5 hình ảnh, dung lượng không quá 15MB.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Thumbnails của các ảnh đã chọn
                        for (var imgFile in pickedImages)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(imgFile.path),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    size: 20,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      pickedImages.remove(imgFile);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        // Nút thêm ảnh
                        if (pickedImages.length < 5)
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSubmit ? Colors.blue : Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: canSubmit
                            ? () {
                                setState(() {
                                  _extraInfoText = symptomController.text.trim();
                                  _extraImages = pickedImages
                                      .map((xfile) => File(xfile.path))
                                      .toList();
                                });
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: Text(
                          'Thêm thông tin',
                          style: TextStyle(
                            fontSize: 16,
                            color: canSubmit ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String monthLabel =
        'Tháng ${_displayedMonth.month.toString().padLeft(2, '0')}/${_displayedMonth.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Đặt lịch khám',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Bước 1: Chọn lịch khám (đã hoàn thành)
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Chọn lịch khám',
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ],
                  ),

                  // Mũi tên
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),

                  // Bước 2: Xác nhận (đang active)
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '2',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Xác nhận',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),

                  // Mũi tên tiếp theo
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),

                  // Bước 3: Nhận lịch (chưa hoàn thành)
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '3',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nhận lịch hẹn',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================
                  // 4.1. Thông tin bác sĩ ở trên cùng - CẬP NHẬT
                  // ============================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: widget.doctor.user?.avatar != null && widget.doctor.user!.avatar.isNotEmpty
                              ? Image.memory(
                                  Uri.parse(widget.doctor.user!.avatar).data!.contentAsBytes(),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.person,
                                        size: 24,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doctor.degree,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.doctor.user?.username ?? 'Unknown Doctor',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Chuyên khoa: ${widget.doctor.specialization?.name ?? 'General'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // 4.2. Phần "Đặt lịch khám này cho:"
                  // ============================
                  const Text(
                    'Đặt lịch khám này cho:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Họ và tên',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              _patientProfile['name']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Giới tính',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              _patientProfile['gender']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Ngày sinh',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              _patientProfile['birthdate']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Điện thoại',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              _patientProfile['phone']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // TODO: Xử lý Xem chi tiết hồ sơ
                              },
                              child: const Text(
                                'Xem chi tiết',
                                style: TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // TODO: Xử lý Sửa hồ sơ
                              },
                              child: const Text(
                                'Sửa hồ sơ',
                                style: TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      // TODO: Xử lý "Chọn hoặc tạo hồ sơ khác"
                    },
                    child: Text(
                      'Chọn hoặc tạo hồ sơ khác →',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // 4.3. Phần "Chọn ngày khám"
                  // ============================
                  const Text(
                    'Chọn ngày khám',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Selector tháng (chỉ chọn tháng-năm)
                  GestureDetector(
                    onTap: _pickMonthYear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            monthLabel,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Danh sách ngày còn lại trong tháng (scroll ngang)
                  SizedBox(
                    height: 120,
                    child: _dates.isEmpty
                        ? Center(
                            child: Text(
                              'Không có ngày khả dụng trong tháng này.',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _dates.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final dayInfo = _dates[index];
                              final bool isSelected = index == _selectedDateIndex;
                              final int slotsAvailable = dayInfo['slots'] as int;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDateIndex = index;
                                    _selectedTimeIndex = -1; // reset giờ khi đổi ngày
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      dayInfo['weekday'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            isSelected ? Colors.blue : Colors.grey.shade600,
                                        fontWeight:
                                            isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Hình tròn chứa số ngày
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${dayInfo['day']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Số slot khả dụng hiển thị dưới dạng pill màu xanh lá (hoặc xám nếu = 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: slotsAvailable > 0
                                            ? Colors.green.shade400
                                            : Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$slotsAvailable slot',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // 4.4. Phần "Chọn giờ khám"
                  // ============================
                  const Text(
                    'Chọn giờ khám',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // TabBar để chọn Buổi sáng / Buổi chiều
                  DefaultTabController(
                    length: 2,
                    initialIndex: _selectedSession == 'morning' ? 0 : 1,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TabBar(
                              onTap: (idx) {
                                setState(() {
                                  _selectedSession = (idx == 0) ? 'morning' : 'afternoon';
                                  _selectedTimeIndex = -1;
                                });
                              },
                              indicator: BoxDecoration(
                                color: Colors.blue.shade100, // Nền tab đang chọn
                                borderRadius: BorderRadius.circular(12), // Full bo tròn
                              ),
                              indicatorSize: TabBarIndicatorSize.tab, // <-- Cái này rất quan trọng để full nền!
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.grey,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                              tabs: const [
                                Tab(text: 'Buổi sáng'),
                                Tab(text: 'Buổi chiều'),
                              ],
                            ),
                          ),

                        ),
                        const SizedBox(height: 12),

                        // Khung giờ trong TabBarView
                        SizedBox(
                          height: 220,
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // Buổi sáng
                              _buildTimeSlots(isMorning: true),

                              // Buổi chiều
                              _buildTimeSlots(isMorning: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // 4.5. Phần "Thông tin bổ sung (không bắt buộc)"
                  // ============================
                  const Text(
                    'Thông tin bổ sung (không bắt buộc)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nếu chưa có thông tin thì hiển thị nút "Tôi muốn gửi thêm thông tin"
                  if (_extraInfoText.isEmpty && _extraImages.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _showExtraInfoModal,
                        child: Text(
                          'Tôi muốn gửi thêm thông tin →',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    )
                  else
                    // Nếu đã có dữ liệu, hiển thị lại thông tin:
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hiển thị lý do thăm khám
                          if (_extraInfoText.isNotEmpty) ...[
                            const Text(
                              'Lý do thăm khám:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _extraInfoText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Hiển thị ảnh đã upload
                          if (_extraImages.isNotEmpty) ...[
                            const Text(
                              'Hình ảnh toa thuốc:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _extraImages.map((file) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    file,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Nút "Sửa thông tin"
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showExtraInfoModal,
                              child: const Text(
                                'Sửa thông tin',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ============================
          // 4.6. Nút "Tiếp tục" ở bottom - CẬP NHẬT
          // ============================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  if (_selectedTimeIndex < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng chọn khung giờ khám'),
                      ),
                    );
                    return;
                  }

                  // Lấy thông tin ngày đã chọn
                  final Map<String, dynamic> dayInfo = _dates[_selectedDateIndex];
                  final DateTime dateObj = dayInfo['dateObj'] as DateTime;

                  // Xác định Slot (sáng/chiều) và format kèm chuỗi "(Buổi sáng)" hoặc "(Buổi chiều)"
                  final bool isMorning = (_selectedSession == 'morning');
                  final String chosenSlot = isMorning
                      ? '${_morningSlots[_selectedTimeIndex]} (Buổi sáng)'
                      : '${_afternoonSlots[_selectedTimeIndex]} (Buổi chiều)';

                  // Tạo giả lập bookingCode (ví dụ)
                  final DateTime now = DateTime.now();
                  final String bookingCode =
                      'YMA${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
                      '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

                  // Số thứ tự (ví dụ tạm set = 2 hoặc lấy từ API)
                  final int sttNumber = 2;

                  // Địa chỉ phòng khám - CẬP NHẬT để dùng description hoặc fallback
                  final String clinicAddress = widget.doctor.description.isNotEmpty 
                      ? widget.doctor.description 
                      : 'Phòng khám không xác định';

                  // Thời điểm đặt lịch:
                  final DateTime bookedAt = now;

                  // Điều hướng sang ConfirmationPage
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ConfirmationPage(
                        doctor: widget.doctor,
                        selectedDate: dateObj,
                        selectedSlot: chosenSlot,
                        patientProfile: _patientProfile,
                        healthInsuranceCode: '--',
                        citizenId: 'Chưa cập nhật',
                        address: '--',
                        bookingCode: bookingCode,
                        sttNumber: sttNumber,
                        clinicAddress: clinicAddress,
                        bookedAt: bookedAt,
                        extraInfoText: _extraInfoText,
                        extraImages: _extraImages,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng widget hiển thị khung giờ (sáng hoặc chiều), với trạng thái disabled nếu past/booked.
  Widget _buildTimeSlots({required bool isMorning}) {
    // Lấy đối tượng ngày đã chọn
    final Map<String, dynamic> dayInfo = _dates[_selectedDateIndex];
    final DateTime dateObj = dayInfo['dateObj'] as DateTime;
    final String dateKey = _formatDateKey(dateObj);
    final List<String> bookedForDay = _bookedSlots[dateKey] ?? [];

    final List<String> slotList = isMorning ? _morningSlots : _afternoonSlots;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        slotList.length,
        (i) {
          final String slot = slotList[i];
          final DateTime slotStart = _parseSlotStartTime(dateObj, slot);
          final DateTime slotEnd = _parseSlotEndTime(dateObj, slot);
          final DateTime now = DateTime.now();

          // Xác định xem slot này đã qua ("past") hay đã bị booked
          bool isPast = false;
          if (dateObj.year == now.year &&
              dateObj.month == now.month &&
              dateObj.day == now.day) {
            if (slotEnd.isBefore(now) || slotEnd.isAtSameMomentAs(now)) {
              isPast = true;
            }
          }
          bool isBooked = bookedForDay.contains(slot);

          // Nếu quá hạn hoặc đã booked, không cho chọn
          final bool isDisabled = isPast || isBooked;

          // Kiểm tra xem slot đang được chọn
          final bool isSlotSelected =
              (_selectedSession == (isMorning ? 'morning' : 'afternoon') &&
                  _selectedTimeIndex == i);

          // Nếu slot đã disabled, override selected state
          final Color borderColor = isDisabled
              ? Colors.grey.shade400
              : (isSlotSelected ? Colors.blue : Colors.grey.shade300);
          final Color textColor = isDisabled
              ? Colors.grey.shade400
              : (isSlotSelected ? Colors.blue : Colors.black87);
          final Color bgColor = isDisabled ? Colors.grey.shade200 : Colors.white;

          return GestureDetector(
            onTap: () {
              if (isDisabled) return;
              setState(() {
                _selectedSession = isMorning ? 'morning' : 'afternoon';
                _selectedTimeIndex = i;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
                  width: isSlotSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                slot,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}