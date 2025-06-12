// appointment_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterproject/features/booking/model/appointment.dart';
import 'appointment_detail_page.dart'; // Import detail page
import '../view_model/calendar_controller.dart';
import 'package:flutterproject/utils/constants/colors.dart';

/// Trang hiển thị lịch khám với bộ lọc trạng thái, ngày và payment status, và chuyển sang chi tiết
class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    await _calendarController.fetchAppointments();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
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
        String temp = _calendarController.selectedStatus;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  ..._getDisplayStatuses().map((s) {
                    final sel = s == temp;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : Colors.white,
                        border: Border.all(
                            color:
                                sel ? AppColors.primary : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RadioListTile<String>(
                        title: Text(s),
                        value: s,
                        groupValue: temp,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setModalState(() => temp = v!),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        _calendarController.setStatusFilter(temp);
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
        String temp = _calendarController.selectedPaymentStatus;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  ..._calendarController.paymentStatuses.map((s) {
                    final sel = s == temp;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
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
                        _calendarController.setPaymentStatusFilter(temp);
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
      initialDate: _calendarController.selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      _calendarController.setDateFilter(picked);
    }
  }

  /// Get display statuses for UI
  List<String> _getDisplayStatuses() {
    return [
      'Tất cả',
      'Chờ khám',
      'Hoàn thành',
      'Đã hủy',
      'Không đến',
    ];
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: _calendarController,
        child: Consumer<CalendarController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: ${controller.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAppointments,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Pill lọc trạng thái
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: _showStatusFilter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_alt_outlined,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text('Trạng thái: ${controller.selectedStatus}',
                              style: const TextStyle(color: Colors.black87)),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pill chọn ngày
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            controller.selectedDate != null
                                ? 'Ngày: ${controller.formatDate(controller.selectedDate!)}'
                                : 'Chọn ngày',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: Colors.black54),
                          if (controller.selectedDate != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => controller.clearDateFilter(),
                              child: const Icon(Icons.clear,
                                  size: 16, color: Colors.black54),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Pill lọc payment status
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: GestureDetector(
                    onTap: _showPaymentFilter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.payment,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text('Payment: ${controller.selectedPaymentStatus}',
                              style: const TextStyle(color: Colors.black87)),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ),
                // Danh sách các lịch hẹn
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: controller.filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = controller.filteredAppointments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AppointmentDetailPage(appointment: appt),
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
                                            Icon(Icons.circle,
                                                size: 8,
                                                color:
                                                    _badgeColor(appt.status)),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getDisplayStatus(appt.status),
                                              style: TextStyle(
                                                  color:
                                                      _badgeColor(appt.status),
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        backgroundColor:
                                            _badgeColor(appt.status)
                                                .withOpacity(0.1),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${controller.getTimeRange(appt.appointmentDatetime)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appt.doctor?.user?.username ??
                                                  'Unknown Doctor',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              appt.doctor?.specialization
                                                      ?.name ??
                                                  'General',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (appt.doctor?.user?.avatar != null &&
                                          appt.doctor!.user!.avatar.isNotEmpty)
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                              appt.doctor!.user!.avatar),
                                        )
                                      else
                                        const CircleAvatar(
                                          radius: 20,
                                          child: Icon(Icons.person),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Expanded(
                                          child: Text('Ngày khám',
                                              style: TextStyle(
                                                  color: Colors.grey))),
                                      Text(
                                          controller.formatDate(
                                              appt.appointmentDatetime),
                                          style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  if (appt.reason != null &&
                                      appt.reason!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Expanded(
                                            child: Text('Lý do khám',
                                                style: TextStyle(
                                                    color: Colors.grey))),
                                        Flexible(
                                          child: Text(appt.reason!,
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                        ),
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
            );
          },
        ),
      ),
    );
  }

  /// Map API status to display status
  String _getDisplayStatus(String apiStatus) {
    switch (apiStatus) {
      case 'scheduled':
        return 'Chờ khám';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'no_show':
        return 'Không đến';
      default:
        return apiStatus;
    }
  }

  /// Màu hiển thị badge theo trạng thái
  Color _badgeColor(String status) {
    switch (status) {
      case 'cancelled':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'scheduled':
        return AppColors.primary;
      case 'no_show':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
