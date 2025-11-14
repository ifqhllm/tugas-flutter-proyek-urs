import '../models/haid_record.dart';

class FikihService {
  String _getFinalStatus(HaidRecord record) {
    // Hitung durasi total dalam jam
    final duration = record.endDate!.difference(record.startDate).inHours;

    // Batasan Fikih
    const int minHaidHours = 24; // 1 Hari
    const int maxHaidHours = 360; // 15 Hari

    // 1. Durasi Kurang dari Minimal Haid
    if (duration < minHaidHours) {
      return 'ISTIHADAH (Kurang dari 24 Jam)';
    }

    // 2. Durasi Melebihi Maksimal Haid
    if (duration > maxHaidHours) {
      return 'ISTIHADAH (Melebihi 15 Hari)';
    }

    // 3. Lolos Batas Minimum dan Maksimum
    return 'HAID';
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
          return _getFinalStatus(record);
        }
      }
    }

    return 'SUCI';
  }

// Siklus dihitung dari endDate siklus sebelumnya hingga endDate siklus ini.
  List<int> _calculateCycleLengths(List<HaidRecord> completedRecords) {
    // Hanya proses record yang sudah memiliki endDate
    final validRecords =
        completedRecords.where((r) => r.endDate != null).toList();

    // Urutkan dari yang paling lama ke yang paling baru
    validRecords.sort((a, b) => a.startDate.compareTo(b.startDate));

    if (validRecords.length < 2) {
      return []; // Minimal butuh 2 data untuk menghitung 1 siklus
    }

    List<int> cycleLengths = [];

    // Siklus dihitung dari startDate satu record ke startDate record berikutnya.
    for (int i = 1; i < validRecords.length; i++) {
      final startCurrent = validRecords[i].startDate;
      final startPrevious = validRecords[i - 1].startDate;

      final length = startCurrent.difference(startPrevious).inDays;
      if (length > 0) {
        cycleLengths.add(length);
      }
    }

    return cycleLengths;
  }

// --- FUNGSI BANTU UNTUK ML: Regresi Linier Sederhana ---
// Menggunakan rumus Y = a + bX
  double _simpleLinearRegression(List<int> data, bool isSlope) {
    if (data.length < 2) return 0.0;

    final x = List<double>.generate(data.length, (i) => (i + 1).toDouble());
    final y = data.map((d) => d.toDouble()).toList();

    final n = data.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumX2 = x.map((xi) => xi * xi).reduce((a, b) => a + b);
    final sumXY = x
        .asMap()
        .entries
        .map((e) => e.value * y[e.key])
        .reduce((a, b) => a + b);

    final meanX = sumX / n;
    final meanY = sumY / n;

    final numerator = sumXY - (sumX * sumY) / n;
    final denominator = sumX2 - (sumX * sumX) / n;

    final b = (denominator == 0) ? 0.0 : numerator / denominator;

    final a = meanY - b * meanX;

    return isSlope ? b : a;
  }

// --- FUNGSI UTAMA PREDIKSI ML ---
  DateTime? getNextPredictedStartDate(List<HaidRecord> allRecords) {
    final cycleLengths = _calculateCycleLengths(allRecords);

    if (cycleLengths.length < 3) {
      final latestEndDate = allRecords
          .lastWhere((r) => r.endDate != null,
              orElse: () => HaidRecord(startDate: DateTime.now()))
          .endDate;
      if (latestEndDate == null) return null;

      if (cycleLengths.isNotEmpty) {
        final averageLength =
            cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
        return latestEndDate.add(Duration(days: averageLength.round()));
      }

      return latestEndDate.add(const Duration(days: 28)); // Rata-rata default
    }

    final b = _simpleLinearRegression(cycleLengths, true); // Slope
    final a = _simpleLinearRegression(cycleLengths, false); // Intercept

    final nextX = (cycleLengths.length + 1).toDouble();
    final predictedLength = a + b * nextX;

    final latestStartDate =
        allRecords.lastWhere((r) => r.endDate != null).startDate;

    return latestStartDate.add(Duration(days: predictedLength.round()));
  }
}
