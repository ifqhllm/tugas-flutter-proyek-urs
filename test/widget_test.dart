import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_heedh/main.dart'; // Sesuaikan path jika berbeda

void main() {
  testWidgets('Cek Teks Selamat Datang setelah input nama',
      (WidgetTester tester) async {
    // Bangun aplikasi kita dan picu frame.
    // Ganti MyApp() menjadi AlHeedhApp()
    await tester.pumpWidget(const AlHeedhApp());

    // Verifikasi bahwa Splash Screen muncul (kita akan mencari teks 'Al-Heedh')
    expect(find.text('Al-Heedh: Solusi Cerdas Muslimah'), findsOneWidget);

    // Karena Splash Screen menunggu 3 detik, kita harus memompa selama 3 detik
    // untuk melanjutkan ke NameInputScreen (asumsi SharedPrefs kosong)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verifikasi bahwa NameInputScreen muncul
    expect(find.text('Masukkan Nama Panggilan Anda'), findsOneWidget);

    // Masukkan teks ke dalam TextField
    await tester.enterText(find.byType(TextField), 'Test Pengguna');

    // Tekan tombol 'Lanjutkan'
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    // Verifikasi bahwa sapaan 'Assalamualaikum' muncul di halaman utama
    expect(find.text('Assalamualaikum, Test Pengguna!'), findsOneWidget);
  });
}
