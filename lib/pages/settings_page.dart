import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../main.dart' as main;
import '../services/notification_service.dart';
import '../widgets/background_widget.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _recordingReminderEnabled = true;
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

  Future<void> _deleteAllCycleHistory(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Riwayat Siklus'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus semua riwayat siklus haid? Tindakan ini tidak dapat dibatalkan.'),
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
      try {
        await main.haidService.clearAllRecords();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Semua riwayat siklus berhasil dihapus')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus riwayat: $e')),
          );
        }
      }
    }
  }

  Future<void> _changeUserName(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString(userNameKey) ?? 'Pengguna';
    controller.text = current;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Nama Pengguna'),
        content: TextField(
          controller: controller,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: 'Nama panggilan',
            hintText: 'Masukkan nama baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null) {
      await prefs.setString(userNameKey, result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama pengguna berhasil diubah')),
        );
      }
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungi Kami'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'WhatsApp: 081918151339',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        const ClipboardData(text: '081918151339'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Nomor WhatsApp berhasil disalin')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Email: ifqohululum@gmail.com',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(
                        const ClipboardData(text: 'ifqohululum@gmail.com'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email berhasil disalin')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
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
              title: const Text('Pengingat Pencatatan Harian',
                  style: TextStyle(color: Colors.black)),
              subtitle:
                  const Text('Pengingat harian untuk mencatat siklus haid'),
              value: _recordingReminderEnabled,
              onChanged: _updateRecordingReminder,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: primaryColor),
              title: const Text('Hapus Semua Riwayat Siklus',
                  style: TextStyle(color: Colors.black)),
              subtitle: const Text('Menghapus semua data riwayat siklus haid'),
              onTap: () => _deleteAllCycleHistory(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: primaryColor),
              title: const Text('Ubah Nama Pengguna',
                  style: TextStyle(color: Colors.black)),
              subtitle: const Text('Mengubah nama panggilan Anda'),
              onTap: () => _changeUserName(context),
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
          ],
        ),
      ),
    );
  }
}
