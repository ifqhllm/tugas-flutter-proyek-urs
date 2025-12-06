// lib/pages/calendar_page.dart

import 'package:flutter/material.dart';
import '../models/haid_record.dart'; // Sesuaikan path-nya
import '../services/fikih_service.dart'; // Sesuaikan path-nya
import '../constants/colors.dart'; // Import warna dan kunci
import '../widgets/monthly_calendar_grid.dart'; // Import widget grid
import '../widgets/background_widget.dart'; // Import background widget

// Akses services global yang didefinisikan di tempat lain
final FikihService fikihService = FikihService();

class CalendarPage extends StatefulWidget {
  final List<HaidRecord> records;
  final DateTime? predictedDate;

  const CalendarPage({super.key, required this.records, this.predictedDate});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  // Di dalam class _CalendarPageState extends State<CalendarPage> { ... }

// Helper untuk membangun satu baris keterangan
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kotak Warna
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 4, right: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Keterangan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Widget utama untuk legend (menggantikan ListTile yang lama)
  Widget _buildMenstrualCycleLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan Siklus Haid:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Keterangan Hari Haid (Merah)
          _buildLegendItem(
            color: menstrualColor,
            label: 'Hari Haid (Merah)',
            description: 'Tanggal yang termasuk periode Haid (riwayat final).',
          ),

          // 2. Keterangan Hari Istihadah (Hijau)
          _buildLegendItem(
            color: istihadahColor,
            label: 'Hari Istihadah (Hijau)',
            description:
                'Tanggal yang termasuk periode Istihadah (riwayat final).',
          ),

          // 3. Keterangan Prediksi Haid (Kuning)
          _buildLegendItem(
            color: predictionColor,
            label: 'Tanggal Prediksi Haid (Kuning)',
            description: 'Prediksi tanggal haid/suci berikutnya (belum final).',
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
            MonthlyCalendarGrid(
              focusedDay: _focusedDay,
              records: widget.records,
              predictedDate: widget.predictedDate,
              fikihService: fikihService,
              onPreviousMonth: _previousMonth,
              onNextMonth: _nextMonth,
            ),
            const SizedBox(height: 20),
            _buildMenstrualCycleLegend(),
          ],
        ),
      ),
    );
  }
}
