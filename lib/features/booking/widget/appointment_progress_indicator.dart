import 'package:flutter/material.dart';
import 'package:flutterproject/utils/constants/colors.dart';

class AppointmentProgressIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, 3

  const AppointmentProgressIndicator({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStep(
              stepNumber: 1,
              title: 'Chọn lịch khám',
              isCompleted: currentStep > 1,
              isActive: currentStep == 1,
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            _buildStep(
              stepNumber: 2,
              title: 'Xác nhận',
              isCompleted: currentStep > 2,
              isActive: currentStep == 2,
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            _buildStep(
              stepNumber: 3,
              title: 'Nhận lịch hẹn',
              isCompleted: currentStep > 3,
              isActive: currentStep == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required int stepNumber,
    required String title,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleColor = Colors.grey.shade300;
    Color textColor = Colors.grey.shade500;
    Widget circleChild = Text(
      stepNumber.toString(),
      style: const TextStyle(color: Colors.white),
    );

    if (isCompleted) {
      circleColor = Colors.green.shade400;
      textColor = Colors.green;
      circleChild = const Icon(Icons.check, size: 16, color: Colors.white);
    } else if (isActive) {
      circleColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
          ),
          alignment: Alignment.center,
          child: circleChild,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontSize: 13, color: textColor),
        ),
      ],
    );
  }
}