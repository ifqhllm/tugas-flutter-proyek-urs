import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_heedh/models/haid_record.dart';
import 'package:al_heedh/models/blood_event.dart';
import 'package:al_heedh/services/haid_service.dart';

import 'package:al_heedh/main.dart'; // Sesuaikan path jika berbeda

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

  testWidgets('Cek Teks Selamat Datang setelah input nama',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Bangun aplikasi kita dan picu frame.
    await tester.pumpWidget(const AlHeedhApp(hasUser: false));

    // Verifikasi bahwa NameInputScreen muncul
    expect(find.text('Selamat Datang di Al-Heedh'), findsOneWidget);

    // Masukkan teks ke dalam TextField
    await tester.enterText(find.byKey(const ValueKey('name-input')), 'Test');

    // Pilih status (Baru Mengalami Haid)
    await tester.tap(find.text('Baru Mengalami Haid'));
    await tester.pump();

    // Tekan tombol 'Lanjutkan'
    await tester.tap(find.text('Lanjutkan'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Verifikasi bahwa sapaan 'Assalamualaikum' muncul di halaman utama
    expect(find.text('Assalamualaikum, Test!'), findsOneWidget);
  });
}
