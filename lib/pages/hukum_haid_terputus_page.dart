import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';

class HukumHaidTerputusPage extends StatefulWidget {
  final int materialNumber;

  const HukumHaidTerputusPage({super.key, this.materialNumber = 25});

  @override
  State<HukumHaidTerputusPage> createState() => _HukumHaidTerputusPageState();
}

class _HukumHaidTerputusPageState extends State<HukumHaidTerputusPage> {
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
              _buildFooterLink(context),
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
              'Hukum Haid yang Terputus',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildContentBox(
            text: 'Hukum haid yang terputus-putus (misalnya: keluar 3 hari, berhenti 2 hari, lalu keluar lagi) secara fikih dikategorikan sebagai darah haid. Selama rentang waktu keluarnya darah dan masa berhentinya (jika ditotal) tidak melebihi kebiasaan haid atau batas maksimal haid yaitu 15 hari, wanita tersebut dihukumi sedang haid sehingga wajib meninggalkan shalat dan puasa.',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('1. Landasan Hukum dan Prinsip Fikih'),
          const SizedBox(height: 8),
          _buildContentBox(
            text: '• Batas Maksimal Haid: Jumhur ulama (termasuk Mazhab Syafi\'i) menetapkan batas maksimal masa haid adalah 15 hari.\n\n'
                '• Masa Suci di Antara Dua Darah: Para ulama berbeda pendapat mengenai masa berhentinya darah. Namun, pendapat yang kuat (rajih) dari Mazhab Syafi\'i dan Hanafi menyatakan bahwa masa putus atau jeda tersebut masih terhitung sebagai masa haid, selama total durasi haid dan masa bersih tidak melebihi 15 hari.\n\n'
                '• Darah Istihadhah (Penyakit): Jika darah terus mengalir melewati batas maksimal 15 hari, atau masa putusnya darah justru terjadi terus-menerus di luar siklus kebiasaan, maka darah tersebut dihukumi sebagai darah istihadhah.',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('2. Panduan Praktis dan Tata Cara Ibadah'),
          const SizedBox(height: 8),
          _buildContentBox(
            text: 'Untuk menentukan apakah Anda wajib mandi besar (bersuci) saat darah berhenti sementara atau tidak, Anda dapat mengkategorikannya berdasarkan kondisi Anda:\n\n'
                '• Masa Jeda Sangat Singkat (Kurang dari Sehari): Jika darah berhenti hanya sebentar (kurang dari 24 jam), ulama seperti dalam kitab Al-Mughni menyebutkan bahwa masa ini tidak dianggap sebagai keadaan suci. Anda tidak perlu mandi wajib dan belum boleh shalat, karena kemungkinan darah akan keluar kembali.\n\n'
                '• Masa Jeda Cukup Panjang (Lebih dari 24 Jam): Jika darah berhenti cukup lama (lebih dari 1 hari 1 malam) dan Anda melihat tanda-tanda suci (misalnya: cairan putih bening atau area kewanitaan benar-benar kering), mayoritas ulama membolehkan Anda untuk mandi besar, shalat, dan puasa. Jika nanti darah keluar lagi, hentikan shalat dan hitung kembali sebagai satu siklus.',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Redaksi Kitab (Teks Arab & Terjemahan)'),
          const SizedBox(height: 8),
          _buildArabicContentBox(
            arabicText: '(وَمَا نَقَصَ) مِنْ دَمٍ أَوْ طُهْرٍ (عَنْ أَقَلِّهِ) كَمَا لَوْ رَأَتْ فِي يَوْمٍ دَمًا وَفِي يَوْمٍ طُهْرًا وَفِي يَوْمٍ دَمًا (فَالصَّحِيحُ أَنَّهُ لَيْسَ بِحَيْضٍ)',
            translationText: 'Terjemahannya:\n"Dan darah atau masa suci yang kurang dari batas minimalnya—seperti seorang wanita yang mengeluarkan darah pada suatu hari, lalu suci di hari berikutnya, kemudian mengeluarkan darah lagi di hari berikutnya—maka menurut pendapat yang paling shahih (kuat) itu bukanlah haid."\n\n(Catatan: Maksudnya jika darah pertama kurang dari sehari semalam atau putusnya tidak memenuhi syarat haid).',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Contoh Penerapan (Siklus Haid Terputus)'),
          const SizedBox(height: 8),
          _buildContentBox(
            text: 'Berdasarkan rumusan syarah pada halaman tersebut:\n\n'
                '• Hari 1-4: Keluar darah haid.\n'
                '• Hari 5-7: Darah berhenti (masa jeda/suci).\n'
                '• Hari 8-12: Darah keluar kembali.\n\n'
                'Kesimpulan Hukum:\nMaka dari tanggal 1 hingga 12 dianggap keseluruhannya sebagai masa haid dan dihukumi suci (tidak perlu mengqadha shalat) pada hari kelima hingga ketujuh. Namun, jika akumulasi hari darah dan jeda suci melebihi 15 hari, maka darah yang keluar pada hari ke-16 dan seterusnya dihukumi sebagai darah istihadlah (darah penyakit).',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: secondaryColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
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

  Widget _buildArabicContentBox({required String arabicText, required String translationText}) {
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
            arabicText,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontFamily: 'Amiri', // Traditional Arabic Font style
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          SelectableText(
            translationText,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB6C1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final Uri url = Uri.parse('https://online.fliphtml5.com/uscyg/sqqc/');
            try {
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                throw Exception('Could not launch $url');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal membuka link: $e')),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(
                  Icons.book,
                  color: secondaryColor,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Referensi Kitab:',
                        style: TextStyle(
                          color: Color(0xFF8B4513),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Kitab Mughni al-Muhtaj juz 1',
                        style: TextStyle(
                          color: Color(0xFF8B4513),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: secondaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
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
