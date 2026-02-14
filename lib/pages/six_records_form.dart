import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/haid_record.dart';
import 'package:hive_flutter/hive_flutter.dart';

void showSixRecordsBottomSheet(BuildContext context, String name) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ScrollController scrollController) {
          return _SixRecordsBottomSheetContent(name: name);
        },
      );
    },
  );
}

class _SixRecordsBottomSheetContent extends StatefulWidget {
  final String name;
  const _SixRecordsBottomSheetContent({required this.name});

  @override
  State<_SixRecordsBottomSheetContent> createState() =>
      _SixRecordsBottomSheetContentState();
}

class _SixRecordsBottomSheetContentState
    extends State<_SixRecordsBottomSheetContent> {
  final List<TextEditingController> _durationControllers =
      List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> _intervalControllers =
      List.generate(5, (index) => TextEditingController());
  DateTime? _lastPeriodDate;

  Future<void> _saveRecordsAndNavigate() async {
    // Validate all inputs
    bool isValid = true;
    List<int> durations = [];
    List<int> intervals = [];

    for (var i = 0; i < 6; i++) {
      final duration = int.tryParse(_durationControllers[i].text.trim());
      if (duration == null || duration <= 0) {
        isValid = false;
        break;
      }
      durations.add(duration);
    }

    for (var i = 0; i < 5; i++) {
      final interval = int.tryParse(_intervalControllers[i].text.trim());
      if (interval == null || interval <= 0) {
        isValid = false;
        break;
      }
      intervals.add(interval);
    }

    if (!isValid || _lastPeriodDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Semua data harus diisi dengan angka positif.')),
      );
      return;
    }

    // Convert to HaidRecord objects
    List<HaidRecord> records = [];
    DateTime currentDate = _lastPeriodDate!;

    for (var i = 0; i < 6; i++) {
      final startDate = currentDate;
      final endDate = startDate.add(Duration(days: durations[i] - 1));

      records.add(
        HaidRecord(
          startDate: startDate,
          endDate: endDate,
          durationDays: durations[i],
          notes: 'Riwayat haid ke-${i + 1} (onboarding)',
        ),
      );

      if (i < 5) {
        currentDate = endDate.add(Duration(days: intervals[i]));
      }
    }

    // Save to Hive
    final box = await Hive.openBox<HaidRecord>('haidRecords');
    for (var record in records) {
      await box.add(record);
    }

    // Set prediction status as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prediction_completed', true);

    // Navigate to home page
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat 6 Haid Sebelumnya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          const Divider(),
          const SizedBox(height: 10),

          // Instructions
          const Text(
            'Masukkan durasi haid dan jarak suci secara berurutan:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // Sequential inputs: Haid 1 → Suci 1-2 → Haid 2 → Suci 2-3 → etc.
                // Haid 1
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _durationControllers[0],
                    decoration: InputDecoration(
                      labelText: '1. Durasi Haid ke-1 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Suci 1-2
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _intervalControllers[0],
                    decoration: InputDecoration(
                      labelText:
                          '2. Jarak Suci antar Haid ke-1 dan ke-2 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Haid 2
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _durationControllers[1],
                    decoration: InputDecoration(
                      labelText: '3. Durasi Haid ke-2 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Suci 2-3
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _intervalControllers[1],
                    decoration: InputDecoration(
                      labelText:
                          '4. Jarak Suci antar Haid ke-2 dan ke-3 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Haid 3
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _durationControllers[2],
                    decoration: InputDecoration(
                      labelText: '5. Durasi Haid ke-3 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Suci 3-4
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _intervalControllers[2],
                    decoration: InputDecoration(
                      labelText:
                          '6. Jarak Suci antar Haid ke-3 dan ke-4 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Haid 4
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _durationControllers[3],
                    decoration: InputDecoration(
                      labelText: '7. Durasi Haid ke-4 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Suci 4-5
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _intervalControllers[3],
                    decoration: InputDecoration(
                      labelText:
                          '8. Jarak Suci antar Haid ke-4 dan ke-5 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Haid 5
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _durationControllers[4],
                    decoration: InputDecoration(
                      labelText: '9. Durasi Haid ke-5 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Suci 5-6
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _intervalControllers[4],
                    decoration: InputDecoration(
                      labelText:
                          '10. Jarak Suci antar Haid ke-5 dan ke-6 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Haid 6
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _durationControllers[5],
                    decoration: InputDecoration(
                      labelText: '11. Durasi Haid ke-6 (hari)',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: secondaryColor, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 20),

                // Last period date picker
                ElevatedButton.icon(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      helpText: 'Tanggal Terakhir Haid ke-6',
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _lastPeriodDate = pickedDate;
                      });
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _lastPeriodDate == null
                        ? 'Pilih Tanggal Terakhir Haid ke-6'
                        : 'Tanggal: ${_lastPeriodDate!.toLocal().toString().split(' ')[0]}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Save button
          ElevatedButton.icon(
            onPressed: _saveRecordsAndNavigate,
            icon: const Icon(Icons.save, size: 20),
            label: const Text(
              'Simpan dan Lanjutkan',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }
}
