import 'package:flutter/material.dart';
import 'package:flutterproject/features/home/widget/doctor_card.dart';
import 'package:flutterproject/features/home/model/doctor.dart';
import 'package:flutterproject/features/home/view_model/doctor_controller.dart';

/// Widget chính hiển thị section "Top Doctors to Book"
class DoctorListSection extends StatefulWidget {
  const DoctorListSection({Key? key}) : super(key: key);

  @override
  State<DoctorListSection> createState() => _DoctorListSectionState();
}

class _DoctorListSectionState extends State<DoctorListSection> {
  final DoctorController _doctorController = DoctorController();
  List<Doctor> doctors = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await _doctorController.fetchAllDoctors();

      setState(() {
        doctors = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        // Fallback data nếu không load được từ API
        doctors = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          // Tiêu đề chính
          Text(
            'Top Doctors to Book',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Simply browse through our extensive list of trusted doctors.',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Content với loading/error handling
          if (isLoading)
            const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load doctors',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadDoctors,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (doctors.isEmpty)
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No doctors available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // === ListView.builder cuộn ngang ===
            SizedBox(
              height: 300, // Chiều cao cố định để chứa mỗi card bác sĩ
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                padding: const EdgeInsets.only(left: 8),
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 160, // Chiều rộng cố định cho mỗi card
                      child: DoctorCard(doctor: doctor),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          // Nút "More"
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 10), // Tăng chiều rộng và chiều cao
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue.shade900,
              elevation: 2, // Thêm chút độ nổi
              shadowColor: Colors.blue.shade200, // Màu bóng nhẹ
            ),
            onPressed: () {
              // TODO: Thêm hành động khi nhấn "More"
            },
            child: const Text(
              'More',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}