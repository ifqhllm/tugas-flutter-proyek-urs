import 'package:flutter/material.dart';
import '../models/haid_record.dart';
import '../services/fikih_service.dart';
import '../constants/colors.dart';

class MonthlyCalendarGrid extends StatelessWidget {
  final DateTime focusedDay;
  final List<HaidRecord> records;
  final DateTime? predictedDate;
  final FikihService fikihService;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const MonthlyCalendarGrid({
    super.key,
    required this.focusedDay,
    required this.records,
    this.predictedDate,
    required this.fikihService,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  Color? _getMarkerColor(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);

    // 1. Cek Prediksi
    if (predictedDate != null) {
      final predictionDay = DateTime(
          predictedDate!.year, predictedDate!.month, predictedDate!.day);

      if (normalizedDay.isAtSameMomentAs(predictionDay)) {
        return predictionColor; // Warna prediksi kuning
      }
    }

    // 2. Cek Riwayat Haid dengan logic baru
    for (final record in records) {
      if (record.endDate == null) continue; // Skip ongoing records

      final recordStart = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);
      final recordEnd = DateTime(
          record.endDate!.year, record.endDate!.month, record.endDate!.day);

      // Cek apakah hari ini dalam rentang record ini
      if ((normalizedDay.isAtSameMomentAs(recordStart) ||
              normalizedDay.isAfter(recordStart)) &&
          (normalizedDay.isAtSameMomentAs(recordEnd) ||
              normalizedDay.isBefore(recordEnd.add(const Duration(days: 1))))) {
        // Dapatkan detail status lengkap
        final statusDetail =
            fikihService.getDetailedHukumStatus(normalizedDay, [record]);
        final statusType = statusDetail['type'] as String;
        final haidDays = statusDetail['haidDays'] as int? ?? 0;

        // Hitung hari ke berapa dalam siklus ini
        final dayIndex = normalizedDay.difference(recordStart).inDays;

        // Logika pewarnaan berdasarkan scenario
        if (statusType == 'HAID') {
          // Scenario 1: Semua hari adalah haid
          return menstrualColor; // Merah
        } else if (statusType == 'ISTIHADAH_SHORT') {
          // Scenario 2: Hari pertama = haid, sisanya = istihadah
          return dayIndex == 0
              ? menstrualColor
              : istihadahColor; // Merah : Hijau
        } else if (statusType == 'ISTIHADAH_LONG') {
          // Scenario 3: 15 hari pertama = haid, sisanya = istihadah
          return dayIndex < haidDays
              ? menstrualColor
              : istihadahColor; // Merah : Hijau
        }
      }
    }

    return null;
  }

  Widget _buildDayOfWeek(String day) {
    Color textColor = Colors.black87;
    if (day == 'Jumat') {
      textColor = Colors.green;
    } else if (day == 'Ahad') {
      textColor = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        day,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDayCell(DateTime? day, bool isCurrentMonth) {
    if (day == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
      );
    }

    final markerColor = _getMarkerColor(day);
    final isToday = day.year == DateTime.now().year &&
        day.month == DateTime.now().month &&
        day.day == DateTime.now().day;

    Color textColor = isCurrentMonth ? Colors.black87 : Colors.grey;
    if (day.weekday == DateTime.friday) {
      textColor = Colors.green;
    } else if (day.weekday == DateTime.sunday) {
      textColor = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: markerColor ??
            (isCurrentMonth
                ? const Color(0xFFFFF8FA)
                : Colors.white), // Full background color for events
        border: isToday
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    final daysInMonth = lastDayOfMonth.day;

    // Adjust for Sunday first: 7 = Sunday, 1 = Monday, ..., 6 = Saturday
    final startWeekday = firstWeekday == 7 ? 0 : firstWeekday; // 0 for Sunday

    const totalCells = 42; // 6 weeks * 7 days
    final days = <DateTime?>[];

    // Previous month days
    final prevMonth = DateTime(focusedDay.year, focusedDay.month, 0);
    for (int i = startWeekday - 1; i >= 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, prevMonth.day - i));
    }

    // Current month days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(focusedDay.year, focusedDay.month, i));
    }

    // Next month days
    final nextMonthStart = days.length;
    for (int i = nextMonthStart; i < totalCells; i++) {
      days.add(DateTime(
          focusedDay.year, focusedDay.month + 1, i - nextMonthStart + 1));
    }

    const daysOfWeek = [
      'Ahad',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];

    return Column(
      children: [
        // Header with month year and navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_getMonthName(focusedDay.month)} ${focusedDay.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Days of week header
        Row(
          children: daysOfWeek
              .map((day) => Expanded(child: _buildDayOfWeek(day)))
              .toList(),
        ),
        // Grid
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1, // Slightly wider cells
          children: days.map((day) {
            final isCurrentMonth = day != null && day.month == focusedDay.month;
            return _buildDayCell(day, isCurrentMonth);
          }).toList(),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }
}
