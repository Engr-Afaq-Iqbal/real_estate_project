import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatDateShort(DateTime date) =>
      DateFormat('dd MMM').format(date);

  static String formatDateFull(DateTime date) =>
      DateFormat('EEEE, dd MMM yyyy').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy · hh:mm a').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('hh:mm a').format(date);

  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return formatDateShort(date);
  }

  static String weeksRemaining(DateTime endDate) {
    final now = DateTime.now();
    final diff = endDate.difference(now);
    final weeks = (diff.inDays / 7).ceil();
    if (weeks <= 0) return 'Overdue';
    if (weeks == 1) return '1 wk left';
    return '$weeks wk left';
  }

  static String daysRemaining(DateTime endDate) {
    final now = DateTime.now();
    final diff = endDate.difference(now);
    if (diff.inDays < 0) return 'Overdue by ${diff.inDays.abs()}d';
    if (diff.inDays == 0) return 'Due today';
    return '${diff.inDays} days left';
  }

  static String monthsElapsed(DateTime startDate) {
    final now = DateTime.now();
    final months = (now.difference(startDate).inDays / 30).floor();
    if (months <= 0) return '< 1 month';
    if (months == 1) return '1 month';
    return '$months months';
  }
}
