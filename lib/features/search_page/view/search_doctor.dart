import 'package:flutter/material.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/features/home/view_model/doctor_controller.dart';
import 'package:flutterproject/features/authentication/model_view/patient_controller.dart';

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
  final PatientController _patientController = PatientController();

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
      // Get token for authentication
      await _patientController.isAuthenticated();
      final token = _patientController.token;

      // Fetch ALL doctors without any filter to get complete data
      final doctors = await _controller.fetchAllDoctors(token: token);

      setState(() {
        _allDoctors = doctors;

        // Extract unique specializations from all doctors
        final Map<int, Map<String, dynamic>> uniqueSpecs = {};
        for (final doctor in _allDoctors) {
          if (doctor.specialization != null) {
            final spec = doctor.specialization!;
            uniqueSpecs[spec.specializationId] = {
              'id': spec.specializationId,
              'name': spec.name,
            };
          }
        }

        _specialties = [
          {'id': null, 'name': 'Tất cả'},
          ...uniqueSpecs.values.toList(),
        ];

        // Set initial filter if specialty is provided
        if (widget.specialty != null && widget.specialty!.isNotEmpty) {
          final matchingSpec = _specialties.firstWhere(
            (spec) => spec['name'] == widget.specialty,
            orElse: () => {'id': null, 'name': 'Tất cả'},
          );
          _selectedSpecialtyName = matchingSpec['name'];
          _selectedSpecialtyId = matchingSpec['id'];
        }

        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách bác sĩ: $e')),
      );
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        // Filter by search query
        final matchesSearch = query.isEmpty ||
            (doc.user?.username.toLowerCase().contains(query) ?? false) ||
            (doc.specialization?.name.toLowerCase().contains(query) ?? false);

        // Filter by specialty
        final matchesSpecialty = _selectedSpecialtyId == null ||
            doc.specialization?.specializationId == _selectedSpecialtyId;

        return matchesSearch && matchesSpecialty;
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

                    // Count doctors for this specialty
                    int doctorCount = 0;
                    if (spec['id'] == null) {
                      // "Tất cả" - count all doctors
                      doctorCount = _allDoctors.length;
                    } else {
                      // Count doctors for specific specialty
                      doctorCount = _allDoctors
                          .where((d) => d.specialization?.specializationId == spec['id'])
                          .length;
                    }

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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    spec['name'],
                                    style: TextStyle(
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    '$doctorCount bác sĩ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                      // Don't fetch doctors again, just apply filters
                      _applyFilters();
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
                          if (_selectedSpecialtyId != null)
                            Text(
                              ' (${_filteredDoctors.length})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy bác sĩ phù hợp',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedSpecialtyName = 'Tất cả';
                                    _selectedSpecialtyId = null;
                                    _searchController.clear();
                                  });
                                  _applyFilters();
                                },
                                child: const Text('Xem tất cả bác sĩ'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredDoctors.length,
                          separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
                          itemBuilder: (_, i) {
                            final d = _filteredDoctors[i];
                            return InkWell(
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
                                          if (d.rating > 0) ...[
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.amber, size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  d.rating.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to booking page
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
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
