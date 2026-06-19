import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../main.dart';
import '../services/notification_service.dart';

void showKebiasaanHaidDialog(BuildContext context, {bool isFromMainScreen = false, VoidCallback? onComplete}) {
  final TextEditingController controller = TextEditingController();
  
  showDialog(
    context: context,
    barrierDismissible: isFromMainScreen,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Kebiasaan Haid', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berapa hari biasanya haid anda?',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Jumlah hari',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: secondaryColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.favorite, color: primaryColor),
              ),
            ),
          ],
        ),
        actions: [
          if (isFromMainScreen)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ElevatedButton(
            onPressed: () async {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('kebiasaan_haid', val);
                await NotificationService().scheduleAllNotifications();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(); // Close dialog
                }
                
                onComplete?.call();
                  
                // Jika dipanggil dari Onboarding, langsung navigate ke MainScreen
                if (!isFromMainScreen && context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen())
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan angka kebiasaan haid yang valid')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor, 
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    }
  );
}
