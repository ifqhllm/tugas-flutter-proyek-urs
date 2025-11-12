// lib/pages/calendar_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/haid_record.dart'; // Sesuaikan path-nya
import '../services/fikih_service.dart'; // Sesuaikan path-nya
import '../constants/colors.dart'; // Import warna dan kunci

// Akses services global yang didefinisikan di tempat lain
final FikihService fikihService = FikihService();

class CalendarPage extends StatelessWidget {
  final List<HaidRecord> records;
  final DateTime? predictedDate;

  const CalendarPage({super.key, required this.records, this.predictedDate});

  // Fungsi bantu untuk mendapatkan warna penanda tanggal
  Color? _getMarkerColor(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);

    // 1. Cek Prediksi
    if (predictedDate != null) {
      final startPrediction = DateTime(
          predictedDate!.year, predictedDate!.month, predictedDate!.day);
      final endPrediction = startPrediction.add(const Duration(days: 7));

      if ((normalizedDay.isAtSameMomentAs(startPrediction) ||
              normalizedDay.isAfter(startPrediction)) &&
          normalizedDay.isBefore(endPrediction)) {
        return primaryColor.withOpacity(0.7); // Warna prediksi (Tosca pudar)
      }
    }

    // 2. Cek Riwayat Haid (Riwayat Haid & Istihadah)
    final isHaidPeriod = records.any((record) {
      final recordStart = DateTime(
          record.startDate.year, record.startDate.month, record.startDate.day);

      // Batas Akhir: Tanggal endDate jika ada, atau Tanggal Hari Ini jika masih aktif.
      final recordEnd = record.endDate != null
          ? DateTime(
              record.endDate!.year, record.endDate!.month, record.endDate!.day)
          : DateTime.now();

      // Cek apakah hari ini ada dalam rentang Haid/Istihadah
      return (normalizedDay.isAtSameMomentAs(recordStart) ||
              normalizedDay.isAfter(recordStart)) &&
          (normalizedDay.isBefore(recordEnd.add(const Duration(days: 1))));
    });

    if (isHaidPeriod) {
      // Logic complex: Cek apakah hari ini berada dalam periode Haid yang sudah divalidasi
      final relevantRecord = records.firstWhere(
        (r) =>
            (r.endDate != null) &&
            normalizedDay.isAfter(
                DateTime(r.startDate.year, r.startDate.month, r.startDate.day)
                    .subtract(const Duration(days: 1))) &&
            normalizedDay.isBefore(r.endDate!.add(const Duration(days: 1))),
        orElse: () => records.firstWhere(
          (r) =>
              r.endDate == null &&
              normalizedDay.isAfter(
                  DateTime(r.startDate.year, r.startDate.month, r.startDate.day)
                      .subtract(const Duration(days: 1))),
          orElse: () => HaidRecord(
              startDate: DateTime(2000), endDate: DateTime(2000)), // Fallback
        ),
      );

      if (relevantRecord.endDate != null) {
        final statusFinal =
            fikihService.getHukumStatus(normalizedDay, [relevantRecord]);

        if (statusFinal.startsWith('ISTIHADAH')) {
          return primaryColor.withOpacity(0.8); // Warna Istihadah
        }
      }

      return secondaryColor; // Warna riwayat Haid (Merah Tua)
    }

    return null;
  }

  // Fungsi utama untuk mewarnai hari
  List<Widget> _getMarkers(DateTime day) {
    final markerColor = _getMarkerColor(day);
    if (markerColor == null) return [];

    return [
      Positioned(
        bottom: 5,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Kalender Siklus',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              locale: 'id_ID',
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: secondaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: _getMarkers(day),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Keterangan:',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const ListTile(
            leading: Icon(Icons.circle, color: secondaryColor),
            title: Text('Tanggal Haid (Riwayat Final)'),
          ),
          ListTile(
            leading: Icon(Icons.circle, color: primaryColor.withOpacity(0.8)),
            title: const Text('Tanggal Istihadah (Riwayat Final)'),
          ),
          ListTile(
            leading: Icon(Icons.circle, color: primaryColor.withOpacity(0.7)),
            title: const Text('Prediksi Haid Mendatang (ML)'),
          ),
        ],
      ),
    );
  }
}
