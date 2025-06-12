// appointment_schedule_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterproject/features/booking/model/appointment.dart';
import 'appointment_detail_page.dart';
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

  void _showStatusFilter() {
    // Áp dụng implementation cũ
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
                  ..._getDisplayStatuses().map((s) {
                    final sel = s == temp;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : Colors.white,
                        border: Border.all(color: sel ? AppColors.primary : Colors.grey.shade300),
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _calendarController.selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) _calendarController.setDateFilter(picked);
  }

  List<String> _getDisplayStatuses() => [
        'Tất cả',
        'Chờ khám',
        'Hoàn thành',
        'Đã hủy',
        'Không đến',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch khám'),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showStatusFilter),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAppointments),
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: _calendarController,
        child: Consumer<CalendarController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error != null) {
              return _buildError(controller.error!);
            }
            return Column(
              children: [
                _buildFilterPills(controller),
                Expanded(child: _buildAppointmentList(controller)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(String error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAppointments, child: const Text('Thử lại')),
          ],
        ),
      );

  Widget _buildFilterPills(CalendarController controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _FilterPill(
                icon: Icons.filter_alt_outlined,
                label: controller.selectedStatus,
                onTap: _showStatusFilter,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterPill(
                icon: Icons.calendar_today,
                label: controller.selectedDate != null
                    ? controller.formatDate(controller.selectedDate!)
                    : 'Chọn ngày',
                onTap: _pickDate,
                onClear: controller.selectedDate != null ? controller.clearDateFilter : null,
              ),
            ),
          ],
        ),
      );

  Widget _buildAppointmentList(CalendarController controller) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.filteredAppointments.length,
        itemBuilder: (context, i) {
          final appt = controller.filteredAppointments[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AppointmentDetailPage(appointment: appt)),
              ),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Chip(
                        label: Text(
                          _getDisplayStatus(appt.status),
                          style: TextStyle(color: _badgeColor(appt.status), fontSize: 12),
                        ),
                        backgroundColor: _badgeColor(appt.status).withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Spacer(),
                      Text(
                        controller.getTimeRange(appt.appointmentDatetime),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]),
                    const Divider(height: 24),
                    Row(children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: appt.doctor?.user?.avatar?.isNotEmpty == true
                            ? NetworkImage(appt.doctor!.user!.avatar) as ImageProvider
                            : null,
                        child: appt.doctor?.user?.avatar?.isEmpty == true
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appt.doctor?.user?.username ?? 'Unknown Doctor',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appt.doctor?.specialization?.name ?? 'General',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Ngày khám',
                      value: controller.formatDate(appt.appointmentDatetime),
                    ),
                    if (appt.reason?.isNotEmpty == true)
                      _DetailRow(label: 'Lý do khám', value: appt.reason!),
                  ]),
                ),
              ),
            ),
          );
        },
      );

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

class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black87))),
          if (onClear != null) ...[
            const SizedBox(width: 4),
            GestureDetector(onTap: onClear, child: const Icon(Icons.clear, size: 16, color: Colors.black54)),
          ],
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
        Text(value, style: const TextStyle(fontSize: 14)),
      ]),
    );
  }
}
