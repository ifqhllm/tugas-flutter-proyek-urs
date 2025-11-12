import 'package:flutter/material.dart';

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Daftar artikel akan ditampilkan di sini.'),
      ),
    );
  }
}
