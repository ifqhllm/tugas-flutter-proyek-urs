import 'package:flutter/material.dart';

class DuaPage extends StatelessWidget {
  const DuaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Kumpulan doa dan artikel islami untuk muslimah.'),
      ),
    );
  }
}
