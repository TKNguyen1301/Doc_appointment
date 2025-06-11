import 'appointment.dart';

class Payment {
  final int paymentId;
  final int appointmentId;
  final int amount;
  final String? paymentMethod; // "cash", "credit_card", "e-wallet"
  final String status; // "paid", "pending"
  final Appointment? appointment;

  Payment({
    required this.paymentId,
    required this.appointmentId,
    required this.amount,
    this.paymentMethod,
    required this.status,
    this.appointment,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'] as int,
      appointmentId: json['appointment_id'] as int,
      amount: json['amount'] as int,
      paymentMethod: json['payment_method'] as String?,
      status: json['status'] as String,
      appointment: json['appointment'] != null
          ? Appointment.fromJson(json['appointment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'payment_id': paymentId,
      'appointment_id': appointmentId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
    };
    if (appointment != null) {
      data['appointment'] = appointment?.toJson();
    }
    return data;
  }
}
