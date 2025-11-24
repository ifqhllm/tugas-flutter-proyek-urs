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
            const Text(
              'Keterangan:',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const ListTile(
              leading: Icon(Icons.circle, color: Colors.red),
              title: Text('Tanggal Haid (Riwayat Final)'),
            ),
            ListTile(
              leading: Icon(Icons.circle, color: Colors.green),
              title: const Text('Tanggal Istihadah (Riwayat Final)'),
            ),
            ListTile(
              leading: Icon(Icons.circle, color: Colors.pink),
              title: const Text('Prediksi Haid Mendatang'),
            ),
          ],
        ),
      ),
    );
  }
}
