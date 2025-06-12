import 'package:flutter/material.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/features/home/view_model/doctor_controller.dart';
import 'package:flutterproject/features/booking/booking_page.dart';

class DoctorSearchPage extends StatefulWidget {
  /// Nếu muốn filter ngay từ đầu theo chuyên khoa,
  /// truyền tên chuyên khoa vào `specialty`
  final String? specialty;

  const DoctorSearchPage({Key? key, this.specialty}) : super(key: key);

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final DoctorController _controller = DoctorController();

  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  List<Map<String, dynamic>> _specialties = [];

  String _selectedSpecialtyName = 'Tất cả';
  int? _selectedSpecialtyId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.specialty != null && widget.specialty!.isNotEmpty) {
      _selectedSpecialtyName = widget.specialty!;
    }

    _searchController.addListener(_applyFilters);
    _fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _controller.fetchAllDoctors(
        specializationId: _selectedSpecialtyId?.toString(),
      );

      setState(() {
        _allDoctors = doctors;
        // Lấy danh sách chuyên khoa duy nhất
        final specs = _allDoctors
            .where((d) => d.specialization != null)
            .map((d) => {
                  'id': d.specialization!.specializationId,
                  'name': d.specialization!.name,
                })
            .toSet()
            .toList();
        _specialties = [
          {'id': null, 'name': 'Tất cả'},
          ...specs,
        ];
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách bác sĩ:\n\$e')),
      );
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        final bySearch = query.isEmpty ||
            (doc.user?.username.toLowerCase().contains(query) ?? false) ||
            (doc.specialization?.name.toLowerCase().contains(query) ?? false);
        return bySearch;
      }).toList();
    });
  }

  void _showSpecialtyFilterSheet() {
    String tempName = _selectedSpecialtyName;
    int? tempId = _selectedSpecialtyId;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateBottom) => FractionallySizedBox(
          heightFactor: 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    const Text(
                      'Lọc chuyên khoa',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _specialties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final spec = _specialties[i];
                    final selected = spec['id'] == tempId;
                    return InkWell(
                      onTap: () => setStateBottom(() {
                        tempName = spec['name'];
                        tempId = spec['id'];
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? Colors.blue : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(spec['name'])),
                            Radio<int?>(
                              value: spec['id'],
                              groupValue: tempId,
                              onChanged: (v) => setStateBottom(() {
                                tempName = spec['name'];
                                tempId = v;
                              }),
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedSpecialtyName = tempName;
                        _selectedSpecialtyId = tempId;
                      });
                      _fetchDoctors();
                    },
                    child: const Text('Áp dụng'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: const BackButton(color: Colors.white),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: 'Tên bác sĩ, chuyên khoa...',
              border: InputBorder.none,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: InkWell(
                    onTap: _showSpecialtyFilterSheet,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.category, size: 20),
                          const SizedBox(width: 6),
                          Text('Chuyên khoa: $_selectedSpecialtyName'),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _filteredDoctors.isEmpty
                      ? Center(
                          child: Text(
                            'Không tìm thấy bác sĩ.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredDoctors.length,
                          separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
                          itemBuilder: (_, i) {
                            final d = _filteredDoctors[i];
                            return InkWell(
                              // onTap: () {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (_) => BookingPage(doctor: d),
                              //     ),
                              //   );
                              // },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundImage: d.user?.avatar != null && d.user!.avatar.isNotEmpty
                                          ? NetworkImage(d.user!.avatar)
                                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${d.degree} • ${d.user?.username ?? 'Chưa tên'}",
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${d.specialization?.name ?? 'Chưa rõ'} · ${d.experienceYears} năm",
                                            style: TextStyle(color: Colors.grey.shade700),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (_) => BookingPage(doctor: d),
                                        //   ),
                                        // );
                                      },
                                      child: const Text('Đặt lịch'),
                                    ),
                                  ],
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
}
