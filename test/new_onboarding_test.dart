import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_heedh/main.dart';

void main() {
  testWidgets('New Onboarding Flow Test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const AlHeedhApp());

    // Skip splash screen
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify NameInputScreen is displayed
    expect(find.text('Selamat Datang di Al-Heedh'), findsOneWidget);
    expect(
        find.text('Masukkan nama panggilanmu dan status haid untuk memulai.'),
        findsOneWidget);

    // Enter name
    await tester.enterText(
        find.byKey(const ValueKey('name-input')), 'Test Pengguna');

    // Select status (Baru Mengalami Haid)
    await tester.tap(find.text('Baru Mengalami Haid'));
    await tester.pump();

    // Tap continue button
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify MainScreen is displayed with greeting
    expect(find.text('Assalamualaikum, Test Pengguna!'), findsOneWidget);
  });

  testWidgets('Prediction Question Dialog Test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const AlHeedhApp());

    // Skip splash screen
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Enter name and select Sudah Biasa Haid
    await tester.enterText(
        find.byKey(const ValueKey('name-input')), 'Test Pengguna');
    await tester.tap(find.text('Sudah Biasa Haid'));
    await tester.pump();
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    // Verify prediction question dialog
    expect(find.text('Apakah anda ingin memprediksi haid berikutnya?'),
        findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('Six Records Form Navigation Test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const AlHeedhApp());

    // Skip splash screen and onboarding to reach main screen
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.enterText(
        find.byKey(const ValueKey('name-input')), 'Test Pengguna');
    await tester.tap(find.text('Sudah Biasa Haid'));
    await tester.pump();
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    // Tap OK to show six records form
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify form is displayed
    expect(find.text('Riwayat 6 Haid Sebelumnya'), findsOneWidget);
    expect(find.text('Masukkan durasi haid dan jarak suci antara haid:'),
        findsOneWidget);
  });
}
