import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack_mobile/core/utils/date_format.dart';

void main() {
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
