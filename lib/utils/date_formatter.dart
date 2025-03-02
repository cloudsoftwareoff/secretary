import 'package:intl/intl.dart';

class DateFormatter {
  // Format date from ISO string
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('EEE, MMM d, yyyy · h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  
  static String getDateHeaderText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return "Today";
    } else if (dateOnly.isAtSameMomentAs(tomorrow)) {
      return "Tomorrow";
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  // is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // is tomorrow
  static bool isTomorrow(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
}