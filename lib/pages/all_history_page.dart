import 'package:flutter/material.dart';
import '../models/haid_record.dart';
import '../services/fikih_service.dart';
import '../services/haid_service.dart';
import '../constants/colors.dart';
import '../widgets/background_widget.dart';
import 'hukum_haid_terputus_page.dart';
import 'masa_keluarnya_darah_haid_page.dart';

class AllHistoryPage extends StatefulWidget {
  final List<HaidRecord> records;
  final String haidStatus;
  final int kebiasaanHaid;
  final VoidCallback onDelete;

  const AllHistoryPage({
    super.key,
    required this.records,
    required this.haidStatus,
    required this.kebiasaanHaid,
    required this.onDelete,
  });

  @override
  State<AllHistoryPage> createState() => _AllHistoryPageState();
}

class _AllHistoryPageState extends State<AllHistoryPage> {
  final FikihService _fikihService = FikihService();
  late List<HaidRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = List.from(widget.records);
  }

  Future<void> _refreshRecords() async {
    final updated = await haidService.getAllRecords();
    setState(() {
      _records = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Semua Riwayat Siklus',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF69B4),
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BackgroundWidget(
        child: _records.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada riwayat siklus.',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  // Tampilkan dalam urutan terbaru (reversed)
                  final record = _records.reversed.toList()[index];
                  final start =
                      '${record.startDate.day}/${record.startDate.month}/${record.startDate.year}';
                  final end = record.endDate != null
                      ? '${record.endDate!.day}/${record.endDate!.month}/${record.endDate!.year}'
                      : 'Sedang berlangsung';

                  final endDateTime = record.endDate ?? DateTime.now();
                  final loggedHours = endDateTime.difference(record.startDate).inHours;
                  final progressPercentage = (loggedHours / 24.0).clamp(0.0, 1.0);

                  Color progressColor;
                  List<Color> gradientColors;
                  double actualProgressPercentage = progressPercentage;
                  String statusText;

                  if (record.endDate != null) {
                    final statusDetail = _fikihService.getDetailedHukumStatus(
                      record.endDate!,
                      _records,
                      haidStatus: widget.haidStatus,
                      kebiasaanHaid: widget.kebiasaanHaid,
                    );
                    final statusType = statusDetail['type'] as String;
                    statusText = statusDetail['status'] as String? ?? 'SUCI';

                    if (statusType == 'HAID') {
                      progressColor = Colors.green;
                      gradientColors = [Colors.green, Colors.green];
                    } else if (statusType == 'ISTIHADAH_SHORT' ||
                        statusType == 'ISTIHADAH_LONG') {
                      progressColor = Colors.green;
                      gradientColors = [Colors.green, Colors.green];
                    } else {
                      progressColor = Colors.red;
                      gradientColors = [Colors.red, Colors.red];
                    }
                  } else {
                    final today = DateTime.now();
                    final statusDetail = _fikihService.getDetailedHukumStatus(
                      today,
                      _records,
                      haidStatus: widget.haidStatus,
                      kebiasaanHaid: widget.kebiasaanHaid,
                    );
                    final statusType = statusDetail['type'] as String;
                    statusText = statusDetail['status'] as String? ?? 'HAID SEMENTARA';

                    if (statusType == 'HAID_ACTIVE') {
                      progressColor = Colors.orange;
                      gradientColors = [Colors.yellow, Colors.red];
                    } else {
                      progressColor = Colors.green;
                      gradientColors = [Colors.green, Colors.green];
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 3,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Siklus: $start - $end',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: primaryColor),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hapus Siklus'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus seluruh siklus ini? Semua data terkait akan hilang.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await haidService.deleteCycle(record);
                                  widget.onDelete();
                                  await _refreshRecords();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: actualProgressPercentage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: gradientColors,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(actualProgressPercentage * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: progressColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Durasi: $loggedHours jam tercatat',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Status Periode ini : $statusText'),
                            Builder(
                              builder: (context) {
                                final statusDetail = _fikihService.getDetailedHukumStatus(
                                  record.endDate ?? DateTime.now(),
                                  _records,
                                  haidStatus: widget.haidStatus,
                                  kebiasaanHaid: widget.kebiasaanHaid,
                                );
                                final message = statusDetail['message'] as String?;
                                final showButton = statusDetail['showInterruptedHaidButton'] == true;
                                final showMasaHaidButton = statusDetail['showMasaHaidButton'] == true;

                                if ((message != null && message.isNotEmpty) || showButton || showMasaHaidButton) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (message != null && message.isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.amber.shade200, width: 1),
                                          ),
                                          child: Text(
                                            message,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      if (showButton) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const HukumHaidTerputusPage(),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.menu_book, color: Colors.white, size: 16),
                                            label: const Text(
                                              'Hukum Haid Yang Terputus',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: secondaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (showMasaHaidButton) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const MasaKeluarnyaDarahHaidPage(),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.menu_book, color: Colors.white, size: 16),
                                            label: const Text(
                                              'Masa Keluarnya Darah Haid',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: secondaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
