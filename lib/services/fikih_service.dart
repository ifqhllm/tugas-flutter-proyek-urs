import '../models/haid_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FikihService {
  Map<String, dynamic> _getFinalStatus(HaidRecord record) {
    // Hitung durasi total dalam jam dari start sampai end
    final totalDurationDays =
        record.endDate!.difference(record.startDate).inDays + 1;

    // Hitung jumlah event yang dicatat (setiap event = 1 jam)
    final loggedHours = record.bloodEvents.length;

    // Batasan Fikih
    const int minHaidHours = 24; // Minimal haid 24 jam
    const int maxHaidDays = 15; // Maksimal haid 15 hari

    // Scenario 1: Normal Haid (24+ jam dalam 15 hari)
    if (totalDurationDays <= maxHaidDays && loggedHours >= minHaidHours) {
      return {
        'status': 'HAID SELAMA $totalDurationDays HARI',
        'type': 'HAID',
        'haidDays': totalDurationDays,
        'istihadahDays': 0,
        'predictionDays': totalDurationDays,
      };
    }

    // Scenario 2: Istihaadah < 24 jam
    if (totalDurationDays <= maxHaidDays && loggedHours < minHaidHours) {
      return {
        'status': 'ISTIHADAH KURANG DARI 24 JAM',
        'type': 'ISTIHADAH_SHORT',
        'haidDays': 1,
        'istihadahDays': totalDurationDays - 1,
        'predictionDays': 1,
        'message':
            'Karena kurang dari 24 jam maka haid anda adalah 1 hari. Silahkan Qadha\' sholat dan puasa jika ditinggalkan',
      };
    }

    // Scenario 3: Istihaadah > 15 hari
    if (totalDurationDays > maxHaidDays) {
      return {
        'status': 'ISTIHADAH LEBIH DARI 15 HARI',
        'type': 'ISTIHADAH_LONG',
        'haidDays': maxHaidDays,
        'istihadahDays': totalDurationDays - maxHaidDays,
        'predictionDays': maxHaidDays,
        'message': 'Haid anda adalah 15 hari. Selebihnya istihadah',
      };
    }

    // Default fallback
    return {
      'status': 'HAID',
      'type': 'HAID',
      'haidDays': totalDurationDays,
      'istihadahDays': 0,
      'predictionDays': totalDurationDays,
    };
  }

// --- 2. Mendapatkan Status Hukum untuk tanggal tertentu ---
  String getHukumStatus(DateTime date, List<HaidRecord> allRecords) {
    if (allRecords.isEmpty) {
      return 'SUCI (Belum ada riwayat)';
    }

    final checkDate = DateTime(date.year, date.month, date.day);

    for (var record in allRecords) {
      final start = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);

      if (record.endDate == null) {
        if (checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) {
          return 'HAID SEMENTARA';
        }
      } else {
        final end = DateTime(
            record.endDate!.year, record.endDate!.month, record.endDate!.day);

        if ((checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) &&
            (checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end))) {
          final statusMap = _getFinalStatus(record);
          return statusMap['status'] as String;
        }
      }
    }

    return 'SUCI';
  }

  // --- Mendapatkan Detail Status Lengkap ---
  Map<String, dynamic> getDetailedHukumStatus(
      DateTime date, List<HaidRecord> allRecords) {
    if (allRecords.isEmpty) {
      return {'status': 'SUCI (Belum ada riwayat)', 'type': 'SUCI'};
    }

    final checkDate = DateTime(date.year, date.month, date.day);

    for (var record in allRecords) {
      final start = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);

      if (record.endDate == null) {
        if (checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) {
          return {'status': 'HAID SEMENTARA', 'type': 'HAID_SEMENTARA'};
        }
      } else {
        final end = DateTime(
            record.endDate!.year, record.endDate!.month, record.endDate!.day);

        if ((checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) &&
            (checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end))) {
          return _getFinalStatus(record);
        }
      }
    }

    return {'status': 'SUCI', 'type': 'SUCI'};
  }

// Hitung rata-rata durasi haid berdasarkan aturan baru
  double _calculateAverageHaidLength(List<HaidRecord> completedRecords) {
    final validRecords =
        completedRecords.where((r) => r.endDate != null).toList();
    if (validRecords.isEmpty) return 0.0;

    final totalPredictionDays = validRecords.map((r) {
      final statusMap = _getFinalStatus(r);
      return statusMap['predictionDays'] as int;
    }).reduce((a, b) => a + b);

    return totalPredictionDays / validRecords.length;
  }

// --- FUNGSI UTAMA PREDIKSI MENGGUNAKAN REGRESI LINIER SEDERHANA ---
  Future<DateTime?> getNextPredictedStartDate(
      List<HaidRecord> allRecords) async {
    final completedRecords =
        allRecords.where((r) => r.endDate != null).toList();
    if (completedRecords.isEmpty) return null;

    final latestEndDate = completedRecords.last.endDate!;
    final prefs = await SharedPreferences.getInstance();
    final suciHabits =
        prefs.getInt('suci_habits') ?? 14; // Default 14 hari suci

    // Jika hanya 1 record, gunakan rata-rata sederhana
    if (completedRecords.length < 2) {
      final averageHaidLength = _calculateAverageHaidLength(completedRecords);
      final predictedCycleLength = averageHaidLength + suciHabits;
      return latestEndDate.add(Duration(days: predictedCycleLength.round()));
    }

    // Hitung panjang siklus historis: Y = haid_days + suci_habits
    final cycleLengths = <double>[];
    for (int i = 0; i < completedRecords.length; i++) {
      final record = completedRecords[i];
      final statusMap = _getFinalStatus(record);
      final haidDays = statusMap['predictionDays'] as int;
      final cycleLength = haidDays + suciHabits;
      cycleLengths.add(cycleLength.toDouble());
    }

    // X = urutan siklus (1, 2, 3, ...)
    final n = cycleLengths.length;
    final xValues = List<double>.generate(n, (i) => (i + 1).toDouble());

    // Hitung regresi linier: Y = a + bX
    final sumX = xValues.reduce((a, b) => a + b);
    final sumY = cycleLengths.reduce((a, b) => a + b);
    final sumXY = List<double>.generate(n, (i) => xValues[i] * cycleLengths[i])
        .reduce((a, b) => a + b);
    final sumX2 = xValues.map((x) => x * x).reduce((a, b) => a + b);

    final b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final a = (sumY - b * sumX) / n;

    // Prediksi untuk siklus berikutnya: X_next = n + 1
    final xNext = (n + 1).toDouble();
    final predictedCycleLength = a + b * xNext;

    return latestEndDate.add(Duration(days: predictedCycleLength.round()));
  }
}
