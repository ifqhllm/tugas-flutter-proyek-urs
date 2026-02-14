import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/fikih_service.dart';
import '../services/haid_service.dart';
import '../services/notification_service.dart';
import '../models/haid_record.dart';
import '../constants/colors.dart';
import '../widgets/background_widget.dart';
import 'wirid_and_dua_page.dart';
import 'articles_page.dart' as articles;
import 'qa_page.dart';
import 'six_records_form.dart';

final FikihService fikihService = FikihService();
final HaidService haidService = HaidService();

class CycleTrackerPage extends StatefulWidget {
  final String userName;
  final Future<void> Function()? onDataChanged;

  const CycleTrackerPage({
    super.key,
    required this.userName,
    this.onDataChanged,
  });

  @override
  State<CycleTrackerPage> createState() => _CycleTrackerPageState();
}

class _CycleTrackerPageState extends State<CycleTrackerPage> {
  // Deklarasi State
  dynamic _currentRecord;
  bool _isLoading = true;
  String _hukumStatus = 'Memuat status...';
  DateTime? _nextPredictedDate;
  List<HaidRecord> _allRecords = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentRecord();
  }

  Future<Map<String, dynamic>> _getPredictionPanelData() async {
    final prefs = await SharedPreferences.getInstance();
    final haidStatus = prefs.getString('haid_status') ?? 'Sudah Biasa';
    final predictionCompleted = prefs.getBool('prediction_completed') ?? false;
    final predictionSkipped = prefs.getBool('prediction_skipped') ?? false;
    final hasActiveRecord =
        _currentRecord != null && _currentRecord.endDate == null;

    return {
      'haidStatus': haidStatus,
      'predictionCompleted': predictionCompleted,
      'predictionSkipped': predictionSkipped,
      'hasActiveRecord': hasActiveRecord,
    };
  }

  Future<void> _loadCurrentRecord() async {
    try {
      final allRecords = await haidService.getAllRecords();
      final current = await haidService.getCurrentActiveRecord();
      final nextPredictedDate =
          await fikihService.getNextPredictedStartDate(allRecords);

      if (mounted) {
        setState(() {
          _currentRecord = current;
          _allRecords = allRecords;

          // Logika untuk status Home Page
          if (current != null && current.endDate == null) {
            // Jika ada record aktif TAPI belum selesai (endDate == null)
            _hukumStatus = 'HAID SEMENTARA';
          } else {
            // Jika tidak ada record aktif atau sudah selesai, hitung status final hari ini
            _hukumStatus =
                fikihService.getHukumStatus(DateTime.now(), allRecords);
          }

          _nextPredictedDate = nextPredictedDate;
        });
      }
    } catch (e) {
      debugPrint("Error saat memuat data siklus: $e");
      if (mounted) {
        setState(() {
          _hukumStatus = 'ERROR: Database Gagal Dimuat. (Cek Build Runner!)';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<DateTime?> _selectDateAndTime(BuildContext context, String title,
      {bool allowFuture = false}) async {
    // 1. Pilih Tanggal (Date Picker)
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: allowFuture
          ? DateTime.now().add(const Duration(days: 30))
          : DateTime.now(),
      helpText: title,
      fieldLabelText: 'Pilih Tanggal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return null;
    if (date == null) return null;

    // 2. Pilih Jam (Time Picker)
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Pilih Jam',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return null;
    if (time == null) {
      return null;
    }

    // Gabungkan Tanggal dan Jam
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

// 1. Fungsi untuk MEMULAI siklus (Hanya mencatat start date)
  Future<void> _startHaidCycle() async {
    if (_isLoading) return;

    final selectedDateTime = await _selectDateAndTime(
      context,
      'Tanggal Mulai Haid',
      allowFuture: false,
    );
    if (selectedDateTime == null) return;

    setState(() => _isLoading = true);

    try {
      // Catat tanggal mulai Haid (Memulai siklus)
      await haidService.startHaid(selectedDateTime);

      // Schedule daily recording reminder
      await NotificationService().scheduleDailyRecordingReminder();

      await _loadCurrentRecord();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Pencatatan Haid Dimulai! Status: HAID SEMENTARA.')),
        );
      }
    } catch (e) {
      debugPrint("Error saat memulai haid: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai pencatatan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// 2. Fungsi untuk MENCATAT DARAH HARIAN/JAM-AN (Log Event)
  Future<void> _logBloodEvent() async {
    if (_isLoading) return;

    final selectedDateTime = await _selectDateAndTime(
      context,
      'Waktu Pencatatan Darah Saat Ini',
      allowFuture: true,
    );
    if (selectedDateTime == null) return;

    setState(() => _isLoading = true);

    try {
      // ASUMSI: Method ini ada di HaidService untuk log event
      await haidService.logBloodEvent(selectedDateTime, 'CONTINUE_FLOW');

      await _loadCurrentRecord();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pencatatan darah harian/jam berhasil disimpan.')),
        );
      }
    } catch (e) {
      debugPrint("Error saat mencatat status darah: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mencatat status darah: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// 3. Fungsi untuk MENGAKHIRI SIKLUS (Memicu Perhitungan Fiqh Final)
  Future<void> _endHaidFinal() async {
    if (_isLoading) return;

    final selectedDateTime = await _selectDateAndTime(
      context,
      'Waktu Darah Benar-benar Berhenti',
      allowFuture: true,
    );
    if (selectedDateTime == null) return;

    setState(() => _isLoading = true);

    try {
      // Panggil service untuk END FINAL (ini akan mengisi endDate dan memicu kalkulasi)
      await haidService.endHaidFinal(selectedDateTime);

      // Cancel recording reminder
      await NotificationService().cancelRecordingReminder();

      // Muat ulang data & trigger MainScreen update (untuk Calendar)
      await _loadCurrentRecord();
      await widget.onDataChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Siklus diakhiri. Status Hukum Final dihitung.')),
        );
      }
    } catch (e) {
      debugPrint("Error saat mengakhiri siklus: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengakhiri siklus: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// FUNGSI BUILD & UI =================================================
  Widget _buildNavButton(
      BuildContext context, String assetPath, String label, Widget page) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.favorite_border,
                      size: 40, color: primaryColor);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHaidActive =
        _currentRecord != null && _currentRecord!.endDate == null;

    return BackgroundWidget(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // --- Header Salam ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.female,
                      color: secondaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Assalamualaikum, ${widget.userName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.female,
                      color: secondaryColor,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Apakah Ada Catatan Hari ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // --- Status Hukum Hari Ini Card ---
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Status Hukum Haid Periode Ini:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isLoading
                            ? 'Menghitung...'
                            : _hukumStatus.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _hukumStatus == 'HAID SEMENTARA'
                            ? 'Silakan catat peristiwa darah harian/jam-an. Status final akan dihitung setelah Darah Berhenti.'
                            : _hukumStatus.contains('HAID SELAMA')
                                ? 'Jika Sudah Berhenti Silahkan Melakukan Mandi Wajib.'
                                : _hukumStatus == 'ISTIHADAH KURANG DARI 24 JAM'
                                    ? 'Karena kurang dari 24 jam maka haid anda adalah 1 hari. Silahkan Qadha\' Shalat dan Puasa Jika Ditinggalkan.'
                                    : _hukumStatus ==
                                            'ISTIHADAH LEBIH DARI 15 HARI'
                                        ? 'Haid Anda Adalah 15 hari. Selebihnya Adalah Istihadah.'
                                        : 'Jika Anda Suci maka wajib qodho sholat. jika istihadah silahkan baca artikel mengenai hukumnya!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // --- MENU CEPAT (3 Tombol Gambar) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavButton(context, 'assets/images/Wirid & Doa.png',
                          'Wirid & Doa', const WiridAndDuaPage()),
                      _buildNavButton(context, 'assets/images/Article.png',
                          'Artikel', const articles.DuaPage()),
                      _buildNavButton(context, 'assets/images/Tanya Jawab.png',
                          'Tanya Jawab', const QAPage()),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // --- Tombol Pencatatan Siklus (Dipecah) ---
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                else if (isHaidActive)
                  // KONDISI 1: Siklus sedang aktif (HAID SEMENTARA)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol 1A: Mencatat Darah Masih Keluar (Event Harian)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _logBloodEvent, // PANGGIL FUNGSI LOG EVENT
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Catat darah hari/jam ini',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Tombol 1B: Akhir Final (Memicu Perhitungan Fiqh)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _endHaidFinal, // PANGGIL FUNGSI END FINAL
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Akhiri haid',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // KONDISI 2: Siklus tidak aktif atau sudah selesai
                  ElevatedButton(
                    onPressed: _startHaidCycle, // PANGGIL FUNGSI START
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text(
                          'CATAT HAID SEKARANG',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // --- Prediksi Siklus Card ---
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.pink.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: secondaryColor.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        spreadRadius: -2,
                        blurRadius: 5,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _getPredictionPanelData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        );
                      }

                      final data = snapshot.data;
                      final haidStatus = data?['haidStatus'] ?? 'Sudah Biasa';
                      final predictionCompleted =
                          data?['predictionCompleted'] ?? false;
                      final predictionSkipped =
                          data?['predictionSkipped'] ?? false;
                      final hasActiveRecord = data?['hasActiveRecord'] ?? false;

                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'Prediksi siklus berikutnya',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (haidStatus == 'Baru Mengalami')
                            const Text(
                              'Prediksi belum tersedia. Silakan catat haid pertama Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (haidStatus == 'Sudah Biasa' && predictionSkipped)
                            Column(
                              children: [
                                const Text(
                                  'Prediksi belum tersedia. Silahkan catat 6 riwayat sebelumnya',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showSixRecordsBottomSheet(
                                        context, widget.userName);
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Catat'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: secondaryColor,
                                    foregroundColor: textColor,
                                  ),
                                ),
                              ],
                            ),
                          if (haidStatus == 'Sudah Biasa' &&
                              predictionCompleted &&
                              !hasActiveRecord)
                            const Text(
                              'Prediksi akan tersedia jika anda sudah mulai mencatat haid baru.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (haidStatus == 'Sudah Biasa' &&
                              predictionCompleted &&
                              hasActiveRecord &&
                              _nextPredictedDate != null)
                            Text(
                              'Prediksi Haid: ${_nextPredictedDate!.day}/${_nextPredictedDate!.month}/${_nextPredictedDate!.year}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),

                // --- RIWAYAT SIKLUS ---
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.purple.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: primaryColor.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        spreadRadius: -2,
                        blurRadius: 5,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'RIWAYAT SIKLUS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (_allRecords.isEmpty)
                        const Text(
                          'Belum ada riwayat siklus.',
                          style: TextStyle(color: textColor),
                        )
                      else
                        ..._allRecords.reversed.take(5).map((record) {
                          final start =
                              '${record.startDate.day}/${record.startDate.month}/${record.startDate.year}';
                          final end = record.endDate != null
                              ? '${record.endDate!.day}/${record.endDate!.month}/${record.endDate!.year}'
                              : 'Sedang berlangsung';

                          // Calculate duration and progress based on logged blood events
                          final loggedHours = record.bloodEvents.length;
                          final progressPercentage =
                              (loggedHours / 24.0).clamp(0.0, 1.0);

                          // Determine color and progress logic based on detailed status
                          Color progressColor;
                          List<Color> gradientColors;
                          double actualProgressPercentage = progressPercentage;

                          String? hukumStatus;

                          if (record.endDate != null) {
                            // Completed cycle - get detailed status
                            final statusDetail =
                                fikihService.getDetailedHukumStatus(
                                    record.endDate!, _allRecords);
                            hukumStatus = statusDetail['status'] as String;
                            final statusType = statusDetail['type'] as String;
                            final totalDays = record.endDate!
                                    .difference(record.startDate)
                                    .inDays +
                                1;

                            if (statusType == 'HAID') {
                              // Scenario 1: All days are haid - solid green
                              progressColor = Colors.green;
                              gradientColors = [Colors.green, Colors.green];
                            } else if (statusType == 'ISTIHADAH_SHORT') {
                              // Scenario 2: 1 day haid (red) + rest istihadah (green)
                              progressColor = Colors.green;
                              gradientColors = [Colors.red, Colors.green];
                              // Progress shows: 1 day red portion, rest green
                              actualProgressPercentage =
                                  totalDays > 1 ? (1 / totalDays) : 1.0;
                            } else if (statusType == 'ISTIHADAH_LONG') {
                              // Scenario 3: 15 days haid (red) + rest istihadah (green)
                              progressColor = Colors.green;
                              gradientColors = [Colors.red, Colors.green];
                              // Progress shows: 15 days red portion, rest green
                              actualProgressPercentage =
                                  totalDays > 15 ? (15 / totalDays) : 1.0;
                            } else {
                              // Fallback - all red (istihadah)
                              progressColor = Colors.red;
                              gradientColors = [Colors.red, Colors.red];
                            }
                          } else {
                            // Ongoing cycle - yellow to red gradient
                            progressColor = Colors.orange;
                            gradientColors = [Colors.yellow, Colors.red];
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                  width: 1),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      icon: const Icon(Icons.delete,
                                          size: 20, color: primaryColor),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Hapus Siklus'),
                                            content: const Text(
                                                'Apakah Anda yakin ingin menghapus seluruh siklus ini? Semua data terkait akan hilang.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await haidService.deleteCycle(record);
                                          await _loadCurrentRecord();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress Indicator
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor:
                                                  actualProgressPercentage,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: gradientColors,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
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
                                    const SizedBox(height: 4),
                                    Text(
                                      'Durasi: $loggedHours jam tercatat (Target Minimal Dalam 1 Haid: 24 Jam)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    // Status message for completed cycles
                                    if (record.endDate != null &&
                                        hukumStatus != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        hukumStatus.contains('ISTIHADAH')
                                            ? hukumStatus.contains('15')
                                                ? 'Status: Istihaadah (Melebihi 15 hari - Darah tidak dianggap haid)'
                                                : 'Status: Istihaadah (Kurang dari 24 jam - Darah tidak dianggap haid)'
                                            : 'Status: Haid (Sesuai syariat Islam - Ada pengecualian ibadah)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: progressColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Scrollable container for blood events (max 4 recent)
                                Container(
                                  height:
                                      120, // Fixed height for scrollable area
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: record.bloodEvents.reversed
                                            .take(4)
                                            .map((event) {
                                          final eventTime =
                                              '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year} ${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}';
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '$eventTime - ${event.type}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      size: 16,
                                                      color: primaryColor),
                                                  onPressed: () async {
                                                    final confirm =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Hapus Pencatatan'),
                                                        content: const Text(
                                                            'Apakah Anda yakin ingin menghapus pencatatan darah ini?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false),
                                                            child: const Text(
                                                                'Batal'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true),
                                                            child: const Text(
                                                                'Hapus'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      final eventIndex = record
                                                          .bloodEvents
                                                          .indexOf(event);
                                                      await haidService
                                                          .deleteBloodEvent(
                                                              record,
                                                              eventIndex);
                                                      await _loadCurrentRecord();
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
