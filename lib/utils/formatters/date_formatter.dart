class DateFormatter {
  static String formatDate(DateTime dt) {
    final weekdayMap = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN',
    };
    final wd = weekdayMap[dt.weekday]!;
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$wd $d/$m/$y';
  }

  static String formatDateKey(DateTime dateObj) {
    final y = dateObj.year.toString().padLeft(4, '0');
    final m = dateObj.month.toString().padLeft(2, '0');
    final d = dateObj.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String formatTimestamp(DateTime dt) {
    final hours = dt.hour.toString().padLeft(2, '0');
    final minutes = dt.minute.toString().padLeft(2, '0');
    final seconds = dt.second.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$hours:$minutes:$seconds $d/$m/$y';
  }

  static DateTime parseSlotEndTime(DateTime dateObj, String slot) {
    if (slot.contains('-')) {
      // Range format: "07:00 - 07:30"
      final parts = slot.split('-');
      final endPart = parts[1].trim();
      final hm = endPart.split(':');
      final int hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      return DateTime(dateObj.year, dateObj.month, dateObj.day, hour, minute);
    } else {
      // Single time format: "07:00" -> assume 10 minutes duration
      final hm = slot.trim().split(':');
      final int hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      return DateTime(
          dateObj.year, dateObj.month, dateObj.day, hour, minute + 10);
    }
  }

  static DateTime parseSlotStartTime(DateTime dateObj, String slot) {
    if (slot.contains('-')) {
      // Range format: "07:00 - 07:30"
      final parts = slot.split('-');
      final startPart = parts[0].trim();
      final hm = startPart.split(':');
      final int hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      return DateTime(dateObj.year, dateObj.month, dateObj.day, hour, minute);
    } else {
      // Single time format: "07:00"
      final hm = slot.trim().split(':');
      final int hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      return DateTime(dateObj.year, dateObj.month, dateObj.day, hour, minute);
    }
  }
}
