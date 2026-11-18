import '../const/app/app_strings.dart';

class PostTimeFormatter {
  const PostTimeFormatter._();

  static const _minute = Duration(minutes: 1);
  static const _hour = Duration(hours: 1);
  static const _day = Duration(days: 1);
  static const _week = Duration(days: 7);
  static const _month = Duration(days: 30);
  static const _year = Duration(days: 365);

  static String formatRelative(DateTime dateTime, {DateTime? now}) {
    final elapsed = (now ?? DateTime.now()).difference(dateTime);
    if (elapsed.isNegative || elapsed < _minute) return AppStrings.postTimeNow;
    if (elapsed < _hour) {
      return elapsed.inMinutes == 1
          ? AppStrings.postTimeMinute
          : _withCount(AppStrings.postTimeMinutes, elapsed.inMinutes);
    }
    if (elapsed < _day) {
      return elapsed.inHours == 1
          ? AppStrings.postTimeHour
          : _withCount(AppStrings.postTimeHours, elapsed.inHours);
    }
    if (elapsed < _week) {
      return elapsed.inDays == 1
          ? AppStrings.postTimeDay
          : _withCount(AppStrings.postTimeDays, elapsed.inDays);
    }
    if (elapsed < _month) {
      final weeks = elapsed.inDays ~/ _week.inDays;
      return weeks == 1
          ? AppStrings.postTimeWeek
          : _withCount(AppStrings.postTimeWeeks, weeks);
    }
    if (elapsed < _year) {
      final months = elapsed.inDays ~/ _month.inDays;
      return months == 1
          ? AppStrings.postTimeMonth
          : _withCount(AppStrings.postTimeMonths, months);
    }

    final years = elapsed.inDays ~/ _year.inDays;
    return years == 1
        ? AppStrings.postTimeYear
        : _withCount(AppStrings.postTimeYears, years);
  }

  static String formatAbsolute(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final day = _twoDigits(localDate.day);
    final month = _twoDigits(localDate.month);
    final hour = _twoDigits(localDate.hour);
    final minute = _twoDigits(localDate.minute);
    return '$day/$month/${localDate.year} às $hour:$minute';
  }

  static String _withCount(String template, int count) =>
      template.replaceAll('{count}', '$count');

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
