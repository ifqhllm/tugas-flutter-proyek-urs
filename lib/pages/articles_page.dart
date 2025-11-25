import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';

class DuaPage extends StatelessWidget {
  const DuaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Artikel'),
        foregroundColor: Colors.black,
      ),
      body: const BackgroundWidget(
        child: Center(
          child: Text('Kumpulan artikel islami untuk muslimah.'),
        ),
      ),
    );
  }
}
