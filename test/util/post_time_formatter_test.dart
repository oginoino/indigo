import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/util/formatter/post_time_formatter.dart';

void main() {
  group('PostTimeFormatter', () {
    final now = DateTime.utc(2026, 11, 18, 12);

    test('formats relative time across nearby and distant dates', () {
      expect(
        PostTimeFormatter.formatRelative(
          now.subtract(const Duration(seconds: 30)),
          now: now,
        ),
        'agora',
      );
      expect(
        PostTimeFormatter.formatRelative(
          now.subtract(const Duration(minutes: 5)),
          now: now,
        ),
        'há 5 min',
      );
      expect(
        PostTimeFormatter.formatRelative(
          now.subtract(const Duration(days: 3)),
          now: now,
        ),
        'há 3 dias',
      );
      expect(
        PostTimeFormatter.formatRelative(
          now.subtract(const Duration(days: 400)),
          now: now,
        ),
        'há 1 ano',
      );
    });

    test('formats exact timestamps for the accessible tooltip', () {
      expect(
        PostTimeFormatter.formatAbsolute(DateTime(2026, 2, 3, 9, 7)),
        '03/02/2026 às 09:07',
      );
    });
  });
}
