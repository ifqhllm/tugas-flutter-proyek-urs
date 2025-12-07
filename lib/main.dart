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

final FikihService fikihService = FikihService();
final HaidService haidService = HaidService();

const String userNameKey = 'user_name';

// --- Onboarding & Theme Configuration ---

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _suciHabitsController = TextEditingController();

  Future<void> _saveNameAndNavigate() async {
    final name = _nameController.text.trim();
    final suciHabitsText = _suciHabitsController.text.trim();
    if (name.isNotEmpty && suciHabitsText.isNotEmpty) {
      final suciHabits = int.tryParse(suciHabitsText);
      if (suciHabits != null && suciHabits > 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(userNameKey, name);
        await prefs.setInt('suci_habits', suciHabits);

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Kebiasaan suci harus berupa angka positif.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nama dan kebiasaan suci tidak boleh kosong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundWidget(
        child: SingleChildScrollView(
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
                  'assets/images/Logo.png',
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
                TextField(
                  controller: _suciHabitsController,
                  decoration: InputDecoration(
                    labelText: 'Kebiasaan Suci (hari)',
                    hintText: 'Masukkan rata-rata hari suci dalam siklus',
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

    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      if (userName != null && userName.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const NameInputScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // Menampilkan logo yang diunggah
                    Image.asset(
                      'assets/images/Logo-1.png',
                      height: 250,
                      width: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.mosque,
                            size: 250, color: primaryColor);
                      },
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
            // Indikator progres di bagian bawah
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: SizedBox(
                height: 8,
                width: 300,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
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
    await NotificationService().scheduleDailyRecordingReminder();

    initializeDateFormatting('id_ID', null).then((_) {
      runApp(const AlHeedhApp());
    });
  } catch (e) {
    await initializeDateFormatting('id_ID', null);
    print('🚨 FATAL INIT ERROR: $e');
    runApp(const AlHeedhApp());
  }
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
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.transparent,
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
  DateTime? _predictedDate;
  List<HaidRecord> _allRecords = [];
  bool _isDataLoaded = false;

  late List<Widget> _widgetOptions = [
    CycleTrackerPage(userName: 'Memuat...', onDataChanged: _loadInitialData),
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
                userName: _userName, onDataChanged: _loadInitialData),
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
          _widgetOptions = <Widget>[
            CycleTrackerPage(
                userName: _userName, onDataChanged: _loadInitialData),
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
                      Image.asset(
                        'assets/images/Logo-1.png',
                        height: 250,
                        width: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.mosque,
                              size: 250, color: primaryColor);
                        },
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
                      return LinearGradient(
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
