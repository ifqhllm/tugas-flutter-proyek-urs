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

      expect(result['status'], equals('HAID SELAMA 5 HARI'));
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

      expect(result['status'], equals('HAID SELAMA 15 HARI'));
      expect(result['type'], equals('HAID'));
      expect(result['haidDays'], equals(15));
      expect(result['istihadahDays'], equals(4));
      expect(
        result['message'],
        contains("karena ini adalah haid pertama anda maka sesuai hukum syari'at haid anda adalah 15 hari selebihnya istihadah"),
      );
    });

    test('Accustomed user with 7 days custom and > 15 days bleeding should have 7 days haid and rest istihadah', () {
      final start = DateTime(2026, 5, 1, 8, 0);
      final end = DateTime(2026, 5, 16, 8, 0); // 16 days
      
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

      expect(result['status'], equals('HAID SELAMA 7 HARI'));
      expect(result['type'], equals('HAID'));
      expect(result['haidDays'], equals(7));
      expect(result['istihadahDays'], equals(9));
      expect(result['message'], contains("7 hari haid mengikuti kebiasaan haid yang anda inputkan, selebihnya istihadah"));
    });
  });
}
