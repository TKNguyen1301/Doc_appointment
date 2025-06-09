// appointment_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutterproject/features/screens/calendar/appointment_data.dart';
class AppointmentPage extends StatefulWidget{
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}
class _AppointmentPageState extends State<AppointmentPage> {
  final List<Appointment> _appointments = ["jalsd",];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch khám'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo mã phiếu khám, tên bệnh',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.indigo.shade700,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appt = _appointments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: _badgeColor(appt.status),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      appt.status,
                                      style: TextStyle(
                                        color: _badgeColor(appt.status),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: _badgeColor(appt.status).withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              ),
                              const Spacer(),
                              Text(
                                'STT ${appt.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  appt.doctorName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(appt.doctorImageUrl),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Giờ khám',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Text(
                                '${appt.time} - ${appt.date}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Bệnh nhân',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Text(
                                appt.patientName,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
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

  Color _badgeColor(String status) {
    switch (status) {
      case 'Đã hủy':
        return Colors.orange;
      case 'Hoàn thành':
        return Colors.green;
      case 'Chờ xác nhận':
      case 'Chờ khám':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
