import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class TatacaraSholatDanBersuciPage extends StatefulWidget {
  final int materialNumber;

  const TatacaraSholatDanBersuciPage({super.key, this.materialNumber = 23});

  @override
  State<TatacaraSholatDanBersuciPage> createState() =>
      _TatacaraSholatDanBersuciPageState();
}

class _TatacaraSholatDanBersuciPageState
    extends State<TatacaraSholatDanBersuciPage> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIstihadah = prefs.getStringList('bookmarked_istihadah') ?? [];
    setState(() {
      _isBookmarked = savedIstihadah.contains(widget.materialNumber.toString());
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIstihadah = prefs.getStringList('bookmarked_istihadah') ?? [];
    final materialStr = widget.materialNumber.toString();

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      if (!savedIstihadah.contains(materialStr)) {
        savedIstihadah.add(materialStr);
      }
    } else {
      savedIstihadah.remove(materialStr);
    }

    await prefs.setStringList('bookmarked_istihadah', savedIstihadah);

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
              'Tatacara Sholat dan Bersuci',
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
                'Adapaun tatacara bersholat dan bersuci bagi perempuan istihadah adalah sebagai berikut:',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            text:
                '1. Membasuh kemaluannya sebelum mengerjakan shalat. Wanita istihadah harus menyumbat atau menutup kemaluannya dengan kapas, atau sejenisnya ketika hendak shalt.\n\n'
                '2. Membalut kemaluannya. Kewajiban ini dilakukan setelah menyumbat dan menutupnya. Kewajiban membalut ini jika memenuhi dua syarat yaitu: pertama, darah selalu keluar ketika hendak mengerjakan shalat, sehingga pembalut menjadi satu-satunya solusi agar darah tidak keluar; dan kedua, tidak sampai berdampak bahaya pada dirinya sendiri.\n\n'
                '3. Wudhu setelah masuknya waktu sholat. Dan, tidak boleh bagi wanita istihadah untuk wudhu sebelum masuknya waktu shalat, karena wudhu yang dilakukan saat istihadah termasuk dari bagian bersuci yang dharurah (thaharah darurah). adapun niat wudhu nya sebagai berikut:',
          ),
          const SizedBox(height: 12),
          _buildDoaBox(),
          const SizedBox(height: 12),
          _buildContentBox(
            text:
                '4. Wajib ketika waktu shalat sudah masuk untuk membasuh kemaluannya, kemudian menyumbat dan menutupnya, dilanjutkan dengan membalutnya, setelah itu wudhu, dan salat.\n\n'
                'Wanita yang sedang istihadah harus wudhu dalam setiap salat wajib. Ia tidak bisa menggunakan satu wudhu untuk dua salat wajib. Selain wudhu, menurut pendapat yang lebih sahih (ashah) ia juga wajib untuk membarui basuhan pada kemaluannya, penyumbatan, dan pembalutannya.',
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

  Widget _buildDoaBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9E9E9E),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SelectableText(
            'نَوَيْتُ فَرْضَ الْوُضُوْءِ لاِسْتِبَاحَةِ الصَّلاَةِ لِلَّهِ تَعَالَى',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontFamily: 'Poppins',
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          const SelectableText(
            'Nawaitu Fardhal Wudhu\'i lis tibahatis salati lillahi ta\'ala',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          const SelectableText(
            'Artinya: "Aku niat fardlunya wudhu untuk diperbolehkankannya salat karena Allah Ta\'ala."',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
