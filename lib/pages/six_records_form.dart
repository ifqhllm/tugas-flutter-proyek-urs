import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<TextEditingController> _cycleControllers =
      List.generate(6, (index) => TextEditingController());

  Future<void> _saveRecordsAndNavigate() async {
    List<int> cycleDurations = [];

    for (var i = 0; i < 6; i++) {
      final duration = int.tryParse(_cycleControllers[i].text.trim());
      if (duration == null || duration <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Siklus ke-${i + 1} harus diisi dengan angka positif.'),
            ),
          );
        }
        return;
      }
      cycleDurations.add(duration);
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('cycle_1', cycleDurations[0]);
    await prefs.setInt('cycle_2', cycleDurations[1]);
    await prefs.setInt('cycle_3', cycleDurations[2]);
    await prefs.setInt('cycle_4', cycleDurations[3]);
    await prefs.setInt('cycle_5', cycleDurations[4]);
    await prefs.setInt('cycle_6', cycleDurations[5]);

    // Save the date when user input the 6 cycles
    await prefs.setInt(
        'cycles_input_date', DateTime.now().millisecondsSinceEpoch);

    await prefs.setBool('prediction_completed', true);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Durasi 6 Siklus Sebelumnya',
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
          const Divider(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFFF9A825), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Catatan: 1 siklus terdiri dari masa haid DAN masa suci (bukan hanya masa haid saja).',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _cycleControllers[0],
                    decoration: InputDecoration(
                      labelText: 'Durasi Siklus ke-1 (hari)',
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _cycleControllers[1],
                    decoration: InputDecoration(
                      labelText: 'Durasi Siklus ke-2 (hari)',
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _cycleControllers[2],
                    decoration: InputDecoration(
                      labelText: 'Durasi Siklus ke-3 (hari)',
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _cycleControllers[3],
                    decoration: InputDecoration(
                      labelText: 'Durasi Siklus ke-4 (hari)',
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _cycleControllers[4],
                    decoration: InputDecoration(
                      labelText: 'Durasi Siklus ke-5 (hari)',
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: _cycleControllers[5],
                    decoration: InputDecoration(
                      labelText: 'Durasi Siklus ke-6 (hari)',
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
              ],
            ),
          ),
          const SizedBox(height: 20),
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
