import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/fikih_service.dart';
import 'services/haid_service.dart';
import 'services/notification_service.dart';
import 'models/haid_record.dart';
import 'models/blood_event.dart';
import 'constants/colors.dart';
import 'widgets/background_widget.dart';
import 'pages/calendar_page.dart';
import 'pages/settings_page.dart';
import 'pages/cycle_tracker_page.dart';
import 'pages/six_records_form.dart';
import 'pages/kebiasaan_haid_dialog.dart';

final FikihService fikihService = FikihService();

const String userNameKey = 'user_name';

// --- Onboarding & Theme Configuration ---

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedStatus;

  Future<void> _saveNameAndNavigate() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && _selectedStatus != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userNameKey, name);
      await prefs.setString('haid_status', _selectedStatus!);

      if (_selectedStatus == 'Baru Mengalami') {
        // Directly go to home page
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MainScreen(),
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
        }
      } else {
        // Show prediction question dialog
        _showPredictionQuestionDialog(context, name);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nama dan status haid tidak boleh kosong.')),
      );
    }
  }

  void _showPredictionQuestionDialog(BuildContext parentContext, String name) {
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Apakah anda ingin memprediksi haid berikutnya?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Go to home page, set prediction status as not started
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setBool('prediction_skipped', true);
                });
                // Tampilkan dialog kebiasaan haid
                showKebiasaanHaidDialog(parentContext, isFromMainScreen: false);
              },
              child: const Text('Lewati'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Show 6 records form as bottom sheet
                showSixRecordsBottomSheet(parentContext, name, isFromMainScreen: false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: textColor,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundWidget(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.all(32.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo kecil di Onboarding dibuat melingkar dan menyatu dengan background
                Center(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const RadialGradient(
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.8, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
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
                  'Masukkan nama panggilanmu dan status haid untuk memulai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  key: const ValueKey('name-input'),
                  controller: _nameController,
                  maxLength: 10,
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
                const Text(
                  'Status Haid:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Baru Mengalami Haid'),
                        value: 'Baru Mengalami',
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Sudah Biasa Haid'),
                        value: 'Sudah Biasa',
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),
                  ],
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
          ),
        ),
      ),
    );
  }
}

// --- Komponen Utama Aplikasi (MainScreen) ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(BloodEventAdapter()); // TypeId 1
  Hive.registerAdapter(HaidRecordAdapter()); // TypeId 0

  try {
    await Hive.openBox<HaidRecord>('haidRecords');
    // Initialize notifications
    await NotificationService().init();
    await NotificationService().scheduleAllNotifications();

    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString(userNameKey);

    initializeDateFormatting('id_ID', null).then((_) {
      runApp(AlHeedhApp(hasUser: userName != null && userName.isNotEmpty));
    });
  } catch (e) {
    await initializeDateFormatting('id_ID', null);
    print('🚨 FATAL INIT ERROR: $e');
    runApp(const AlHeedhApp(hasUser: false));
  }
}

class AlHeedhApp extends StatelessWidget {
  final bool hasUser;
  const AlHeedhApp({super.key, required this.hasUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      title: 'Aplikasi Al_Heedh: Solusi Cerdas Muslimah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: hasUser ? const MainScreen() : const NameInputScreen(),
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
  DateTime? _predictedDate;
  List<HaidRecord> _allRecords = [];
  bool _isDataLoaded = false;

  late List<Widget> _widgetOptions = [
    CycleTrackerPage(
      userName: 'Memuat...',
      onDataChanged: _loadInitialData,
      onPredictionCompleted: _handleReloadData,
    ),
    const Center(child: CircularProgressIndicator()),
    SettingsPage(onDataChanged: _handleReloadData),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialDataWithDelay();
  }

  Future<void> _loadInitialDataWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    await _loadInitialData();
  }

  Future<void> _handleReloadData() async {
    if (mounted) {
      setState(() {
        _isDataLoaded = false;
      });
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    String userName = 'Pengguna';
    try {
      // Muat Nama Pengguna
      final prefs = await SharedPreferences.getInstance();
      userName = prefs.getString(userNameKey) ?? 'Pengguna'; // Ganti _userNameKey

      // Muat Data Siklus Awal
      final allRecords = await haidService.getAllRecords();
      final predictedDate =
          await fikihService.getNextPredictedStartDate(allRecords);

      if (mounted) {
        setState(() {
          _userName = userName;
          _predictedDate = predictedDate;
          _allRecords = allRecords;
          _isDataLoaded = true;

          // Inisialisasi widget options setelah data dimuat
          _widgetOptions = <Widget>[
            CycleTrackerPage(
              userName: _userName,
              onDataChanged: _loadInitialData,
              onPredictionCompleted: _handleReloadData,
            ),
            CalendarPage(records: _allRecords, predictedDate: _predictedDate),
            SettingsPage(onDataChanged: _handleReloadData),
          ];
        });
      }
    } catch (e) {
      debugPrint("Error saat memuat data awal di MainScreen: $e");
      if (mounted) {
        setState(() {
          _userName = userName;
          _isDataLoaded =
              true; // Tetap tampilkan UI walau ada error, untuk debug
          _widgetOptions = <Widget>[
            CycleTrackerPage(
              userName: _userName,
              onDataChanged: _loadInitialData,
              onPredictionCompleted: _handleReloadData,
            ),
            const CalendarPage(records: [], predictedDate: null),
            SettingsPage(onDataChanged: _handleReloadData),
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
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: BackgroundWidget(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) {
                          return const RadialGradient(
                            colors: [Colors.black, Colors.transparent],
                            stops: [0.8, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/Logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.mosque,
                                    size: 280, color: primaryColor);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'AL-HEEDH',
                        style: TextStyle(
                          fontSize: 28,
                          color: secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Solusi Cerdas Muslimah',
                        style: TextStyle(
                          fontSize: 18,
                          color: secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: SizedBox(
                  height: 8,
                  width: 300,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.yellow,
                          Colors.red,
                        ],
                      ).createShader(bounds);
                    },
                    child: const LinearProgressIndicator(
                      value: null,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              backgroundColor: const Color(0xFFFF69B4),
              elevation: 4,
              centerTitle: true,
            ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Kalender'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: secondaryColor,
        unselectedItemColor: primaryColor.withValues(alpha: 179),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}
