import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class WiridIstighfarPage extends StatefulWidget {
  final int materialNumber;

  const WiridIstighfarPage({super.key, this.materialNumber = 6});

  @override
  State<WiridIstighfarPage> createState() => _WiridIstighfarPageState();
}

class _WiridIstighfarPageState extends State<WiridIstighfarPage> {
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
              'Wirid Istighfar',
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
              'Mengutip buku Dahsyatnya Keajaiban Istighfar bagi Orang-Orang Sibuk karya Khairi Syekh Maulana Arabi berikut beberapa bacaan dzikir istighfar yang dapat diamalkan oleh seorang muslim.',
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
            title: '1. Bacaan Pertama',
            arabic: 'أَسْتَغْفِرُ الله',
            latin: 'astaghfirullah',
            translation: 'Artinya: "Aku memohon ampun kepada Allah."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '2. Bacaan Kedua',
            arabic: 'أَسْتَغْفِرُ اللهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوْبُ إِلَيْهِ',
            latin: 'astaghfirullahalladzi la ilaha illa huwal hayyul qayyum wa atuubu ilaih.',
            translation: 'Artinya: "Aku memohon ampun kepada Allah, tiada Tuhan yang berhak diibadahi selain-Nya, Yang Maha Hidup, Yang Maha Mengurus, dan aku bertaubat kepada-Nya."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '3. Bacaan Ketiga',
            arabic: 'سُبْحَانَكَ اللهُ وَبِحَمْدِهِ، أَسْتَغْفِرُ اللَّهَ وَأَتُوْبُ إِلَيْهِ',
            latin: 'subhanallahu wa bihamdihi, astaghfirullah wa atuubu ilaih.',
            translation: 'Artinya: "Maha Suci Allah dengan memuji-Nya. Aku memohon ampun kepada-Nya serta bertaubat kepada-Nya."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '4. Bacaan Keempat',
            arabic: 'سُبْحَانَكَ، اللَّهُمَّ رَبَّنَا وَبِحَمْدِكَ أَسْتَغْفِرُكَ وَأَتُوْبُ إِلَيْكَ',
            latin: 'subhanaka allahumma rabbana wa bihamdika astaghfiruka wa atuubu ilaik.',
            translation: 'Artinya: "Maha Suci Engkau ya Allah Tuhan kami, dengan memuji-Mu, aku memohon ampun dan bertaubat kepada-Mu."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '5. Bacaan Kelima',
            arabic: 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
            latin: 'rabbighfir lii wa tub \'alayya innaka anta at-tawwabur rahim.',
            translation: 'Artinya: "Wahai Tuhanku ampunilah aku dan terimalah taubatku. Sesungguhnya, Engkau lah Maha Penerima taubat dan Maha Penyayang."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '6. Bacaan Keenam',
            arabic: 'سُبْحَانَكَ، اللَّهُمَّ وَبِحَمْدِكَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ أَسْتَغْفِرُكَ وَأَتُوْبُ إِلَيْكَ',
            latin: 'subhanaka allahumma wa bihamdiika asyhadu alla ilaha illa anta astaghfiruka wa atuubu ilaik.',
            translation: 'Artinya: "Maha Suci Engkau ya Allah dengan memuji-Mu, aku bersaksi bahwa tiada Tuhan yang berhak diibadahi dengan benar selain Engkau. Aku memohon ampun dan bertaubat kepada-Mu."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '7. Bacaan Ketujuh',
            arabic: 'أَللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَ ارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ',
            latin: 'allahumma inni zhalamtu nafsi zhulman katsiran wala yagfirud dzunuba illa anta, faghfirlī maghfira tan min \'indika warhamnii innaka anta al-ghafuurur rahim.',
            translation: 'Artinya: "Ya Allah sungguh aku telah menzalimi diriku dengan kezaliman yang banyak. Dan, tiada yang bisa mengampuni dosa-dosaku selain Engkau. Maka, ampunkan aku dengan pengampunan-Mu dan rahmatilah aku. Sesungguhnya, Engkaulah Maha Pengampun lagi Maha Penyayang."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '8. Bacaan Kedelapan',
            arabic: 'أَللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَاسْتَطَعْتُ وَأَعُوْدُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي إِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
            latin: 'allahumma anta rabbi la ilaha illa anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastata\'tu wa a\'udzu bika min syarri ma shana\'tu, abuu\'u laka bini\'matika \'alayya wa abuu\'u laka bidzanbi faghfirlī innahu la yagfirud dzunuba illa anta.',
            translation: 'Artinya: "Ya Allah Engkau adalah Tuhanku, tidak ada sesembahan yang haq kecuali Engkau. Engkau yang menciptakanku sedangkan aku adalah hamba-Mu dan aku di atas ikatan janji-Mu dengan semampuku, aku berlindung kepadamu dari segala kejahatan yang telah aku perbuat, aku mengakui-Mu atas nikmat-Mu terhadap diriku dan aku mengakui dosaku pada-Mu, maka ampunilah aku, sesungguhnya tiada yang bisa mengampuni segala dosa kecuali Engkau."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '9. Bacaan Sayyidul Istighfar',
            faedah: 'Mengutip dari sumber sebelumnya, sayyidul istighfar merupakan bacaan yang dianggap sebagai puncak dari istighfar oleh Nabi Muhammad SAW. Karenanya, beliau sangat menganjurkan umatnya untuk membaca sayyidul istighfar ini agar umatnya dapat meraih ampunan dari Allah SWT. Berikut bacaan sayyidul Istighfar.',
            arabic: 'أَللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَاسْتَطَعْتُ وَأَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوْهُ لَكَ بِذَنْبِي فَاغْفِرْ لِي إِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ',
            latin: 'allahumma anta rabbi, la ilaha illa anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastata\'tu, wa a\'udzu bika min syarri ma shana\'tu, abuu\'u laka bini\'matika \'alayya wa abuu\'u laka bidzanbi, faghfirlī innahu la yagfirud dzunuba illa anta.',
            translation: 'Artinya: "Ya Allah Engkau adalah Tuhanku, tidak ada sesembahan yang hak kecuali Engkau. Engkau yang menciptakanku sedang aku adalah hamba- Mu, dan aku diatas ikatan janji-Mu (yaitu selalu menjalankan perjanjian-Mu untuk beriman dan ikhlas dalam menjalankan amal ketaatan kepada-Mu) dengan semampuku. Aku berlindung kepadamu dari segala kejahatan yang telah aku perbuat, aku mengakui-Mu atas nikmat-Mu terhadap diriku, dan aku mengakui dosaku pada-Mu, maka ampunilah aku. Sesungguhnya, tiada yang bisa mengampuni segala dosa kecuali Engkau." (HR. Bukhari)',
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
              "Dikutip dari buku Fikih Istighfar karya Syaikh Ismail Al-Muqaddam",
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
