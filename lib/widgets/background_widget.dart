import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Latar belakang dasar Ungu Muda Pucat (Lilac)
        Container(
          width: double.infinity,
          height: double.infinity,
          // Menggunakan warna ungu muda pucat yang mendekati lilac
          color: const Color(
              0xFFF3E5F5), // Contoh: Lavender Blush/Very Light Purple
        ),

        // 2. Bentuk kurva/gelombang Atas (Putih Transparan)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 150,
          child: ClipPath(
            // Menggunakan clipper yang sudah ada
            clipper: TopWaveClipper(),
            child: Container(
              // Warna Putih dengan Opasitas, memberi kesan "kabut"
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ),

        // 3. Bentuk kurva/gelombang Bawah (Putih Transparan)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: ClipPath(
            // Menggunakan clipper yang sudah ada
            clipper: BottomWaveClipper(),
            child: Container(
              // Warna Putih dengan Opasitas
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ),

        // 4. Lingkaran radial (untuk efek cahaya lembut di tengah, menyesuaikan gradien)
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 1.5, // Lebih besar
            height: MediaQuery.of(context).size.width * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  // Warna Putih/Lilac yang sangat terang dan transparan
                  const Color(0xFFFFFFFF).withOpacity(0.4),
                  Colors.transparent,
                ],
                stops: const [
                  0.0,
                  0.7
                ], // Mengubah stops agar gradien lebih menyebar
              ),
            ),
          ),
        ),

        // 5. Konten anak
        child,
      ],
    );
  }
}

// --- CLIPPERS (TETAP SAMA) ---

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
    // Membuat kurva lebih halus
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 * size.width / 4, size.height - 40, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 20);
    // Membuat kurva lebih halus
    path.quadraticBezierTo(size.width / 4, 0, size.width / 2, 20);
    path.quadraticBezierTo(3 * size.width / 4, 40, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
