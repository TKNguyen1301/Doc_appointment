import 'package:flutter/material.dart';
import 'package:flutterproject/features/screens/booking/booking_page.dart';
import 'package:flutterproject/features/screens/doctor_data.dart';

/// =======================
/// 1. Model Doctor
/// =======================

/// =======================
/// 2. DoctorSearchPage (Danh sách bác sĩ)
/// =======================
class DoctorSearchPage extends StatefulWidget {
  final String? specialty;
  const DoctorSearchPage({Key? key, this.specialty}) : super(key: key);

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  // Controller cho ô search
  final TextEditingController _searchController = TextEditingController();
  final List<Doctor> _allDoctors = doctorList;
  // 2.2. Danh sách hiện tại (filter theo search + chuyên khoa). Ban đầu chính là toàn bộ
  List<Doctor> _filteredDoctors = [];

  // 2.3. Danh sách các chuyên khoa có trong _allDoctors (cộng thêm "Tất cả")
  late final List<String> _specialties;

  late String _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _selectedSpecialty = (widget.specialty == null || widget.specialty!.isEmpty)
      ? 'Tất cả'
      : widget.specialty!;

    // Khởi tạo danh sách các chuyên khoa (unique) từ _allDoctors, chèn "Tất cả" ở đầu
    final Set<String> specialtySet =
        _allDoctors.map((doc) => doc.specialty).toSet();
    _specialties = ['Tất cả', ...specialtySet.toList()];

    // Gán toàn bộ doctors vào filtered lần đầu
    _filteredDoctors = List<Doctor>.from(_allDoctors);
    _applyFilters();
    // Lắng nghe mỗi khi text thay đổi để filter lại (_applyFilters sẽ xét cả search + chuyên khoa)
    _searchController.addListener(() {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 2.5. Hàm lọc _allDoctors dựa trên cả ô tìm kiếm (search) và chuyên khoa (_selectedSpecialty)
  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        // 1) Kiểm tra chuyên khoa: nếu _selectedSpecialty != "Tất cả", buộc phải khớp chính xác
        final matchesSpecialty = (_selectedSpecialty == 'Tất cả') ||
            (doctor.specialty == _selectedSpecialty);

        // 2) Kiểm tra tìm kiếm: nếu query không rỗng, so sánh với tên và chuyên khoa
        final matchesSearch = query.isEmpty ||
            doctor.name.toLowerCase().contains(query) ||
            doctor.specialty.toLowerCase().contains(query);

        // Chỉ giữ những doctor thỏa mãn cả 2 điều kiện
        return matchesSpecialty && matchesSearch;
      }).toList();
    });
  }

  /// 2.6. Hiển thị Bottom Sheet để người dùng chọn chuyên khoa
  void _showSpecialtyFilterSheet() {
    String tempSelected = _selectedSpecialty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              child: Column(
                children: [
                  // Header (tiêu đề + nút đóng)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text(
                          'Lọc theo chuyên khoa',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Body scrollable (danh sách chuyên khoa)
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _specialties.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        String spec = _specialties[index];
                        bool isSelected = spec == tempSelected;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setStateBottom(() => tempSelected = spec);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  spec,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Radio<String>(
                                  value: spec,
                                  groupValue: tempSelected,
                                  activeColor: Colors.blue,
                                  onChanged: (value) {
                                    setStateBottom(() => tempSelected = value!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Footer (nút Áp dụng)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedSpecialty = tempSelected;
                            _applyFilters();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Áp dụng',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 2A. AppBar chứa nút back và SearchBar
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: 'Tên bác sĩ, triệu chứng, chuyên khoa',
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                      child: const Icon(Icons.clear, color: Colors.grey),
                    ),
            ),
          ),
        ),
      ),

      // 2B + 2C: Nội dung chính (Chuyên khoa + ListView bác sĩ)
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Hàng "Chuyên khoa: …" (bọc InkWell để bấm mở filter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
              onTap: _showSpecialtyFilterSheet,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category, color: Colors.grey, size: 20),
                    const SizedBox(width: 6),
                    // Hiển thị tên chuyên khoa đang chọn
                    Text(
                      'Chuyên khoa: $_selectedSpecialty',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ListView hiển thị danh sách bác sĩ đã filter
          Expanded(
            child: _filteredDoctors.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy bác sĩ phù hợp.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredDoctors.length,
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 8,
                        color: Colors.grey.shade200,
                      );
                    },
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      return _DoctorListItem(doctor: doctor);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 3. Widget _DoctorListItem: hiển thị từng item bác sĩ
///     Khi bấm "Đặt lịch ngay" thì điều hướng sang BookingPage
/// =======================
class _DoctorListItem extends StatelessWidget {
  final Doctor doctor;
  const _DoctorListItem({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----- Ảnh bác sĩ (vòng tròn) -----
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              doctor.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // ----- Thông tin chính: tiêu đề + tên, kinh nghiệm, chuyên khoa, địa chỉ -----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dòng "BS. CK1" + Tên bác sĩ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      doctor.title,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doctor.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // 2. Kinh nghiệm
                Text(
                  doctor.experience,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                // 3. Thẻ chuyên khoa
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 4. Địa chỉ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ----- Nút “Đặt lịch ngay” -----
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              textStyle: const TextStyle(fontSize: 14),
            ),
            onPressed: () {
              // Điều hướng sang BookingPage, truyền vào đối tượng doctor
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingPage(doctor: doctor),
                ),
              );
            },
            child: const Text('Đặt lịch ngay'),
          ),
        ],
      ),
    );
  }
}

