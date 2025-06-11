// appointment_data.dart

/// Model Appointment với các trường mở rộng cho chi tiết hoàn thành
class Appointment {
  final int id;
  final String code;
  final String status;
  final String doctorName;
  final String doctorImageUrl;
  final String time;
  final String date;
  final String patientName;

  // Chỉ có giá trị khi status == 'Hoàn thành'
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final String? prescriptionDetails;
  final String? amount;
  final String? paymentStatus;  // Thêm trường để lưu trạng thái thanh toán
  final String? paymentMethod;

  // Feedback
  final double? rating;
  final String? comment;

  Appointment({
    required this.id,
    required this.code,
    required this.status,
    required this.doctorName,
    required this.doctorImageUrl,
    required this.time,
    required this.date,
    required this.patientName,
    this.diagnosis,
    this.treatment,
    this.notes,
    this.prescriptionDetails,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.rating,
    this.comment,
  });
}

/// Dữ liệu mẫu các lịch khám
final List<Appointment> appointments = [
  // Lịch chờ khám
  Appointment(
    id: 1,
    code: 'YMA2506110992',
    status: 'Chờ khám',
    doctorName: 'BS. CK1 Hồ Thị Mỹ Ngọc',
    doctorImageUrl: 'assets/assets_frontend/doc1.png',
    time: '17:05-17:10',
    date: '11/06/2025',
    patientName: 'Trần Khánh Nguyên',
  ),

  // Lịch huỷ
  Appointment(
    id: 2,
    code: 'YMA2506110993',
    status: 'Đã hủy',
    doctorName: 'BS. CK1 Vũ Thị Hạnh',
    doctorImageUrl: 'assets/assets_frontend/doc2.png',
    time: '14:20-14:30',
    date: '10/06/2025',
    patientName: 'Trần Khánh Nguyên',
  ),

  // Lịch hoàn thành có chi tiết
  Appointment(
    id: 3,
    code: 'YMA2506110994',
    status: 'Hoàn thành',
    doctorName: 'BS. CK1 Phạm Thị Lan',
    doctorImageUrl: 'assets/assets_frontend/doc3.png',
    time: '09:20-09:30',
    date: '05/06/2025',
    patientName: 'Trần Khánh Nguyên',
    diagnosis: 'Cao huyết áp',
    treatment: 'Dùng thuốc điều hòa huyết áp hàng ngày',
    notes: 'Cần tái khám sau 1 tháng',
    prescriptionDetails: 'Losartan 50mg - 1 viên/ngày, Aspirin 81mg - 1 viên/ngày',
    amount: '250.000 VND',
    paymentStatus: 'PAID',
    paymentMethod: 'Cash',
    rating: 4.0,
    comment: 'Dịch vụ ổn, bác sĩ cần nhiệt tình nhiều hơn.',
  ),

  // Thêm các mục khác nếu cần
];
