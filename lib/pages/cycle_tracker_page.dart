import 'package:flutter/material.dart';
import '../services/fikih_service.dart';
import '../services/haid_service.dart';
import '../models/haid_record.dart';
import '../constants/colors.dart';
import 'prayer_times_page.dart';
import 'wirid_and_dua_page.dart';
import 'articles_page.dart' as articles;

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

  Future<void> _loadCurrentRecord() async {
    try {
      final allRecords = await haidService.getAllRecords();
      final current = await haidService.getCurrentActiveRecord();

      if (mounted) {
        setState(() {
          _currentRecord = current;
          _allRecords = allRecords;

          // Logika baru untuk status Home Page
          if (current != null && current.endDate == null) {
            // Jika ada record aktif TAPI belum selesai (endDate == null)
            final durationHours = DateTime.now().difference(current.startDate).inHours;
            if (durationHours > 360) { // 15 hari
              _hukumStatus = 'ISTIHADAH (Melebihi 15 Hari)';
            } else {
              _hukumStatus = 'HAID SEMENTARA';
            }
          } else {
            // Jika tidak ada record aktif atau sudah selesai, hitung status final hari ini
            _hukumStatus =
                fikihService.getHukumStatus(DateTime.now(), allRecords);
          }

          _nextPredictedDate =
              fikihService.getNextPredictedStartDate(allRecords);
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

  Future<DateTime?> _selectDateAndTime(
      BuildContext context, String title) async {
    // 1. Pilih Tanggal (Date Picker)
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
    );
    if (selectedDateTime == null) return;

    setState(() => _isLoading = true);

    try {
      // Catat tanggal mulai Haid (Memulai siklus)
      await haidService.startHaid(selectedDateTime);

      await _loadCurrentRecord();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pencatatan Haid Dimulai! Status: HAID SEMENTARA.')),
      );
    } catch (e) {
      debugPrint("Error saat memulai haid: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memulai pencatatan: ${e.toString()}')),
      );
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
    );
    if (selectedDateTime == null) return;

    setState(() => _isLoading = true);

    try {
      // ASUMSI: Method ini ada di HaidService untuk log event
      await haidService.logBloodEvent(selectedDateTime, 'CONTINUE_FLOW');

      await _loadCurrentRecord();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pencatatan darah harian/jam-an berhasil disimpan.')),
      );
    } catch (e) {
      debugPrint("Error saat mencatat status darah: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencatat status darah: ${e.toString()}')),
      );
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
    );
    if (selectedDateTime == null) return;

    setState(() => _isLoading = true);

    try {
      // Panggil service untuk END FINAL (ini akan mengisi endDate dan memicu kalkulasi)
      await haidService.endHaidFinal(selectedDateTime);

      // Muat ulang data & trigger MainScreen update (untuk Calendar)
      await _loadCurrentRecord();
      await widget.onDataChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Siklus diakhiri. Status Hukum Final dihitung.')),
      );
    } catch (e) {
      debugPrint("Error saat mengakhiri siklus: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengakhiri siklus: ${e.toString()}')),
      );
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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => page));
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.favorite_border,
                    size: 40, color: primaryColor);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHaidActive =
        _currentRecord != null && _currentRecord!.endDate == null;
    final primaryBgColor = primaryColor;

    return SafeArea(
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
                    Icons.favorite,
                    color: primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assalamualaikum, ${widget.userName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.favorite,
                    color: primaryColor,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Bagaimana keadaan Anda hari ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 25),

              // --- Status Hukum Hari Ini Card ---
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: primaryBgColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBgColor.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'STATUS HUKUM HAID PERIODE INI',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLoading ? 'Menghitung...' : _hukumStatus.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _hukumStatus == 'HAID SEMENTARA'
                          ? 'Silakan catat peristiwa darah harian/jam-an. Status final akan dihitung setelah Darah Berhenti.'
                          : _hukumStatus == 'HAID' ||
                                  _hukumStatus == 'ISTIHADAH'
                              ? 'Ada pengecualian ibadah.'
                              : 'Jika Anda Suci maka wajib qodho sholat. jika istihadah silahkan baca artikel mengenai hukumnya!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton(context, 'assets/images/jadwal sholat.jpg',
                        'Jadwal Shalat', const PrayerTimesPage()),
                    _buildNavButton(context, 'assets/images/wirid dan doa.jpg',
                        'Wirid & Doa', const WiridAndDuaPage()),
                    _buildNavButton(context, 'assets/images/artikel.jpg',
                        'Artikel', const articles.DuaPage()),
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
                          backgroundColor: primaryColor.withOpacity(0.8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                        ),
                        child: const Text(
                          'CATAT DARAH HARI INI/JAM INI',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tombol 1B: Akhir Final (Memicu Perhitungan Fiqh)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _endHaidFinal, // PANGGIL FUNGSI END FINAL
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: const Text(
                          'DARAH SUDAH BERHENTI KELUAR',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Text(
                    'CATAT HAID SEKARANG',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),

              const SizedBox(height: 20),

              // --- Prediksi Siklus Card ---
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: primaryBgColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PREDIKSI SIKLUS BERIKUTNYA',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoading
                          ? 'Memuat data prediksi...'
                          : _nextPredictedDate == null
                              ? 'Data kurang untuk prediksi akurat.'
                              : 'Prediksi Haid: ${_nextPredictedDate!.day}/${_nextPredictedDate!.month}/${_nextPredictedDate!.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- RIWAYAT SIKLUS ---
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RIWAYAT SIKLUS',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_allRecords.isEmpty)
                      const Text(
                        'Belum ada riwayat siklus.',
                        style: TextStyle(color: textColor),
                      )
                    else
                      ..._allRecords.reversed.take(5).map((record) {
                        final start = '${record.startDate.day}/${record.startDate.month}/${record.startDate.year}';
                        final end = record.endDate != null
                            ? '${record.endDate!.day}/${record.endDate!.month}/${record.endDate!.year}'
                            : 'Sedang berlangsung';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Siklus: $start - $end',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...record.bloodEvents.map((event) {
                                final eventTime = '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year} ${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Hapus Pencatatan'),
                                              content: const Text('Apakah Anda yakin ingin menghapus pencatatan darah ini?'),
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
                                            final eventIndex = record.bloodEvents.indexOf(event);
                                            await haidService.deleteBloodEvent(record, eventIndex);
                                            await _loadCurrentRecord();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
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
    );
  }
}