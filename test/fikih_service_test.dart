import 'package:flutter_test/flutter_test.dart';
import 'package:al_heedh/services/fikih_service.dart';
import 'package:al_heedh/models/haid_record.dart';
import 'package:al_heedh/models/blood_event.dart';

void main() {
  group('FikihService Unit Tests - Baru Mengalami (Mubtada\'ah)', () {
    final fikihService = FikihService();

    test('First-time user with <= 15 days should have normal haid status', () {
      final start = DateTime(2026, 5, 1, 8, 0);
      final end = DateTime(2026, 5, 5, 8, 0);
      
      // Create 24+ blood events (at least 24 hours logged)
      final events = List.generate(
        24,
        (i) => BloodEvent(timestamp: start.add(Duration(hours: i)), type: 'CONTINUE_FLOW'),
      );

      final record = HaidRecord(
        startDate: start,
        endDate: end,
        bloodEvents: events,
      );

      final result = fikihService.getDetailedHukumStatus(
        end,
        [record],
        haidStatus: 'Baru Mengalami',
      );

      expect(result['status'], equals('HAID SELAMA 4 HARI'));
      expect(result['type'], equals('HAID'));
      expect(result['haidDays'], equals(5));
      expect(result['istihadahDays'], equals(0));
    });

    test('First-time user with > 15 days (e.g., 19 days) should have 15 days haid and rest istihadah', () {
      final start = DateTime(2026, 5, 1, 8, 0);
      final end = DateTime(2026, 5, 19, 8, 0);
      
      // Create 24+ blood events (at least 24 hours logged)
      final events = List.generate(
        24,
        (i) => BloodEvent(timestamp: start.add(Duration(hours: i)), type: 'CONTINUE_FLOW'),
      );

      final record = HaidRecord(
        startDate: start,
        endDate: end,
        bloodEvents: events,
      );

      final result = fikihService.getDetailedHukumStatus(
        end,
        [record],
        haidStatus: 'Baru Mengalami',
      );

      expect(result['status'], equals('ISTIHADAH LEBIH 15 HARI'));
      expect(result['type'], equals('HAID'));
      expect(result['haidDays'], equals(15));
      expect(result['istihadahDays'], equals(4));
      expect(
        result['message'],
        contains("terhitung istihadah karena lebih dari maksimal masa haid"),
      );
    });

    test('Accustomed user with 7 days custom and > 15 days bleeding should have 7 days haid and rest istihadah', () {
      final start = DateTime(2026, 5, 1, 8, 0);
      final end = DateTime(2026, 5, 17, 8, 0); // 16 days / 384 hours (> 15 days)
      
      final events = List.generate(
        24,
        (i) => BloodEvent(timestamp: start.add(Duration(hours: i)), type: 'CONTINUE_FLOW'),
      );

      final record = HaidRecord(
        startDate: start,
        endDate: end,
        bloodEvents: events,
      );

      final result = fikihService.getDetailedHukumStatus(
        end,
        [record],
        haidStatus: 'Sudah Biasa',
        kebiasaanHaid: 7,
      );

      expect(result['status'], equals('ISTIHADAH LEBIH 15 HARI'));
      expect(result['type'], equals('HAID'));
      expect(result['haidDays'], equals(7));
      expect(result['istihadahDays'], equals(10));
      expect(result['message'], contains("terhitung istihadah karena lebih dari maksimal masa haid"));
    });
  });
}
