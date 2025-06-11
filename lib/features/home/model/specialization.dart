import 'doctor.dart';

class Specialization {
  final int specializationId;
  final String name;
  final String image;
  final int fees;
  final List<Doctor>? doctors;

  Specialization({
    required this.specializationId,
    required this.name,
    required this.image,
    required this.fees,
    this.doctors,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      specializationId: json['specialization_id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      fees: json['fees'] as int,
      doctors: json['doctors'] != null
          ? (json['doctors'] as List)
              .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'specialization_id': specializationId,
      'name': name,
      'image': image,
      'fees': fees,
    };
    if (doctors != null) {
      data['doctors'] = doctors!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}