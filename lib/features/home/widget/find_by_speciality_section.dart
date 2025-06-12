import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterproject/features/home/widget/speciality_card.dart';
import 'package:flutterproject/features/home/view_model/specialization_controller.dart';
import 'package:flutterproject/features/home/model/specialization.dart';
import 'package:get/get.dart';
import '../../search_page/view/search_doctor.dart';
import '../../authentication/model_view/patient_controller.dart';
import '../../home/view_model/doctor_controller.dart';

class FindBySpecialitySection extends StatefulWidget {
  const FindBySpecialitySection({super.key});

  @override
  State<FindBySpecialitySection> createState() => _FindBySpecialitySectionState();
}

class _FindBySpecialitySectionState extends State<FindBySpecialitySection> {
  final DoctorController _doctorController = DoctorController();
  final PatientController _patientController = PatientController();
  List<Specialization> specializations = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSpecializationsFromDoctors();
  }

  Future<void> _loadSpecializationsFromDoctors() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      await _patientController.isAuthenticated();
      final token = _patientController.token;
      
      // Get doctors data which contains specialization info
      final doctors = await _doctorController.fetchAllDoctors(token: token);
      
      // Extract unique specializations from doctors
      final specializationMap = <int, Specialization>{};
      for (final doctor in doctors) {
        if (doctor.specialization != null) {
          specializationMap[doctor.specialization!.specializationId] = doctor.specialization!;
        }
      }
      
      setState(() {
        specializations = specializationMap.values.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        
        specializations = _createFallbackSpecializations();
      });
      
      if (kDebugMode) {
        print('Error loading specializations from doctors: $e');
      }
    }
  }

  List<Specialization> _createFallbackSpecializations() {
    return [
      Specialization(
        specializationId: 1,
        name: 'General Physician',
        image: 'https://cdn1.youmed.vn/tin-tuc/wp-content/uploads/2023/05/yhocduphong.png',
        fees: 100,
      ),
      Specialization(
        specializationId: 2,
        name: 'Cardiology',
        image: 'https://cdn1.youmed.vn/tin-tuc/wp-content/uploads/2023/05/yhocduphong.png',
        fees: 150,
      ),
      Specialization(
        specializationId: 3,
        name: 'Neurology',
        image: 'https://cdn1.youmed.vn/tin-tuc/wp-content/uploads/2023/05/yhocduphong.png',
        fees: 200,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Find by Speciality',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const SizedBox(height: 24),

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
                      onPressed: _loadSpecializationsFromDoctors,
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