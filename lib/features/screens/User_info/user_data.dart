/// Mock user model for demo

class User {

  String name;

  String phone;

  String birthdate;

  String gender;

  String? address;

  String? ethnicity;

  String? occupation;

  String? email;

  String? healthInsurance;

  String? citizenId;

  String patientId; // Added patientId field




  User({

    required this.name,

    required this.phone,

    required this.birthdate,

    required this.gender,

    this.address,

    this.ethnicity,

    this.occupation,

    this.email,

    this.healthInsurance,

    this.citizenId,

    required this.patientId, // Initialize patientId
    

  });

}


final User currentUser = User(
  name: 'Trần Khánh Nguyên',
  phone: '+84 896 204 571',
  birthdate: '13/01/2003',
  gender: 'Nam',
  address: '123 Đường Lê Lợi, Quận 1, TP.HCM',
  ethnicity: 'Kinh',
  occupation: 'Kỹ sư phần mềm',
  email: 'nguyen@example.com',
  healthInsurance: '123456789',
  citizenId: '0123456789',
  patientId: 'BN001234',
);
