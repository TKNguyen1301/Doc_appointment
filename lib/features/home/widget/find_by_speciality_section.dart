import 'package:flutter/material.dart';
import 'package:flutterproject/features/home/widget/speciality_card.dart';
import 'package:flutterproject/features/home/view_model/specialization_controller.dart';
import 'package:flutterproject/features/home/model/specialization.dart';
import 'package:get/get.dart';
import '../../search_page/view/search_doctor.dart';

class FindBySpecialitySection extends StatefulWidget {
  const FindBySpecialitySection({super.key});

  @override
  State<FindBySpecialitySection> createState() => _FindBySpecialitySectionState();
}

class _FindBySpecialitySectionState extends State<FindBySpecialitySection> {
  final SpecializationService _specializationService = SpecializationService();
  List<Specialization> specializations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSpecializations();
  }

  Future<void> _loadSpecializations() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final result = await _specializationService.getAllSpecializations();
      
      setState(() {
        specializations = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        // Fallback data nếu không load được từ API
        specializations = [
          Specialization(
            specializationId: 1,
            name: 'General physician',
            image: '', // Empty string để dùng SVG mặc định
            fees: 100,
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiêu đề chính
          const Text(
            'Find by Speciality',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const SizedBox(height: 24),

          // Hiển thị loading, error hoặc danh sách chuyên khoa
          if (isLoading)
            const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null && specializations.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadSpecializations,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: specializations.map((specialization) {
                  return SpecialityCard(
                    label: specialization.name,
                    image: specialization.image.isNotEmpty ? specialization.image : null,
                    onTap: () {
                      // Chuyển đến trang tìm kiếm bác sĩ theo chuyên khoa
                      Get.to(() => DoctorSearchPage(specialty: specialization.name));
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}