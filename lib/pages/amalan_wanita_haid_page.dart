import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class AmalanWanitaHaidPage extends StatefulWidget {
  final int materialNumber;

  const AmalanWanitaHaidPage({super.key, this.materialNumber = 6});

  @override
  State<AmalanWanitaHaidPage> createState() => _AmalanWanitaHaidPageState();
}

class _AmalanWanitaHaidPageState extends State<AmalanWanitaHaidPage> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWirid = prefs.getStringList('bookmarked_wirid') ?? [];
    setState(() {
      _isBookmarked = savedWirid.contains(widget.materialNumber.toString());
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWirid = prefs.getStringList('bookmarked_wirid') ?? [];
    final materialStr = widget.materialNumber.toString();

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      if (!savedWirid.contains(materialStr)) {
        savedWirid.add(materialStr);
      }
    } else {
      savedWirid.remove(materialStr);
    }

    await prefs.setStringList('bookmarked_wirid', savedWirid);

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
              'Amalan Wanita Haid',
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
              'Dalam Islam, meskipun seorang perempuan sedang berhalangan melaksanakan salat atau puasa, tetap ada banyak amalan yang bisa dilakukan untuk menjaga pahala dan memohon agar doa dikabulkan. Salah satu amalan utama yang dianjurkan adalah memperbanyak dzikir dan sholawat. Meskipun dalam keadaan tidak suci, dzikir tetap dapat dilakukan dan menjadi cara yang sangat baik untuk mendekatkan diri kepada Allah Ta\'ala.',
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
            title: 'Tata Cara Berdzikir dan Berdoa',
            translation: '1. Dilakukan pada waktu mustajab: Sebaiknya memilih waktu-waktu mustajab seperti hari Jumat, malam Lailatul Qadar, atau sepertiga malam terakhir.\n\n2. Dilakukan dengan khusyuk: Meski dalam kondisi haid, penting untuk melaksanakan dzikir dengan penuh kekhusyukan, seperti setelah salat atau di waktu luang.\n\n3. Menghadap kiblat: Saat berdoa, lebih baik menghadap kiblat sebagai bentuk penghormatan.\n\n4. Dimulai dengan pujian kepada Allah Ta\'ala: Bacalah pujian kepada Allah dan sholawat kepada Nabi Muhammad SAW sebelum berdoa.\n\n5. Membaca syahadat dan memohon ampunan: Awali dzikir dengan syahadat dan mohon ampun atas dosa yang diperbuat.\n\n6. Berdoa dengan rendah hati: Dalam berdoa, bersikap rendah diri, menggunakan bahasa yang lembut dan penuh pengharapan.\n\n7. Tidak berputus asa: Yakinlah bahwa Allah Ta\'ala akan mengabulkan doa, meskipun membutuhkan waktu.\n\n8. Berdoa untuk orang lain: Setelah berdoa untuk diri sendiri, lanjutkan dengan doa untuk orang lain sebagai bentuk kepedulian.\n\n9. Gunakan asmaul husna: Berdoa dengan menyebut nama-nama Allah yang indah (asmaul husna) dapat memperbesar harapan agar doa dikabulkan.\n\n10. Tetap menjaga kebersihan: Meski haid, penting menjaga kebersihan tubuh dan lingkungan.',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '1. Hauqalah',
            faedah: 'Dzikir ini dikenal sebagai Hauqalah dan menjadi harta perbendaharaan surga. Barang siapa yang mengucapkannya, maka Allah SWT akan menyelamatkannya dari segala siksaan.',
            arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
            latin: 'Laa hawla wa laa quwwata illaa billaah.',
            translation: 'Artinya: "Tiada daya dan upaya kecuali dengan kekuatan Allah."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '2. Sayyidul Istighfar',
            faedah: 'Memperbanyak doa seperti Sayyidul Istighfar dan dzikir lainnya dapat menjadi bentuk mendekatkan diri kepada Allah dan memperbesar peluang doa dikabulkan.',
            arabic: 'اَللَّهُمَّ أَنْتَ رَبِّيْ لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِيْ وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ. أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ. أَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ. وَأَبُوْءُ بِذَنْبِيْ. فَاغْفِرْ لِيْ فَإِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ',
            latin: 'Allahumma anta rabbii laa ilaaha illaa anta khalaqtanii wa anaa \'abduka wa anaa \'alaa \'ahdika wa wa\'dika mastatha\'tu. A\'uudzu bika min syarri maa shana\'tu. Abuu-u laka bini\'matika \'alayya. Wa abuu-u bidzanbii. Faghfirlii fa-innahu laa yaghfirudz dzunuuba illaa anta.',
            translation: 'Artinya: "Hai Tuhanku, Engkau Tuhanku. Tiada Tuhan yang disembah selain Engkau. Engkau yang menciptakan. Aku adalah hamba-Mu. Aku berada dalam perintah iman sesuai perjanjian-Mu sebatas kemampuanku. Aku berlindung kepada-Mu dari kejahatan yang kuperbuat. Kepada-Mu, aku mengakui segala nikmat-Mu padaku. Aku mengakui dosaku. Maka itu ampunilah dosaku. Sungguh tiada yang mengampuni dosa selain Engkau."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '3. Tasbih',
            arabic: 'سُبْحَانَ اللهِ وَالْحَمْدُ للهِ وَلَا إِلَهَ إِلَّا اللهُ وَاللهُ أَكْبَرُ',
            latin: 'Subhaanallaahi walhamdu lillaahi wa laa ilaaha illallaahu wallaahu akbar.',
            translation: 'Artinya: "Mahasuci Allah, segala puji bagi Allah, tiada Tuhan selain Allah, dan Allah Mahabesar."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '4. Tahlil',
            arabic: 'لَا إِلَهَ إِلَّا اللهُ',
            latin: 'Laa ilaaha illallaah.',
            translation: 'Artinya: "Tiada Tuhan selain Allah."',
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
              "Semoga amalan dzikir dan doa ini senantiasa dikabulkan oleh Allah Ta'ala.",
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
