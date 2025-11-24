import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base uniform pink background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFFCE4EC), // Very light blush pink
        ),
        // Top curved shape
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 150,
          child: ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
        ),
        // Bottom curved shape
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: ClipPath(
            clipper: BottomWaveClipper(),
            child: Container(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
        ),
        // Large transparent circle with light purple gradient
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 1.2,
            height: MediaQuery.of(context).size.width * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE1BEE7).withOpacity(0.2), // Light purple
                  Colors.transparent,
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 20);
    path.quadraticBezierTo(3 * size.width / 4, size.height - 40, size.width, size.height - 20);
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