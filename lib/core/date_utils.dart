/// Date and time utilities for health app
library date_utils;

/// Get start of week (Monday)
DateTime getWeekStart(DateTime date) {
  final diff = date.weekday - DateTime.monday;
  return date.subtract(Duration(days: diff)).copyWith(
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );
}

/// Get end of week (Sunday)
DateTime getWeekEnd(DateTime date) {
  return getWeekStart(date).add(const Duration(days: 7, microseconds: -1));
}

/// Get start of month
DateTime getMonthStart(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

/// Get end of month
DateTime getMonthEnd(DateTime date) {
  return DateTime(date.year, date.month + 1, 1)
      .subtract(const Duration(microseconds: 1));
}

/// Get days between two dates
int daysBetween(DateTime from, DateTime to) {
  return to.difference(from).inDays.abs();
}

/// Check if date is in the past
bool isPast(DateTime date) {
  return date.isBefore(DateTime.now());
}

/// Check if date is in the future
bool isFuture(DateTime date) {
  return date.isAfter(DateTime.now());
}

/// Check if dates are same day
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

/// Get days in current year
int get daysInCurrentYear {
  final now = DateTime.now();
  final isLeap = (now.year % 4 == 0 && now.year % 100 != 0) ||
      (now.year % 400 == 0);
  return isLeap ? 366 : 365;
}

/// Calculate age from birthdate
int getAge(DateTime birthDate) {
  final today = DateTime.now();
  var age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}

/// Format duration for display
String formatDuration(Duration duration) {
  final inHours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (inHours == 0) return '${minutes}m';
  return '${inHours}h ${minutes}m';
}
