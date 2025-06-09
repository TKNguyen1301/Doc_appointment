class Doctor {
  final String title;      // Ví dụ: "BS. CK1" hoặc "Bác sĩ"
  final String name;       // Tên bác sĩ
  final String experience; // Ví dụ: "14 năm kinh nghiệm"
  final String specialty;  // Ví dụ: "Sản phụ khoa"
  final String address;    // Ví dụ: "333 Huỳnh Tấn Phát, …"
  final String image;      // Đường dẫn file PNG, ví dụ "assets/assets_frontend/doc1.png"
  final bool isAvailable;

  Doctor({
    required this.title,
    required this.name,
    required this.experience,
    required this.specialty,
    required this.address,
    required this.image,
    this.isAvailable = true,
  });
}

final List<Doctor> doctorList = [
  Doctor(
    title: 'BS. CK1',
    name: 'Vũ Thị Hạnh Thư',
    experience: '14 năm kinh nghiệm',
    specialty: 'Sản phụ khoa',
    address: '333 Huỳnh Tấn Phát, Phường Tân Thuận Đông, Quận 7, Hồ Chí Minh',
    image: 'assets/assets_frontend/doc1.png',
    isAvailable: true,
  ),
  Doctor(
    title: 'BS. CK1',
    name: 'Hồ Thị Mỹ Ngọc',
    experience: '7 năm kinh nghiệm',
    specialty: 'Nhi khoa',
    address: '63/9A Gò Dầu, Phường Tân Quý, Quận Tân Phú, Hồ Chí Minh',
    image: 'assets/assets_frontend/doc2.png',
    isAvailable: true,
  ),
  Doctor(
    title: 'Bác sĩ',
    name: 'Mai Văn Sỹ',
    experience: '15 năm kinh nghiệm',
    specialty: 'Nhãn khoa',
    address: '65 Võ Oanh, Phường 25, Quận Bình Thạnh, Hồ Chí Minh',
    image: 'assets/assets_frontend/doc3.png',
    isAvailable: true,
  ),
];