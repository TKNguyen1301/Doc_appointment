import 'package:flutter/material.dart';
import 'package:flutterproject/utils/formatters/date_formatter.dart';
import 'package:flutterproject/utils/constants/colors.dart';
class DateSelector extends StatelessWidget {
  final DateTime displayedMonth;
  final List<Map<String, dynamic>> dates;
  final int selectedDateIndex;
  final Function(int) onDateSelected;
  final VoidCallback onMonthYearPick;

  const DateSelector({
    Key? key,
    required this.displayedMonth,
    required this.dates,
    required this.selectedDateIndex,
    required this.onDateSelected,
    required this.onMonthYearPick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String monthLabel =
        'Tháng ${displayedMonth.month.toString().padLeft(2, '0')}/${displayedMonth.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn ngày khám',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Selector tháng (chỉ chọn tháng-năm)
        GestureDetector(
          onTap: onMonthYearPick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(monthLabel, style: const TextStyle(fontSize: 14)),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Danh sách ngày còn lại trong tháng (scroll ngang)
        SizedBox(
          height: 120,
          child: dates.isEmpty
              ? Center(
                  child: Text(
                    'Không có ngày khả dụng trong tháng này',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final dayInfo = dates[index];
                    final isSelected = index == selectedDateIndex;
                    return GestureDetector(
                      onTap: () => onDateSelected(index),
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayInfo['weekday'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (dayInfo['day'] as int).toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dayInfo['slots']} slots',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white70 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}