import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';

class WiridAndDuaPage extends StatelessWidget {
  const WiridAndDuaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Wirid dan Doa'),
        foregroundColor: Colors.black,
      ),
      body: BackgroundWidget(
        child: const Center(
          child: Text('Kumpulan wirid dan doa.'),
        ),
      ),
    );
  }
}
