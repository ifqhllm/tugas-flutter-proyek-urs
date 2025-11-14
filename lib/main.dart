import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'services/fikih_service.dart';
import 'services/haid_service.dart';
import 'models/haid_record.dart';
import 'constants/colors.dart';
import 'pages/calendar_page.dart';
import 'pages/settings_page.dart';
import 'pages/articles_page.dart' as articles;
import 'pages/wirid_and_dua_page.dart';

final FikihService fikihService = FikihService();
final HaidService haidService = HaidService();

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  bool _isLoading = true;
  String _locationName = '';
  Map<String, String> _prayerTimes = {};
  String _nextPrayer = '';
  Duration _timeUntilNextPrayer = Duration.zero;
  Timer? _countdownTimer;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePrayerTimes();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializePrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage =
                'Izin lokasi diperlukan untuk mendapatkan jadwal salat.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get location name
      final locationResponse = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10&addressdetails=1',
        ),
      );

      if (locationResponse.statusCode == 200) {
        final locationData = json.decode(locationResponse.body);
        final address = locationData['address'] ?? {};
        final city =
            address['city'] ?? address['town'] ?? address['village'] ?? '';
        final country = address['country'] ?? '';
        _locationName = city.isNotEmpty ? '$city, $country' : country;
      } else {
        _locationName =
            '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      }

      // Fetch prayer times from Aladhan API (Shafi'i method = 1)
      final now = DateTime.now();
      final prayerResponse = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timings/${now.millisecondsSinceEpoch ~/ 1000}?latitude=${position.latitude}&longitude=${position.longitude}&method=1',
        ),
      );

      if (prayerResponse.statusCode == 200) {
        final prayerData = json.decode(prayerResponse.body);
        final timings = prayerData['data']['timings'] as Map<String, dynamic>;

        _prayerTimes = {
          'Imsak': timings['Imsak'] ?? '',
          'Fajar': timings['Fajr'] ?? '',
          'Terbit': timings['Sunrise'] ?? '',
          'Dhuhur': timings['Dhuhr'] ?? '',
          'Ashar': timings['Asr'] ?? '',
          'Maghrib': timings['Maghrib'] ?? '',
          'Isya': timings['Isha'] ?? '',
        };

        _calculateNextPrayer();
        _startCountdown();
      } else {
        setState(() {
          _errorMessage = 'Gagal mengambil data jadwal salat.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final prayerOrder = ['Fajar', 'Dhuhur', 'Ashar', 'Maghrib', 'Isya'];
    DateTime? nextPrayerTime;
    String nextPrayerName = '';

    for (final prayer in prayerOrder) {
      final timeStr = _prayerTimes[prayer];
      if (timeStr != null && timeStr.isNotEmpty) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          final prayerTime = today.add(Duration(hours: hour, minutes: minute));

          if (prayerTime.isAfter(now) &&
              (nextPrayerTime == null || prayerTime.isBefore(nextPrayerTime))) {
            nextPrayerTime = prayerTime;
            nextPrayerName = prayer;
          }
        }
      }
    }

    // If no prayer today, check Dawn tomorrow
    if (nextPrayerTime == null) {
      final dawnStr = _prayerTimes['Fajar'];
      if (dawnStr != null && dawnStr.isNotEmpty) {
        final parts = dawnStr.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          nextPrayerTime = today
              .add(const Duration(days: 1))
              .add(Duration(hours: hour, minutes: minute));
          nextPrayerName = 'Fajar';
        }
      }
    }

    if (nextPrayerTime != null) {
      _nextPrayer = nextPrayerName;
      _timeUntilNextPrayer = nextPrayerTime.difference(now);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeUntilNextPrayer.inSeconds > 0) {
          _timeUntilNextPrayer =
              _timeUntilNextPrayer - const Duration(seconds: 1);
        } else {
          // Recalculate when countdown reaches zero
          _calculateNextPrayer();
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Salat'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializePrayerTimes,
          ),
          IconButton(
            icon: const Icon(Icons.warning),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Peringatan'),
                    content: const Text(
                      'waktu salat dalam aplikasi ini hanya bersifat membantu dan bukan sebagai referensi waktu salat. Untuk memastikan akurasi waktu, silakan periksa perhitungan jadwal salat di daerah Anda.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Mengerti'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text('Mengambil lokasi dan jadwal salat...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializePrayerTimes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Lokasi Anda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _locationName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Next Prayer Countdown
                      if (_nextPrayer.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Waktu Salat Selanjutnya',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _nextPrayer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDuration(_timeUntilNextPrayer),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Prayer Times List
                      const Text(
                        'Jadwal Salat Hari Ini',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      ..._prayerTimes.entries.map((entry) {
                        final isNextPrayer = entry.key == _nextPrayer;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isNextPrayer
                                ? secondaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isNextPrayer
                                  ? secondaryColor
                                  : primaryColor.withOpacity(0.3),
                              width: isNextPrayer ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isNextPrayer
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color:
                                      isNextPrayer ? secondaryColor : textColor,
                                ),
                              ),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isNextPrayer
                                      ? secondaryColor
                                      : primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                      const Text(
                        'Metode Perhitungan: Shafi\'i',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class CycleTrackerPage extends StatefulWidget {
  final String userName;
  final String
      statusHukum; // statusHukum diubah menjadi non-final (tidak perlu, karena direplace di build)

  const CycleTrackerPage({
    super.key,
    required this.userName,
    required this.statusHukum,
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
      if (mounted) {
        (context.findAncestorStateOfType<_MainScreenState>())
            ?._loadInitialData();
      }
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
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
    final primaryBgColor = isHaidActive ? secondaryColor : primaryColor;

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
                        'Prayer Schedules', const PrayerTimesPage()),
                    _buildNavButton(context, 'assets/images/wirid dan doa.jpg',
                        'Wirid', const WiridAndDuaPage()),
                    _buildNavButton(context, 'assets/images/artikel.jpg',
                        'Dua', const articles.DuaPage()),
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
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Onboarding & Theme Configuration ---

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveNameAndNavigate() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          userNameKey, name); // Ganti _userNameKey dengan userNameKey

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo kecil di Onboarding
              Image.asset(
                'assets/images/logo.apk.png',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 30),
              const Text(
                'Selamat Datang di Al-Heedh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Masukkan nama panggilanmu untuk memulai.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Panggilan',
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
                  prefixIcon: const Icon(Icons.person, color: primaryColor),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveNameAndNavigate,
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                label: const Text(
                  'Lanjutkan',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString(userNameKey);

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      if (userName != null && userName.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NameInputScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor, // Pink Muda
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menampilkan logo yang diunggah
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/images/logo.apk.png',
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.mosque,
                        size: 250, color: primaryColor);
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(primaryColor), // Warna Tosca
            ),
            const SizedBox(height: 20),
            const Text(
              'Al-Heedh: Solusi Cerdas Muslimah',
              style: TextStyle(
                fontSize: 20,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Komponen Utama Aplikasi (MainScreen) ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Perbaikan: Inisialisasi Hive dan daftarkan Adapter
  await Hive.initFlutter();

  // HaidRecordAdapter ada di haid_record.g.dart, yang diimpor melalui models/haid_record.dart
  Hive.registerAdapter(HaidRecordAdapter());

  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const AlHeedhApp());
  });
}

class AlHeedhApp extends StatelessWidget {
  const AlHeedhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Al-Heedh: Solusi Cerdas Muslimah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          background: lightBackgroundColor,
          surface: lightBackgroundColor,
        ),
        scaffoldBackgroundColor: lightBackgroundColor,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _userName = 'Pengguna';

  // Data State Global untuk dibagikan ke CalendarPage dan CycleTrackerPage
  String _hukumStatus = 'Memuat...';
  DateTime? _predictedDate;
  List<HaidRecord> _allRecords = [];
  bool _isDataLoaded = false;

  late List<Widget> _widgetOptions = [
    CycleTrackerPage(userName: 'Memuat...', statusHukum: 'Memuat...'),
    const Center(child: CircularProgressIndicator()),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Muat Nama Pengguna
      final prefs = await SharedPreferences.getInstance();
      final userName =
          prefs.getString(userNameKey) ?? 'Pengguna'; // Ganti _userNameKey

      // Muat Data Siklus Awal
      final allRecords = await haidService.getAllRecords();
      final predictedDate = fikihService.getNextPredictedStartDate(allRecords);
      final currentStatus =
          fikihService.getHukumStatus(DateTime.now(), allRecords);

      if (mounted) {
        setState(() {
          _userName = userName;
          _hukumStatus = currentStatus;
          _predictedDate = predictedDate;
          _allRecords = allRecords;
          _isDataLoaded = true;

          // Inisialisasi widget options setelah data dimuat
          _widgetOptions = <Widget>[
            CycleTrackerPage(userName: _userName, statusHukum: _hukumStatus),
            CalendarPage(records: _allRecords, predictedDate: _predictedDate),
            const SettingsPage(),
          ];
        });
      }
    } catch (e) {
      debugPrint("Error saat memuat data awal di MainScreen: $e");
      if (mounted) {
        setState(() {
          _isDataLoaded =
              true; // Tetap tampilkan UI walau ada error, untuk debug
          _hukumStatus = 'ERROR DATA: Cek Build Runner.';
          _widgetOptions = <Widget>[
            CycleTrackerPage(userName: _userName, statusHukum: _hukumStatus),
            const CalendarPage(records: [], predictedDate: null),
            const SettingsPage(),
          ];
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      // Tampilkan loading screen sementara data dimuat
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Perbarui CalendarPage dengan data terbaru
    _widgetOptions[1] =
        CalendarPage(records: _allRecords, predictedDate: _predictedDate);

    return Scaffold(
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(
                _selectedIndex == 1 ? 'Kalender Siklus' : 'Pengaturan',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: primaryColor,
              elevation: 4,
              centerTitle: true,
            ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: secondaryColor,
        unselectedItemColor: primaryColor.withOpacity(0.7),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}
