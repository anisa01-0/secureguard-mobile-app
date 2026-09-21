import 'package:flutter_test/flutter_test.dart';
import 'package:secureguard/utils/formatters.dart';

/// Unit tests for the date, time and duration helpers.
void main() {
  final DateTime reference = DateTime(2026, 9, 20, 20, 45);

  group('Dates', () {
    test('formats a full date', () {
      expect(Formatters.fullDate(reference), 'September 20, 2026');
    });

    test('formats a short date', () {
      expect(Formatters.shortDate(reference), '20 Sep 2026');
    });

    test('names the weekday', () {
      expect(Formatters.weekday(reference), 'Sunday');
    });
  });

  group('Times', () {
    test('uses a 12-hour clock with AM and PM', () {
      expect(Formatters.time(reference), '8:45 PM');
      expect(Formatters.time(DateTime(2026, 9, 20, 9, 5)), '9:05 AM');
    });

    test('shows midnight and midday as 12', () {
      expect(Formatters.time(DateTime(2026, 9, 20)), '12:00 AM');
      expect(Formatters.time(DateTime(2026, 9, 20, 12)), '12:00 PM');
    });

    test('combines date and time', () {
      expect(
        Formatters.dateAndTime(reference),
        'September 20, 2026 at 8:45 PM',
      );
    });
  });

  group('Friendly labels', () {
    test('says Today and Yesterday', () {
      expect(
        Formatters.friendlyDateTime(reference, now: reference),
        'Today, 8:45 PM',
      );
      expect(
        Formatters.friendlyDateTime(
          reference.subtract(const Duration(days: 1)),
          now: reference,
        ),
        'Yesterday, 8:45 PM',
      );
    });

    test('falls back to a short date for older events', () {
      expect(
        Formatters.friendlyDateTime(
          DateTime(2026, 9, 14, 20, 45),
          now: reference,
        ),
        '14 Sep, 8:45 PM',
      );
    });

    test('describes relative times', () {
      expect(
        Formatters.relative(
          reference.subtract(const Duration(seconds: 10)),
          now: reference,
        ),
        'Just now',
      );
      expect(
        Formatters.relative(
          reference.subtract(const Duration(minutes: 12)),
          now: reference,
        ),
        '12 min ago',
      );
      expect(
        Formatters.relative(
          reference.subtract(const Duration(hours: 3)),
          now: reference,
        ),
        '3 h ago',
      );
    });
  });

  group('Durations', () {
    test('formats the SOS timer as mm:ss', () {
      expect(Formatters.timer(const Duration(seconds: 9)), '00:09');
      expect(Formatters.timer(const Duration(minutes: 2, seconds: 5)), '02:05');
      expect(
        Formatters.timer(const Duration(hours: 1, minutes: 2, seconds: 5)),
        '01:02:05',
      );
    });

    test('describes a duration in words', () {
      expect(
        Formatters.readableDuration(const Duration(seconds: 42)),
        '42 seconds',
      );
      expect(
        Formatters.readableDuration(const Duration(minutes: 2, seconds: 15)),
        '2 min 15 s',
      );
    });
  });

  group('Greeting', () {
    test('changes with the time of day', () {
      expect(
        Formatters.greeting(now: DateTime(2026, 9, 20, 8)),
        'Good morning',
      );
      expect(
        Formatters.greeting(now: DateTime(2026, 9, 20, 14)),
        'Good afternoon',
      );
      expect(
        Formatters.greeting(now: DateTime(2026, 9, 20, 19)),
        'Good evening',
      );
      expect(Formatters.greeting(now: DateTime(2026, 9, 20, 23)), 'Good night');
    });
  });
}
