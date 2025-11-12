import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            child: const Text('Batal', style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus Data',
                style: TextStyle(color: secondaryColor)),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: primaryColor),
            title: const Text('Tentang Aplikasi',
                style: TextStyle(color: textColor)),
            subtitle: const Text('Versi 1.0.0'),
            onTap: () {
              // Aksi navigasi atau dialog info
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: secondaryColor),
            title: const Text('Reset Data Aplikasi',
                style: TextStyle(
                    color: secondaryColor, fontWeight: FontWeight.bold)),
            subtitle:
                const Text('Menghapus semua riwayat siklus dan nama pengguna.'),
            onTap: () => _resetApp(context),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
