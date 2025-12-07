import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';

class QAPage extends StatelessWidget {
  const QAPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tanya Jawab'),
        foregroundColor: Colors.black,
      ),
      body: const BackgroundWidget(
        child: Center(
          child: Text('Kumpulan tanya jawab fiqih haid untuk muslimah.'),
        ),
      ),
    );
  }
}
