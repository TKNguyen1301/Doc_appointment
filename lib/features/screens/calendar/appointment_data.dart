
class Appointment {
  final int id;
  final String status;
  final String doctorName;
  final String doctorImageUrl;
  final String time;
  final String date;
  final String patientName;

  Appointment({
    required this.id,
    required this.status,
    required this.doctorName,
    required this.doctorImageUrl,
    required this.time,
    required this.date,
    required this.patientName,
  });
}

final List<Appointment> _appointments = [
    Appointment(
      id: 1,
      status: 'Chờ xác nhận',
      doctorName: 'BS. CK1 Nguyễn Thị Mai',
      doctorImageUrl: 'assets/assets_frontend/doc1.png',
      time: '08:00-08:10',
      date: '07/06/2025',
      patientName: 'Trần Khánh Nguyên',
    ),
    Appointment(
      id: 2,
      status: 'Đã hủy',
      doctorName: 'assets/assets_frontend/doc2.png',
      doctorImageUrl: '',
      time: '17:40-17:50',
      date: '06/06/2025',
      patientName: 'Trần Khánh Nguyên',
    ),
    Appointment(
      id: 3,
      status: 'Hoàn thành',
      doctorName: 'assets/assets_frontend/doc3.png',
      doctorImageUrl: '',
      time: '09:20-09:30',
      date: '05/06/2025',
      patientName: 'Trần Khánh Nguyên',
    ),
    Appointment(
      id: 4,
      status: 'Chờ khám',
      doctorName: 'BS. CK1 Phạm Thị Hồng',
      doctorImageUrl: 'assets/assets_frontend/doc4.png',
      time: '10:15-10:25',
      date: '07/06/2025',
      patientName: 'Trần Khánh Nguyên',
    ),
  ];