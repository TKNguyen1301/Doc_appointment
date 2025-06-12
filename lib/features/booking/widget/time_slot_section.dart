import 'package:flutter/material.dart';
import 'package:flutterproject/utils/formatters/date_formatter.dart';
import 'package:flutterproject/utils/constants/colors.dart';
class TimeSlotsSection extends StatelessWidget {
  final String selectedSession;
  final int selectedTimeIndex;
  final List<String> morningSlots;
  final List<String> afternoonSlots;
  final List<Map<String, dynamic>> dates;
  final int selectedDateIndex;
  final Map<String, List<String>> bookedSlots;
  final Function(String, int) onTimeSlotSelected;
  final Function(String) onSessionChanged;

  const TimeSlotsSection({
    Key? key,
    required this.selectedSession,
    required this.selectedTimeIndex,
    required this.morningSlots,
    required this.afternoonSlots,
    required this.dates,
    required this.selectedDateIndex,
    required this.bookedSlots,
    required this.onTimeSlotSelected,
    required this.onSessionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding 2 bên
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn giờ khám',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // TabBar để chọn Buổi sáng / Buổi chiều
          DefaultTabController(
            length: 2,
            initialIndex: selectedSession == 'morning' ? 0 : 1,
            child: Column(
              children: [
                TabBar(
                  onTap: (index) {
                    onSessionChanged(index == 0 ? 'morning' : 'afternoon');
                  },
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Buổi sáng'),
                    Tab(text: 'Buổi chiều'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: TabBarView(
                    children: [
                      _buildTimeSlots(isMorning: true),
                      _buildTimeSlots(isMorning: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots({required bool isMorning}) {
    if (dates.isEmpty || selectedDateIndex >= dates.length) {
      return const Center(child: Text('Không có dữ liệu ngày'));
    }

    final Map<String, dynamic> dayInfo = dates[selectedDateIndex];
    final DateTime dateObj = dayInfo['dateObj'] as DateTime;
    final String dateKey = DateFormatter.formatDateKey(dateObj);
    final List<String> bookedForDay = bookedSlots[dateKey] ?? [];

    final List<String> slotList = isMorning ? morningSlots : afternoonSlots;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding trong
        child: _buildGridTimeSlots(slotList, bookedForDay, dateObj, isMorning),
      ),
    );
  }

  Widget _buildGridTimeSlots(List<String> slotList, List<String> bookedForDay,
      DateTime dateObj, bool isMorning) {
    
    // Tính toán số cột dựa trên độ rộng màn hình
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mỗi slot tối thiểu 100px, tối đa 4 cột
        final double availableWidth = constraints.maxWidth;
        final int crossAxisCount = (availableWidth / 110).floor().clamp(2, 4);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5, // Tỷ lệ width/height
          ),
          itemCount: slotList.length,
          itemBuilder: (context, i) {
            final String slot = slotList[i];
            final DateTime slotEnd = DateFormatter.parseSlotEndTime(dateObj, slot);
            final DateTime now = DateTime.now();

            // Xác định xem slot này đã qua ("past") hay đã bị booked
            bool isPast = false;
            if (dateObj.year == now.year &&
                dateObj.month == now.month &&
                dateObj.day == now.day) {
              if (slotEnd.isBefore(now) || slotEnd.isAtSameMomentAs(now)) {
                isPast = true;
              }
            }
            bool isBooked = bookedForDay.contains(slot);

            // Nếu quá hạn hoặc đã booked, không cho chọn
            final bool isDisabled = isPast || isBooked;

            // Kiểm tra xem slot đang được chọn
            final bool isSlotSelected =
                (selectedSession == (isMorning ? 'morning' : 'afternoon') &&
                    selectedTimeIndex == i);

            // Nếu slot đã disabled, override selected state
            final Color borderColor = isDisabled
                ? Colors.grey.shade400
                : (isSlotSelected ? AppColors.primary : Colors.grey.shade300);
            final Color textColor = isDisabled
                ? Colors.grey.shade400
                : (isSlotSelected ? Colors.white : Colors.black87);
            final Color bgColor = isDisabled 
                ? Colors.grey.shade200 
                : (isSlotSelected ? AppColors.primary : Colors.white);

            return GestureDetector(
              onTap: () {
                if (isDisabled) return;
                onTimeSlotSelected(isMorning ? 'morning' : 'afternoon', i);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: isSlotSelected ? 2 : 1,
                  ),
                  boxShadow: isSlotSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                      fontWeight: isSlotSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}