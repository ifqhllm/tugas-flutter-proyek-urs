import 'package:flutter/material.dart';

class WiridAndDuaPage extends StatelessWidget {
  const WiridAndDuaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wirid & Doa'),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Kumpulan wirid dan doa.'),
      ),
    );
  }
}
