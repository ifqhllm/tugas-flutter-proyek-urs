import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../main.dart';
import '../services/notification_service.dart';
import '../widgets/background_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _prayerNotificationsEnabled = true;
  bool _recordingReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prayerNotificationsEnabled =
          prefs.getBool('prayer_notifications') ?? true;
      _recordingReminderEnabled = prefs.getBool('recording_reminder') ?? true;
    });
  }

  Future<void> _updatePrayerNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_notifications', value);
    setState(() {
      _prayerNotificationsEnabled = value;
    });
    // If disabled, cancel existing notifications
    if (!value) {
      await NotificationService().cancelPrayerNotifications();
    }
  }

  Future<void> _updateRecordingReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recording_reminder', value);
    setState(() {
      _recordingReminderEnabled = value;
    });
    // If disabled, cancel existing reminder
    if (!value) {
      await NotificationService().cancelRecordingReminder();
    }
  }

  // Fungsi untuk menghapus semua data dan navigasi ke Onboarding
  Future<void> _resetApp(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Aplikasi'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus semua data (nama, riwayat siklus, dll.)? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Hapus Data', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Hapus SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Hapus Hive Boxes (Asumsikan HaidRecordBox)
        await haidService
            .clearAllRecords(); // Asumsikan HaidService memiliki fungsi ini

        // Navigasi ke Onboarding
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const NameInputScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mereset data: $e')),
          );
        }
      }
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beri Masukan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama:'),
            ),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(labelText: 'Masukan:'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final feedback = feedbackController.text.trim();
              if (name.isEmpty || feedback.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama dan Masukan harus diisi')),
                );
                return;
              }
              final message = 'Nama: $name\nMasukan: $feedback';
              final url =
                  'whatsapp://send?phone=6281918151339&text=${Uri.encodeComponent(message)}';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Notifikasi Waktu Shalat',
                  style: TextStyle(color: Colors.black)),
              subtitle:
                  const Text('Dapatkan notifikasi saat waktu shalat tiba'),
              value: _prayerNotificationsEnabled,
              onChanged: _updatePrayerNotifications,
              activeColor: const Color.fromARGB(255, 29, 202, 250),
            ),
            SwitchListTile(
              title: const Text('Pengingat Pencatatan Harian',
                  style: TextStyle(color: Colors.black)),
              subtitle:
                  const Text('Pengingat harian untuk mencatat siklus haid'),
              value: _recordingReminderEnabled,
              onChanged: _updateRecordingReminder,
              activeColor: const Color.fromARGB(255, 29, 202, 250),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: primaryColor),
              title: const Text('Tentang Aplikasi',
                  style: TextStyle(color: Colors.black)),
              subtitle: const Text('Versi 1.0.0'),
              onTap: () {
                // Aksi navigasi atau dialog info
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: primaryColor),
              title: const Text('Beri Masukan',
                  style: TextStyle(color: Colors.black)),
              onTap: () => _showFeedbackDialog(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: secondaryColor),
              title: const Text('Reset Data Aplikasi',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Menghapus semua riwayat siklus dan nama pengguna.'),
              onTap: () => _resetApp(context),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
