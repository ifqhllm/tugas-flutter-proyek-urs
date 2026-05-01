import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class DoaSesudahAdzanPage extends StatefulWidget {
  final int materialNumber;

  const DoaSesudahAdzanPage({super.key, this.materialNumber = 11});

  @override
  State<DoaSesudahAdzanPage> createState() => _DoaSesudahAdzanPageState();
}

class _DoaSesudahAdzanPageState extends State<DoaSesudahAdzanPage> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDoa = prefs.getStringList('bookmarked_doa') ?? [];
    setState(() {
      _isBookmarked = savedDoa.contains(widget.materialNumber.toString());
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDoa = prefs.getStringList('bookmarked_doa') ?? [];
    final materialStr = widget.materialNumber.toString();

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      if (!savedDoa.contains(materialStr)) {
        savedDoa.add(materialStr);
      }
    } else {
      savedDoa.remove(materialStr);
    }

    await prefs.setStringList('bookmarked_doa', savedDoa);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Berhasil disimpan!' : 'Dihapus dari favorit',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: secondaryColor,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

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
              'Doa Sesudah Adzan',
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Text(
              'Membaca doa setelah mendengar adzan adalah salah satu sunnah yang sangat dianjurkan. Selain sebagai bentuk ketaatan, doa ini juga menjadi jalan untuk mendapatkan syafaat dari Rasulullah SAW di hari kiamat.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: 'Doa Sesudah Adzan',
            arabic: 'اَللّٰهُمَّ رَبَّ هٰذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ اٰتِ سَيِّدَنَا مُحَمَّدًا ۨالْوَسِيْلَةَ وَالْفَضِيْلَةَ وَالدَّرَجَةَ الرَّفِيْعَةَ وَابْعَثْهُ مَقَامًا مَحْمُوْدًا ۨالَّذِيْ وَعَدْتَهُ إِنَّكَ لَا تُخْلِفُ الْمِيْعَادَ',
            latin: 'Allaahumma Rabba haadzihid-da\'watit-taammati, wash-shalaatil-qaaimati, aati sayyidanaa Muhammadanil-wasiilata wal fadhilata wad darajatar rafii\'ah, wab\'ats-hu maqaaman mahmuudanilladzii wa\'adtah, innaka laa tukhliful-mii\'aad.',
            translation: 'Artinya: "Ya Allah Tuhan yang memiliki seruan yang sempurna dan shalat yang tetap didirikan, karuniailah Nabi Muhammad wasilah (tempat yang luhur), keutamaan, dan derajat yang tinggi. Tempatkanlah beliau pada kependudukan yang terpuji yang telah Kaujanjikan. Sungguh Engkau tiada menyalahi janji."',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContentBox({required String title, String? faedah, String? arabic, String? latin, String? translation}) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectableText(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          if (faedah != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFB6C1), width: 1),
              ),
              child: SelectableText(
                faedah,
                style: const TextStyle(
                  color: Color(0xFF8B4513),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (arabic != null) ...[
            const SizedBox(height: 16),
            SelectableText(
              arabic,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
          ],
          if (latin != null) ...[
            const SizedBox(height: 16),
            SelectableText(
              latin,
              style: TextStyle(
                color: secondaryColor.withOpacity(0.8),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ],
          if (translation != null) ...[
            const SizedBox(height: 12),
            SelectableText(
              translation,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ],
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
              "Barangsiapa membaca doa ini setelah mendengar adzan, maka ia berhak mendapatkan syafaat Rasulullah SAW pada hari kiamat.",
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
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await _toggleBookmark();
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
