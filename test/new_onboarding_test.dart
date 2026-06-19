import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_heedh/models/haid_record.dart';
import 'package:al_heedh/models/blood_event.dart';
import 'package:al_heedh/services/haid_service.dart';

import 'package:al_heedh/main.dart';

class FakeHaidService extends HaidService {
  final List<HaidRecord> records = [];

  @override
  Future<List<HaidRecord>> getAllRecords() async {
    return records;
  }

  @override
  Future<HaidRecord?> getCurrentActiveRecord() async {
    final active = records.where((r) => r.endDate == null).toList();
    return active.isNotEmpty ? active.first : null;
  }

  @override
  Future<HaidRecord?> getLastEndedRecord() async {
    final ended = records.where((r) => r.endDate != null).toList();
    if (ended.isNotEmpty) {
      ended.sort((a, b) => b.endDate!.compareTo(a.endDate!));
      return ended.first;
    }
    return null;
  }

  @override
  Future<void> startHaid(DateTime startDate) async {
    records.add(HaidRecord(startDate: startDate));
  }

  @override
  Future<void> endHaidFinal(DateTime endDate) async {
    final active = await getCurrentActiveRecord();
    if (active != null) {
      active.endDate = endDate;
    }
  }

  @override
  Future<void> logBloodEvent(DateTime timestamp, String type) async {
    final active = await getCurrentActiveRecord();
    if (active != null) {
      active.bloodEvents.add(BloodEvent(timestamp: timestamp, type: type));
    }
  }

  @override
  Future<void> clearAllRecords() async {
    records.clear();
  }
}

void main() {
  setUp(() {
    haidService = FakeHaidService();
  });

  testWidgets('New Onboarding Flow Test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build the app
    await tester.pumpWidget(const AlHeedhApp(hasUser: false));

    // Verify NameInputScreen is displayed
    expect(find.text('Selamat Datang di Al-Heedh'), findsOneWidget);
    expect(
        find.text('Masukkan nama panggilanmu dan status haid untuk memulai.'),
        findsOneWidget);

    // Enter name
    await tester.enterText(
        find.byKey(const ValueKey('name-input')), 'Test');

    // Select status (Baru Mengalami Haid)
    await tester.tap(find.text('Baru Mengalami Haid'));
    await tester.pump();

    // Tap continue button
    await tester.tap(find.text('Lanjutkan'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Verify MainScreen is displayed with greeting
    expect(find.text('Assalamualaikum, Test!'), findsOneWidget);
  });

  testWidgets('Prediction Question Dialog Test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build the app
    await tester.pumpWidget(const AlHeedhApp(hasUser: false));

    // Enter name and select Sudah Biasa Haid
    await tester.enterText(
        find.byKey(const ValueKey('name-input')), 'Test');
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
    SharedPreferences.setMockInitialValues({});
    // Build the app
    await tester.pumpWidget(const AlHeedhApp(hasUser: false));

    await tester.enterText(
        find.byKey(const ValueKey('name-input')), 'Test');
    await tester.tap(find.text('Sudah Biasa Haid'));
    await tester.pump();
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    // Tap OK to show six records form
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify form is displayed
    expect(find.text('Durasi 6 Siklus Sebelumnya'), findsOneWidget);
    expect(find.text('Durasi Siklus ke-1 (hari)'), findsOneWidget);
  });
}
