import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack_mobile/core/utils/date_format.dart';

void main() {
  wibToUtcTests();
  headerFormatTests();
  test('formatWib: UTC → WIB', () {
    expect(formatWib(DateTime.utc(2026, 7, 2, 3, 0)), 'Kam, 2 Jul 2026 · 10.00');
  });
  test('formatWib: lewat tengah malam WIB', () {
    expect(formatWib(DateTime.utc(2026, 12, 31, 20, 5)), 'Jum, 1 Jan 2027 · 03.05');
  });
  final now = DateTime.utc(2026, 7, 2, 0, 0);
  test('Sisa', () {
    expect(deadlineLabel(now.add(const Duration(hours: 5, minutes: 30)), now), 'Sisa 5 jam');
  });
  test('Terlambat', () {
    expect(deadlineLabel(now.subtract(const Duration(hours: 3)), now), 'Terlambat 3 jam');
  });
  test('kurang dari 1 jam', () {
    expect(deadlineLabel(now.add(const Duration(minutes: 20)), now), 'Sisa <1 jam');
  });
}

void wibToUtcTests() {
  group('wibToUtc', () {
    test('10.00 WIB → 03:00Z', () {
      expect(wibToUtc(DateTime(2026, 7, 2, 10, 0)), DateTime.utc(2026, 7, 2, 3, 0));
    });
    test('lintas hari: 03.00 WIB 1 Jan → 20:00Z 31 Des', () {
      expect(wibToUtc(DateTime(2026, 1, 1, 3, 0)), DateTime.utc(2025, 12, 31, 20, 0));
    });
    test('RFC3339 berakhiran Z', () {
      expect(wibToUtc(DateTime(2026, 7, 2, 10, 0)).toIso8601String(), '2026-07-02T03:00:00.000Z');
    });
    test('bolak-balik dengan toWib', () {
      final w = toWib(wibToUtc(DateTime(2026, 7, 2, 23, 45)));
      expect([w.year, w.month, w.day, w.hour, w.minute], [2026, 7, 2, 23, 45]);
    });
  });
}

void headerFormatTests() {
  test('formatWibLong', () {
    expect(formatWibLong(DateTime.utc(2026, 7, 2, 2, 0)), 'Kamis, 2 Juli 2026 · 09.00 WIB');
  });
  test('formatWibShort', () {
    expect(formatWibShort(DateTime.utc(2026, 7, 2, 3, 0)), 'Kam, 2 Jul · 10.00');
  });
}
