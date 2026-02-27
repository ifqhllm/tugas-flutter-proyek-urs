import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Latar Belakang Gambar
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover, // Menyesuaikan gambar ke ukuran container
              alignment: Alignment.center,
            ),
          ),
        ),

        // 2. Efek Overlay (Opsional, untuk memudahkan membaca konten)
        Container(
          width: double.infinity,
          height: double.infinity,
        ),

        // 3. Konten Anak (Child)
        child,
      ],
    );
  }
}
