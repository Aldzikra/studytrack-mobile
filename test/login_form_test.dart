import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studytrack_mobile/features/auth/login_screen.dart';
import 'package:studytrack_mobile/features/auth/validators.dart';

Future<void> _pump(WidgetTester t) => t.pumpWidget(
    const ProviderScope(child: MaterialApp(home: LoginScreen())));

void main() {
  testWidgets('form kosong menampilkan error', (t) async {
    await _pump(t);
    await t.ensureVisible(find.widgetWithText(FilledButton, 'Masuk'));
    await t.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await t.pump();
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('email tidak valid & password < 8', (t) async {
    await _pump(t);
    await t.enterText(find.byType(TextFormField).first, 'bukan-email');
    await t.enterText(find.byType(TextFormField).last, '1234567');
    await t.ensureVisible(find.widgetWithText(FilledButton, 'Masuk'));
    await t.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await t.pump();
    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  test('validator menerima input valid', () {
    expect(validateEmail('a@b.co'), isNull);
    expect(validatePassword('12345678'), isNull);
  });
}
