import 'appointment.dart';

class Feedback {
  final int feedbackId;
  final int appointmentId;
  final int rating;
  final String? comment;
  final Appointment? appointment;

  Feedback({
    required this.feedbackId,
    required this.appointmentId,
    required this.rating,
    this.comment,
    this.appointment,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      feedbackId: json['feedback_id'] as int,
      appointmentId: json['appointment_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      appointment: json['appointment'] != null
          ? Appointment.fromJson(json['appointment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedback_id': feedbackId,
      'appointment_id': appointmentId,
      'rating': rating,
      'comment': comment,
      if (appointment != null) 'appointment': appointment!.toJson(),
    };
  }
}
