// appointment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutterproject/features/screens/calendar/appointment_data.dart';
import 'package:flutterproject/features/screens/User_info/user_data.dart';

/// Chi tiết phiếu khám (Phiếu khám)
class AppointmentDetailPage extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailPage({Key? key, required this.appointment}) : super(key: key);

  @override
  _AppointmentDetailPageState createState() => _AppointmentDetailPageState();
}

/// Chi tiết phiếu khám (Phiếu khám)
class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late int _rating;
  late String _comment;

  @override
  void initState() {
    super.initState();
    _rating = (widget.appointment.rating ?? 0).toInt();
    _comment = widget.appointment.comment ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Phiếu khám'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: chia sẻ phiếu khám
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER: Bs. name, QR, STT, Status
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            appointment.doctorName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('STT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            Text(
                              appointment.id.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _statusColor(appointment.status),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                            decoration: BoxDecoration(
                              color: _statusColor(appointment.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              appointment.status,
                              style: TextStyle(
                                color: _statusColor(appointment.status),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Thông tin cơ bản
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Mã phiếu', appointment.code),
                        const SizedBox(height: 12),
                        _infoRow('Ngày khám', appointment.date),
                        const SizedBox(height: 12),
                        _infoRow('Giờ khám', appointment.time),
                      ],
                    ),
                  ),

                  // Thông tin bệnh nhân
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin bệnh nhân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        _infoRow('Mã bệnh nhân', currentUser.patientId),
                        const SizedBox(height: 8),
                        _infoRow('Họ và tên', currentUser.name),
                        const SizedBox(height: 8),
                        _infoRow('Điện thoại', currentUser.phone),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: xem chi tiết hồ sơ
                            },
                            child: const Text('Xem chi tiết'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Thông tin đăng ký khám
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(appointment.doctorImageUrl),
                          ),
                          title: Text(
                            appointment.doctorName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: TextButton.icon(
                            onPressed: () {
                              // TODO: nhắn tin với bác sĩ
                            },
                            icon: const Icon(Icons.message_outlined),
                            label: const Text('Chat'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chi tiết khi hoàn thành
                  if (appointment.status == 'Hoàn thành') ...[
                    _sectionHeader(context, Icons.description, 'Medical Record'),
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Diagnosis', appointment.diagnosis),
                          const SizedBox(height: 8),
                          _infoRow('Treatment', appointment.treatment),
                          const SizedBox(height: 8),
                          _infoRow('Notes', appointment.notes),
                        ],
                      ),
                    ),

                    _sectionHeader(context, Icons.medical_services, 'Prescription'),
                    _sectionCard(
                      child: _infoRow('Medicine Details', appointment.prescriptionDetails),
                    ),

                    _sectionHeader(context, Icons.payment, 'Payment'),
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Amount', appointment.amount),
                          const SizedBox(height: 8),
                          _infoRow('Status', appointment.paymentStatus),
                          const SizedBox(height: 8),
                          _infoRow('Method', appointment.paymentMethod),
                        ],
                      ),
                    ),

                    _sectionHeader(context, Icons.feedback, 'Feedback'),
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              Text('$_rating / 5', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          if (_comment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              _comment,
                              style: const TextStyle(color: Colors.black87),
                              softWrap: true,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: _showFeedbackDialog,
                              child: const Text('Update Feedback'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appointment.status == 'Chờ khám'
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: Colors.red.shade400),
                      ),
                      onPressed: () {
                        // TODO: hủy lịch khám
                      },
                      child: const Text('Hủy lịch khám', style: TextStyle(color: Colors.red)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: () {
                        // TODO: đặt lịch khác
                      },
                      child: Text(
                        appointment.status == 'Hoàn thành' ? 'Đặt lịch khám khác' : appointment.status,
                      ),
                    ),
              const SizedBox(height: 8),
              Column(
                children: const [
                  Text('Tổng đài hỗ trợ chăm sóc khách hàng', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('1900-2805', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tiêu đề section với icon
  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Widget Card section
  Widget _sectionCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  /// Row đơn giản label-value, với wrap text tránh overflow
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w500),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
  void _showFeedbackDialog() {
    final ratingController = TextEditingController(text: _rating.toString());
    final commentController = TextEditingController(text: _comment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Feedback'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: ratingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rating (1-5)'),
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRating = int.tryParse(ratingController.text) ?? _rating;
              setState(() {
                _rating = newRating.clamp(1, 5);
                _comment = commentController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  /// Màu badge theo trạng thái
  Color _statusColor(String status) {
    switch (status) {
      case 'Hoàn thành':
        return Colors.green;
      case 'Chờ khám':
        return Colors.blue;
      case 'Đã hủy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
