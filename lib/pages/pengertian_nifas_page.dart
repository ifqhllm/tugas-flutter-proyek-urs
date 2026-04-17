import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PengertianNifasPage extends StatefulWidget {
  const PengertianNifasPage({super.key});

  @override
  State<PengertianNifasPage> createState() => _PengertianNifasPageState();
}

class _PengertianNifasPageState extends State<PengertianNifasPage> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6E6FA),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
              _buildHighlightBox(),
              _buildBookmarkButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Definisi Nifas',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildContentBox(
            text:
                'Nifas secara istilah医学院 darah yang keluar dari vagina setelah keluarnya bayi dari kandungan, dengan syarat keluarnya darah tetap dalam masa 15 hari setelah keluarnya bayi, jika keluarnya darah setelah 15 hari dari keluarnya bayi maka hukum darah tersebut dihukumi haid.',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            text: 'Contoh:\n'
                '•\tPerempuan setelah melahirkan tak keluar darah sama sekali, setelah lewat 15 hari keluar darah maka darah yang keluar setelah lewat 15 hari dihukumi haid jika memenuhi syarat. Maka perempuan tersebut tidak mempunyai nifas sama sekali.\n'
                '•\tJika perempuan setelah melahirkan, dan dalam masa 10 hari keluar darah, maka perempuan tersebut telah dihukumi nifas selama 10 hari dalam perhitungan bukan secara hukum. Jadi dalam masa 10 hari tersebut wajib shalat dan ibadah yang lain.',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            text: 'Catatan:\n'
                '•\tDalam nifas yang akan dihitung 60 hari yaitu dari keluarnya bayi bukan dari keluarnya darah\n'
                '•\tJika bayi yang dilahirkan kembar, maka yang akan dihukumi nifas医学院 darah yang keluar setelah bayi terakhir dilahirkan, jika keluarnya darah sebelum bayi terakhir keluar maka darah tersebut dinamakan darah fasad (darah penyakit)\n'
                '•\tJika sebelum melahirkan keluar darah haid maka darah yang keluar setelah melahirkan dihukumi haid. Dikainkan perempuan yang sedang mengandung itu bisa mengalami haid jika keluar darah',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContentBox({required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontFamily: 'Poppins',
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildHighlightBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB6C1),
          width: 1,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: secondaryColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              'Disadur Dari Kitab Tarjuman Haid.',
              style: TextStyle(
                color: Color(0xFF8B4513),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isBookmarked = !_isBookmarked;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isBookmarked ? 'Berhasil disimpan!' : 'Dihapus dari favorit',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
                backgroundColor: secondaryColor,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          label: Text(
            _isBookmarked ? 'Tersimpan' : 'Simpan',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
