import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../main.dart' as main;
import '../services/notification_service.dart';
import '../widgets/background_widget.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _recordingReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recordingReminderEnabled = prefs.getBool('recording_reminder') ?? true;
    });
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

        // Also clear the 6 user-input cycles
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cycle_1');
        await prefs.remove('cycle_2');
        await prefs.remove('cycle_3');
        await prefs.remove('cycle_4');
        await prefs.remove('cycle_5');
        await prefs.remove('cycle_6');
        await prefs.remove('cycles_input_date');
        await prefs.remove('prediction_completed');
        await prefs.remove('prediction_skipped');

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
    if (!context.mounted) return;
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
            InkWell(
              onTap: () async {
                final Uri url = Uri.parse('https://wa.me/6281918151339');
                try {
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuka WhatsApp: $e')),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android, color: Colors.green),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'WhatsApp: 081918151339',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
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
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final Uri url = Uri.parse('mailto:ifqohululum@gmail.com?subject=Tanya%20Jawab%20Al-Heedh');
                try {
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuka Email: $e')),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: primaryColor),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Email: ifqohululum@gmail.com',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
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
              ),
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 10),
            const Text('Tentang Aplikasi'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: primaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Al-Heedh',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Text(
                      'Solusi Cerdas Muslimah • v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Biodata Pengembang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Card(
                elevation: 0,
                color: Color(0xFFFFF5F7),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.person, size: 18, color: primaryColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nama: Ifqohul Ulum',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.badge, size: 18, color: primaryColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'NIM: 2022020100014',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.school, size: 18, color: primaryColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pendidikan: Program Studi Teknik Informatika, Fakultas Teknik, Universitas Islam Madura',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Mengapa Aplikasi Ini Dibuat?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Aplikasi Al-Heedh dibuat atas kesadaran bahwa pemahaman tentang darah kewanitaan (Haid, Istihadah, dan Nifas) adalah ilmu fardhu \'ain yang wajib dipelajari setiap muslimah karena berkaitan erat dengan keabsahan ibadah shalat dan puasa.\n\nSeringkali, kerumitan perhitungan hari haid dan masa suci menimbulkan keraguan dalam beribadah. Melalui Al-Heedh, pengembang berkomitmen menghadirkan solusi teknologi cerdas yang dapat mengotomatisasi perhitungan hukum Fiqh (khususnya Madzhab Sya\'i) secara otomatis dan akurat, guna membantu para muslimah beribadah dengan penuh kepastian dan ketenangan jiwa.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.rate_review, size: 18),
                      label: const Text('Beri Saran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final Uri url = Uri.parse(
                            'https://wa.me/6281918151339?text=Assalamualaikum%20Kak%20Ifqoh,%20saya%20ingin%20memberikan%20saran%20mengenai%20aplikasi%20Al-Heedh...');
                        try {
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            throw Exception('Could not launch $url');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal membuka WhatsApp: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.star_rate, size: 18),
                      label: const Text('Beri Penilaian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.alheedh.app');
                        try {
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            throw Exception('Could not launch $url');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Akan segera tersedia setelah aplikasi rilis di Google Play Store! Terima kasih atas dukungan Anda.'),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            ListTile(
              leading: const Icon(Icons.notifications_active, color: primaryColor),
              title: const Text('Tes Notifikasi Instan',
                  style: TextStyle(color: Colors.black)),
              subtitle: const Text('Kirim notifikasi uji coba langsung ke HP Anda'),
              onTap: () async {
                try {
                  await NotificationService().showInstantTestNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifikasi tes berhasil dikirim!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengirim notifikasi tes: $e')),
                    );
                  }
                }
              },
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
              onTap: () => _showAboutDialog(context),
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
