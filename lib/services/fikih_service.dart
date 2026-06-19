import '../models/haid_record.dart';
import '../models/blood_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FikihService {
  Map<String, dynamic> _calculateRecordPeriods(HaidRecord record) {
    final endTime = record.endDate ?? DateTime.now();
    final totalSpanHours = endTime.difference(record.startDate).inHours;

    final events = List<BloodEvent>.from(record.bloodEvents);
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int totalRecordedHours = 0;
    DateTime currentStart = record.startDate;
    bool isFlowing = true;

    for (var event in events) {
      if (event.type == 'END') {
        if (isFlowing) {
          totalRecordedHours += event.timestamp.difference(currentStart).inHours;
          isFlowing = false;
        }
      } else if (event.type == 'Pencatatan' || event.type == 'START') {
        if (!isFlowing) {
          currentStart = event.timestamp;
          isFlowing = true;
        }
      }
    }

    if (isFlowing) {
      totalRecordedHours += endTime.difference(currentStart).inHours;
    }

    if (totalRecordedHours == 0) {
      totalRecordedHours = totalSpanHours;
    }

    final hasInterruption = events.any((e) => e.type == 'Pencatatan');

    return {
      'totalRecordedHours': totalRecordedHours,
      'totalSpanHours': totalSpanHours,
      'hasInterruption': hasInterruption,
    };
  }

  Map<String, dynamic> _getFinalStatus(HaidRecord record, {required String haidStatus, required int kebiasaanHaid}) {
    final endTime = record.endDate ?? DateTime.now();

    final endDay = DateTime(endTime.year, endTime.month, endTime.day);
    final startDay = DateTime(record.startDate.year, record.startDate.month, record.startDate.day);
    final totalDurationDays = endDay.difference(startDay).inDays + 1;

    // Batasan Fikih
    const int minHaidHours = 24; // Minimal haid 24 jam
    const int maxHaidHours = 360; // Maksimal haid 15 hari (15 * 24 = 360 jam)

    // Calculate periods with support for interrupted menstruation (darah terputus-putus)
    final periods = _calculateRecordPeriods(record);
    final int totalRecordedHours = periods['totalRecordedHours'] as int;
    final int totalSpanHours = periods['totalSpanHours'] as int;
    final bool hasInterruption = periods['hasInterruption'] as bool;

    if (hasInterruption) {
      if (totalSpanHours <= maxHaidHours) {
        final totalDays = totalSpanHours ~/ 24;
        final remainingHours = totalSpanHours % 24;

        final statusStr = remainingHours > 0
            ? 'HAID SELAMA $totalDays HARI $remainingHours JAM'
            : 'HAID SELAMA $totalDays HARI';

        final statusVal = record.endDate == null ? 'HAID SEMENTARA' : statusStr;

        final msg = 'Total Pencatatan $totalRecordedHours jam Maka Haid anda adalah $totalDays hari $remainingHours jam, Silahkan Baca Dalilnya melalui tombol berikut';

        return {
          'status': statusVal,
          'type': 'HAID',
          'haidDays': totalDurationDays,
          'istihadahDays': 0,
          'predictionDays': totalDays,
          'message': msg,
          'showInterruptedHaidButton': true,
        };
      } else {
        final haidDaysVal = kebiasaanHaid > 0 ? kebiasaanHaid : 15;
        const statusStr = 'ISTIHADAH LEBIH 15 HARI';
        final msg = 'Total Pencatatan $totalRecordedHours jam Terhitung lebih 15 hari tergolong istihadah maka haid anda adalah $haidDaysVal Hari mengikuti kebiasaan haid anda, Silahkan baca Dalilnya Melalui tombol berikut';

        return {
          'status': statusStr,
          'type': 'ISTIHADAH_LONG',
          'haidDays': haidDaysVal,
          'istihadahDays': totalDurationDays - haidDaysVal,
          'predictionDays': haidDaysVal,
          'message': msg,
          'showInterruptedHaidButton': true,
        };
      }
    }

    // Default flow (no interruption)
    // Scenario 1: Kurang dari 24 jam
    if (totalRecordedHours < minHaidHours) {
      if (record.endDate == null) {
        return {
          'status': 'HAID SEMENTARA',
          'type': 'HAID_ACTIVE',
          'haidDays': 0,
          'istihadahDays': totalDurationDays,
          'predictionDays': 0,
          'message': 'Catat terus untuk status haid yang valid',
        };
      } else {
        return {
          'status': 'ISTIHADAH KURANG DARI 24 JAM',
          'type': 'ISTIHADAH_SHORT',
          'haidDays': 0,
          'istihadahDays': totalDurationDays,
          'predictionDays': 0,
          'message':
              'Total pencatatan $totalRecordedHours jam terhitung istihadah karena tidak mencapai minimal masa haid, silahkan baca dalilnya melalui tombol berikut',
          'showMasaHaidButton': true,
        };
      }
    }

    // Scenario 2: Lebih dari 15 hari (360 jam)
    if (totalRecordedHours > maxHaidHours) {
      int haidDaysVal = 0;
      if (haidStatus == 'Baru Mengalami') {
        haidDaysVal = 15;
      } else if (haidStatus == 'Sudah Biasa' && kebiasaanHaid > 0) {
        haidDaysVal = kebiasaanHaid;
      } else {
        haidDaysVal = 15;
      }

      return {
        'status': 'ISTIHADAH LEBIH 15 HARI',
        'type': haidDaysVal > 0 ? 'HAID' : 'ISTIHADAH_LONG',
        'haidDays': haidDaysVal,
        'istihadahDays': totalDurationDays - haidDaysVal,
        'predictionDays': haidDaysVal,
        'message': 'Total pencatatan $totalRecordedHours jam terhitung istihadah karena lebih dari maksimal masa haid, Silahkan baca dalilnya melalui tombol berikut',
        'showMasaHaidButton': true,
      };
    }

    // Scenario 3: Ongoing dan masih dalam batas 15 hari dan >= 24 jam
    if (record.endDate == null) {
      final elapsedDays = totalRecordedHours ~/ 24;
      return {
        'status': 'HAID SEMENTARA',
        'type': 'HAID_ACTIVE',
        'haidDays': elapsedDays,
        'istihadahDays': 0,
        'predictionDays': elapsedDays,
      };
    }

    // Scenario 4: Selesai, >= 24 jam dan <= 15 hari (360 jam)
    final totalDays = totalRecordedHours ~/ 24;
    final remainingHours = totalRecordedHours % 24;
    final statusStr = remainingHours > 0
        ? 'HAID SELAMA $totalDays HARI $remainingHours JAM'
        : 'HAID SELAMA $totalDays HARI';

    return {
      'status': statusStr,
      'type': 'HAID',
      'haidDays': totalDurationDays, // Color all days in calendar red
      'istihadahDays': 0,
      'predictionDays': totalDays,
      'message': 'total pencatatan $totalRecordedHours jam terhitung haid selama $totalDays hari $remainingHours jam, silahkan baca dalilnya melalui tombol berikut',
      'showMasaHaidButton': true,
    };
  }

  // --- 2. Mendapatkan Status Hukum untuk tanggal tertentu ---
  String getHukumStatus(DateTime date, List<HaidRecord> allRecords, {String haidStatus = 'Sudah Biasa', int kebiasaanHaid = 0}) {
    if (allRecords.isEmpty) {
      return 'SUCI';
    }

    final checkDate = DateTime(date.year, date.month, date.day);

    for (var record in allRecords) {
      final start = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);

      if (record.endDate == null) {
        if (checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) {
          final statusDetail = getDetailedHukumStatus(checkDate, allRecords, haidStatus: haidStatus, kebiasaanHaid: kebiasaanHaid);
          return statusDetail['status'] as String;
        }
      } else {
        final end = DateTime(
            record.endDate!.year, record.endDate!.month, record.endDate!.day);

        if ((checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) &&
            (checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end))) {
          final statusMap = _getFinalStatus(record, haidStatus: haidStatus, kebiasaanHaid: kebiasaanHaid);
          return statusMap['status'] as String;
        }
      }
    }

    return 'SUCI';
  }

  // --- Mendapatkan Detail Status Lengkap ---
  Map<String, dynamic> getDetailedHukumStatus(
      DateTime date, List<HaidRecord> allRecords, {String haidStatus = 'Sudah Biasa', int kebiasaanHaid = 0}) {
    if (allRecords.isEmpty) {
      return {'status': 'SUCI', 'type': 'SUCI'};
    }

    final checkDate = DateTime(date.year, date.month, date.day);

    for (var record in allRecords) {
      final start = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);

      if (record.endDate == null) {
        if (checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) {
          final today = DateTime.now();
          final todayMidnight = DateTime(today.year, today.month, today.day);
          
          // Jika checkDate melebihi hari ini, jangan diwarnai di kalender (belum terjadi)
          if (checkDate.isAfter(todayMidnight)) {
            continue;
          }

          return _getFinalStatus(record, haidStatus: haidStatus, kebiasaanHaid: kebiasaanHaid);
        }
      } else {
        final end = DateTime(
            record.endDate!.year, record.endDate!.month, record.endDate!.day);

        if ((checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) &&
            (checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end))) {
          return _getFinalStatus(record, haidStatus: haidStatus, kebiasaanHaid: kebiasaanHaid);
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
        final prevStartDay = DateTime(prevStart.year, prevStart.month, prevStart.day);
        final currStartDay = DateTime(currStart.year, currStart.month, currStart.day);
        final cycleLength = currStartDay.difference(prevStartDay).inDays;
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
