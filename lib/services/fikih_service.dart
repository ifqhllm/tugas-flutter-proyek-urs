import '../models/haid_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FikihService {
  Map<String, dynamic> _getFinalStatus(HaidRecord record) {
    // Hitung durasi dalam hari dari start sampai waktu saat ini (atau endDate jika sudah diakhiri)
    final endTime = record.endDate ?? DateTime.now();
    final totalDurationDays = endTime.difference(record.startDate).inDays + 1;

    // Hitung jumlah event yang dicatat (setiap event = 1 jam)
    final loggedHours = record.bloodEvents.length;
    final loggedDays = (loggedHours / 24).ceil();

    // Batasan Fikih
    const int minHaidHours = 24; // Minimal haid 24 jam
    const int maxHaidDays = 15; // Maksimal haid 15 hari

    // Check if currently 24+ hours and still within 15 days (active or ended)
    final is24HoursOrMore = loggedHours >= minHaidHours;
    final isWithin15Days = totalDurationDays <= maxHaidDays;
    final exceeds15Days = totalDurationDays > maxHaidDays;

    // Scenario 1: Recorded within 15 days AND 24+ hours recorded AND user ended haid
    // Status: "HAID SELAMA ... days" based on logged recording days
    if (isWithin15Days && is24HoursOrMore && record.endDate != null) {
      return {
        'status': 'HAID SELAMA $loggedDays HARI',
        'type': 'HAID',
        'haidDays': loggedDays,
        'istihadahDays': 0,
        'predictionDays': loggedDays,
      };
    }

    // Scenario 2: Recorded within 15 days BUT less than 24 hours total AND user ended haid
    // Status: "ISTIHADAH KURANG DARI 24 JAM"
    if (isWithin15Days &&
        loggedHours < minHaidHours &&
        record.endDate != null) {
      return {
        'status': 'ISTIHADAH KURANG DARI 24 JAM',
        'type': 'ISTIHADAH_SHORT',
        'haidDays': 0,
        'istihadahDays': totalDurationDays,
        'predictionDays': 0,
        'message':
            'Karena kurang dari 24 jam maka anda tidak memiliki hari haid. Silahkan Qadha\' sholat dan puasa jika ditinggalkan',
      };
    }

    // Scenario 3: 24+ hours recorded but exceeds 15 days (even if user hasn't ended haid yet)
    // Status: "ISTIHADAH LEBIH DARI 15 HARI"
    if (exceeds15Days || (is24HoursOrMore && !isWithin15Days)) {
      return {
        'status': 'ISTIHADAH LEBIH DARI 15 HARI',
        'type': 'ISTIHADAH_LONG',
        'haidDays': 0,
        'istihadahDays': totalDurationDays,
        'predictionDays': 0,
        'message':
            'Karena lebih dari 15 hari maka haid anda tergantung status mustahadahnya. Silahkan baca materi tentang mustahadah',
      };
    }

    // Active haid (within 15 days, 24+ hours, not ended yet) - showing current status
    if (is24HoursOrMore && !record.endDate!.isAfter(DateTime.now())) {
      return {
        'status': 'HAID SEMENTARA',
        'type': 'HAID_ACTIVE',
        'haidDays': loggedDays,
        'istihadahDays': 0,
        'predictionDays': loggedDays,
      };
    }

    // Default fallback (still recording, less than 24 hours within 15 days)
    return {
      'status': 'HAID SEMENTARA',
      'type': 'HAID_ACTIVE',
      'haidDays': 0,
      'istihadahDays': totalDurationDays,
      'predictionDays': 0,
      'message': 'Catat terus minimal 24 jam untuk status haid yang valid',
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

// --- FUNGSI UTAMA PREDIKSI ---
  Future<DateTime?> getNextPredictedStartDate(
      List<HaidRecord> allRecords) async {
    final prefs = await SharedPreferences.getInstance();

    final cycle1 = prefs.getInt('cycle_1');
    final cycle2 = prefs.getInt('cycle_2');
    final cycle3 = prefs.getInt('cycle_3');
    final cycle4 = prefs.getInt('cycle_4');
    final cycle5 = prefs.getInt('cycle_5');
    final cycle6 = prefs.getInt('cycle_6');

    List<double> allCycleLengths = [];

    // Add user-input cycles (1-6)
    if (cycle1 != null) allCycleLengths.add(cycle1.toDouble());
    if (cycle2 != null) allCycleLengths.add(cycle2.toDouble());
    if (cycle3 != null) allCycleLengths.add(cycle3.toDouble());
    if (cycle4 != null) allCycleLengths.add(cycle4.toDouble());
    if (cycle5 != null) allCycleLengths.add(cycle5.toDouble());
    if (cycle6 != null) allCycleLengths.add(cycle6.toDouble());

    // Get completed records sorted by startDate (chronological order)
    final completedRecords =
        allRecords.where((r) => r.endDate != null).toList();

    if (completedRecords.isNotEmpty) {
      completedRecords.sort((a, b) => a.startDate.compareTo(b.startDate));

      // Calculate cycle lengths from recorded haid (start to start of next haid)
      // History #7 = duration from cycle_6 end to first recorded haid start
      // History #8 = duration from first recorded haid start to second recorded haid start
      for (int i = 1; i < completedRecords.length; i++) {
        final prevStart = completedRecords[i - 1].startDate;
        final currStart = completedRecords[i].startDate;
        final cycleLength = currStart.difference(prevStart).inDays;
        if (cycleLength > 0) {
          allCycleLengths.add(cycleLength.toDouble());
        }
      }
    }

    if (allCycleLengths.isEmpty) return null;

    // Calculate average cycle length
    final averageCycleLength =
        allCycleLengths.reduce((a, b) => a + b) / allCycleLengths.length;

    // Base date is the start date of the most recent haid
    // If no records exist, use the date when user input the 6 cycles, or now
    DateTime baseDate;
    if (completedRecords.isNotEmpty) {
      completedRecords.sort((a, b) => b.startDate.compareTo(a.startDate));
      baseDate = completedRecords.first.startDate;
    } else {
      final cyclesInputDate = prefs.getInt('cycles_input_date');
      if (cyclesInputDate != null) {
        baseDate = DateTime.fromMillisecondsSinceEpoch(cyclesInputDate);
      } else {
        baseDate = DateTime.now();
      }
    }

    return baseDate.add(Duration(days: averageCycleLength.round()));
  }
}
