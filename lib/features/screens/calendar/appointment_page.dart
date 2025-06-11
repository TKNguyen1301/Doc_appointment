// appointment_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutterproject/features/screens/calendar/appointment_data.dart';
import 'appointment_detail_page.dart';  // Import detail page

/// Trang hiển thị lịch khám với bộ lọc trạng thái, ngày và payment status, và chuyển sang chi tiết
class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final List<Appointment> _appointments = appointments;
  late List<Appointment> _filteredAppointments;

  // Các trạng thái để lọc
  final List<String> _statuses = [
    'Tất cả',
    'Chờ khám',
    'Hoàn thành',
    'Đã hủy',
  ];
  String _selectedStatus = 'Tất cả';

  // Các payment status để lọc
  final List<String> _paymentStatuses = [
    'Tất cả',
    'PAID',
    'PENDING',
  ];
  String _selectedPaymentStatus = 'Tất cả';

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _filteredAppointments = List.from(_appointments);
  }

  /// Áp dụng đồng thời bộ lọc trạng thái, ngày và payment status
  void _applyFilters() {
    setState(() {
      _filteredAppointments = _appointments.where((a) {
        final statusMatch = _selectedStatus == 'Tất cả' || a.status == _selectedStatus;
        final dateMatch = _selectedDate == null || a.date == _formatDate(_selectedDate!);
        final paymentMatch = _selectedPaymentStatus == 'Tất cả' ||
            (a.paymentStatus != null && a.paymentStatus == _selectedPaymentStatus);
        return statusMatch && dateMatch && paymentMatch;
      }).toList();
    });
  }

  /// Định dạng DateTime thành dd/MM/yyyy
  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  /// Hiển thị bottom sheet để chọn trạng thái
  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String temp = _selectedStatus;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lọc theo trạng thái',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._statuses.map((s) {
                    final sel = s == temp;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: sel ? Colors.blue.shade50 : Colors.white,
                        border: Border.all(
                            color: sel ? Colors.blue : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RadioListTile<String>(
                        title: Text(s),
                        value: s,
                        groupValue: temp,
                        activeColor: Colors.blue,
                        onChanged: (v) => setModalState(() => temp = v!),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        _selectedStatus = temp;
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Hiển thị bottom sheet để chọn payment status
  void _showPaymentFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String temp = _selectedPaymentStatus;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lọc theo Payment Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._paymentStatuses.map((s) {
                    final sel = s == temp;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: sel ? Colors.green.shade50 : Colors.white,
                        border: Border.all(
                            color: sel ? Colors.green : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RadioListTile<String>(
                        title: Text(s),
                        value: s,
                        groupValue: temp,
                        activeColor: Colors.green,
                        onChanged: (v) => setModalState(() => temp = v!),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        _selectedPaymentStatus = temp;
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Hiển thị DatePicker để chọn ngày
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch khám'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showStatusFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Pill lọc trạng thái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: _showStatusFilter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text('Trạng thái: $_selectedStatus', style: const TextStyle(color: Colors.black87)),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          // Pill chọn ngày
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null ? 'Ngày: ${_formatDate(_selectedDate!)}' : 'Chọn ngày',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = null);
                          _applyFilters();
                        },
                        child: const Icon(Icons.clear, size: 16, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Pill lọc payment status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GestureDetector(
              onTap: _showPaymentFilter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payment, size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text('Payment: $_selectedPaymentStatus', style: const TextStyle(color: Colors.black87)),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          // Danh sách các lịch hẹn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _filteredAppointments.length,
              itemBuilder: (context, index) {
                final appt = _filteredAppointments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentDetailPage(appointment: appt),
                      ),
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 8, color: _badgeColor(appt.status)),
                                      const SizedBox(width: 4),
                                      Text(
                                        appt.status,
                                        style: TextStyle(color: _badgeColor(appt.status), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: _badgeColor(appt.status).withOpacity(0.1),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                ),
                                const Spacer(),
                                Text('STT ${appt.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    appt.doctorName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                CircleAvatar(radius: 20, backgroundImage: AssetImage(appt.doctorImageUrl)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Expanded(child: Text('Giờ khám', style: TextStyle(color: Colors.grey))),
                                Text('${appt.time} • ${appt.date}', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(child: Text('Bệnh nhân', style: TextStyle(color: Colors.grey))),
                                Text(appt.patientName, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            if (appt.status == 'Hoàn thành') ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Expanded(child: Text('Payment Status', style: TextStyle(color: Colors.grey))),
                                  Text(appt.paymentStatus ?? '-', style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Màu hiển thị badge theo trạng thái
  Color _badgeColor(String status) {
    switch (status) {
      case 'Đã hủy':
        return Colors.orange;
      case 'Hoàn thành':
        return Colors.green;
      case 'Chờ khám':
      case 'Chờ xác nhận':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
