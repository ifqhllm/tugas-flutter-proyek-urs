import 'package:flutter/material.dart';
import 'dart:ui';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const Color lightPurple = Color(0xFFE8EAF6); 
    // Merah Muda Pucat (Soft Pink) - untuk highlight di kiri atas
    const Color softPink = Color(0xFFFFEBEE);

    return Stack(
      children: [
        // 1. Latar Belakang Gradien Utama 
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            // Menggunakan LinearGradient untuk gradien horizontal
            // yang meniru pergeseran warna dari pink ke ungu
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Mengatur warna: Pink di kiri atas, Ungu di kanan bawah, dan Putih di tengah
              colors: [
                softPink,
                lightPurple,
                lightPurple,
              ],
              stops: [0.0, 0.5, 1.0], // Mengatur pergeseran gradien
            ),
          ),
        ),

        // 2. Efek Blur (Opsional, untuk menambahkan nuansa buram/kabut)
        Positioned.fill(
          child: BackdropFilter(
            // Nilai sigmaX dan sigmaY mengontrol seberapa buram
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              // Container transparan di atas blur agar warnanya sedikit memudar
              color: Colors.white.withOpacity(0.01),
            ),
          ),
        ),

        // 3. Konten Anak (Child)
        child,
      ],
    );
  }
}

