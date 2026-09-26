/// Small date/time helpers.
///
/// Written by hand instead of pulling in an extra localisation package, so
/// the project stays easy to read and has no avoidable dependencies.
class Formatters {
  const Formatters._();

  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// `September 20, 2026`
  static String fullDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  /// `20 Sep 2026`
  static String shortDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1].substring(0, 3)} ${date.year}';

  /// `Sunday`
  static String weekday(DateTime date) => _weekdays[date.weekday - 1];

  /// `8:45 PM`
  static String time(DateTime date) {
    final int hour24 = date.hour;
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = hour24 < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  /// `September 20, 2026 at 8:45 PM`
  static String dateAndTime(DateTime date) =>
      '${fullDate(date)} at ${time(date)}';

  /// `Today, 8:45 PM` / `Yesterday, 8:45 PM` / `20 Sep, 8:45 PM`
  static String friendlyDateTime(DateTime date, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final DateTime day = DateTime(date.year, date.month, date.day);
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final int diff = today.difference(day).inDays;
    if (diff == 0) return 'Today, ${time(date)}';
    if (diff == 1) return 'Yesterday, ${time(date)}';
    return '${date.day} ${_months[date.month - 1].substring(0, 3)}, ${time(date)}';
  }

  /// `Just now`, `12 min ago`, `3 h ago`, `4 d ago`.
  static String relative(DateTime date, {DateTime? now}) {
    final Duration diff = (now ?? DateTime.now()).difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return shortDate(date);
  }

  /// `01:23` - used by the SOS timer.
  static String timer(Duration duration) {
    final String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// `2 min 15 s` - readable duration used in the history detail screen.
  static String readableDuration(Duration duration) {
    if (duration.inMinutes < 1) return '${duration.inSeconds} seconds';
    if (duration.inHours < 1) {
      final int seconds = duration.inSeconds.remainder(60);
      return '${duration.inMinutes} min${seconds > 0 ? ' $seconds s' : ''}';
    }
    final int minutes = duration.inMinutes.remainder(60);
    return '${duration.inHours} h${minutes > 0 ? ' $minutes min' : ''}';
  }

  /// A greeting based on the time of day, used on the dashboard.
  static String greeting({DateTime? now}) {
    final int hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }
}
