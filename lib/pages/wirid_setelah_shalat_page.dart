import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class WiridSetelahShalatPage extends StatefulWidget {
  final int materialNumber;

  const WiridSetelahShalatPage({super.key, this.materialNumber = 4});

  @override
  State<WiridSetelahShalatPage> createState() => _WiridSetelahShalatPageState();
}

class _WiridSetelahShalatPageState extends State<WiridSetelahShalatPage> {
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
              'Wirid Setelah Shalat',
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
            title: '1. Membaca Istighfar Dahulu',
            subtitle: 'Sebelum berdoa, dianjurkan untuk membaca istighfar sebanyak tiga kali:',
            arabic: 'أَسْتَغْفِرُ اللهَ الْعَظِـيْمِ الَّذِيْ لَااِلَهَ اِلَّا هُوَ الْحَيُّ الْقَيُّوْمُ وَأَتُوْبُ إِلَيْهِ',
            latin: '"ASTAGHFIRULLAH HAL\'ADZIM, ALADZI LAAILAHA ILLAHUWAL KHAYYUL QOYYUUMU WA ATUUBU ILAIIH"',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '2. Dilanjutkan dengan membaca:',
            arabic: 'لَاإِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِيْ وَيُمِيْتُ وَهُوَ عَلَى كُلِّ شَيْئٍ قَدِيْرٌ',
            latin: '"LAA ILAHA ILLALLAH WAKHDAHU LAA SYARIKA LAHU, LAHUL MULKU WALAHUL KHAMDU YUKHYIIY WAYUMIITU WAHUWA \'ALAA KULLI SYAI\'INNQODIIR"',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '3. Memohon perlindungan dari siksa neraka (3 Kali)',
            arabic: 'اَللَّهُمَّ أَجِرْنِـى مِنَ النَّارِ',
            latin: '"ALLAHUMMA AJIRNI MINAN-NAAR" 3x',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '4. Memuji Allah Dengan Kalimat',
            arabic: 'للَّهُمَّ أَنْتَ السَّلاَمُ، وَمِنْكَ السَّلَامُ، وَإِلَيْكَ يَعُوْدُ السَّلَامُ فَحَيِّنَارَبَّنَا بِالسَّلَامِ وَاَدْخِلْنَا الْـجَنَّةَ دَارَ السَّلَامِ تَبَارَكْتَ رَبَّنَا وَتَعَالَيْتَ يَا ذَاالْـجَلَالِ وَاْلإِكْرَام.',
            latin: '"ALLAHUMMA ANGTASSALAM, WAMINGKASSALAM, WA ILAYKA YA\'UUDUSSALAM FAKHAYYINA RABBANAA BISSALAAM WA-ADKHILNALJANNATA DAROSSALAAM TABAROKTA RABBANAA WATA\'ALAYTA YAA DZALJALAALI WAL IKRAAM"',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '5. Membaca surat Al-Fatihah dan ayat kursi',
            subtitle: 'Membaca Surat Al-Fatihah kemudian dilanjutkan dengan membaca Ayat Kursi (Al-Baqarah : 255)',
            arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ. بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيْمِ. اَللهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَّلَانَوْمٌ، لَهُ مَافِي السَّمَاوَاتِ وَمَافِي اْلأَرْضِ مَن ذَا الَّذِيْ يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَابَيْنَ أَيْدِيْهِمْ وَمَاخَلْفَهُمْ وَلَا يُحِيْطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَآءَ، وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَاْلأَرْضَ وَلَا يَـؤدُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيْمُ.',
            latin: '"Allahu laa ilaaha illaa huwal hayyul qayyum. Laa ta\'khudzuhuu sinatuw wa laa naum. Lahuu maa fis samaawaati wa maa fil ardh. Man dzal ladzii yasyfa\'u \'indahuu illaa bi idznih. Ya\'lamu maa bayna aidiihim wa maa khalfahum. Wa laa yuhiithuuna bi syai-im min \'ilmihii illaa bimaa syaa-a. Wasi\'a kursiyyuhus samaawaati wal ardh walaa ya-uuduhuu hifzhuhumaa Wahuwal \'aliyyul \'azhiim."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '6. Membaca Tasbih, Tahmid, Takbir, dan Tahlil',
            arabic: 'سُبْحَانَ اللهِ\n\nالْحَمْدُلِلهِ\n\nاللهُ اَكْبَرُ\n\nلَااِلٰهَ اِلَّا اللهُ',
            latin: '"SUBHANALLAH" 33x\n"ALHAMDULILLAH" 33x\n"ALLAHU AKBAR" 33x\n"LAILAHA ILLALLAH" 33x',
          ),
          const SizedBox(height: 12),
          _buildLongContentBox(
            title: '7. Membaca Doa Berikut',
            subtitle: 'Setelah selesai berdzikir, maka membaca doa setelah sholat berikut:',
            contentBlocks: [
              {
                'arabic': 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيماَلْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِيْنَ. حَمْدًا يُوَافِيْ نِعَمَهُ وَيُكَافِئُ مَزِيْدَهُ. يَا رَبَّنَا لَكَ الْحَمْدُ كَمَا يَنْبَغِيْ لِجَلاَلِ وَجْهِكَ الْكَرِيْمِ وَعَظِيْمِ سُلْطَانِكَ',
                'latin': '"BISMILLAHIRRAHMAANIRRAHIIM. ALHAMDU LILLAAHI RABBIL \'AALAMIIN, HAMDAN YUWAAFII NI\'AMAHU WAYUKAAFII MAZIIDAHU. YA RABBANAA LAKAL HAMDU KAMAA YAN BAGHHI LIJALAALI WAJHIKA WA\'AZHIIMI SULTHAANIKA."'
              },
              {
                'arabic': 'اللهم صل على سيدنا محمد وعلى ال سيدنا محمد',
                'latin': '"ALLAHUMMA SHALLI \'ALAA SAYYIDINAA MUHAMMADIN WA\'ALAA AALI SAYYIDINAA MUHAMMAD".'
              },
              {
                'arabic': 'اَللَّهُمَّ رَبَّنَا تَـقَـبَّلْ مِنَّا صَلاَتَنَا وَصِيَا مَنَا وَرُكُوْ عَنَا وَسُجُوْدَنَا وَقُعُوْدَنَا وَتَضَرُّ عَنَا وَتَخَشُّوْ عَنَا وَتَعَبُّدَنَا وَتَمِّمْ تَقْصِيْرَ نَا يَا اَلله يَا رَبَّ الْعَا لَمِيْنَ',
                'latin': '"ALLAHUMMA RABBANAA TAQABBAL MINNAA SHALAATAANA WASHIYAAMANAA WARUKUU\'ANAA WASUJUUDANAA WAQU\'UUDANAA WATADLARRU\'ANAA, WATAKHASYSYU\'ANAA WATA\'ABBUDANAA, WATAMMIM TAQSHIIRANAA YAA ALLAH YAA RABBAL\'AALAMIIN".'
              },
              {
                'arabic': 'رَبَّنَا ضَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْ حَمْنَا لَنَكُوْ نَنَّ مِنَ الْخَا سِرِ يْنَ',
                'latin': '"RABBANA DZHALAMNAA ANFUSANAA WA-INLAMTAGHFIR LANA WATARHAMNAA LANAKUUNANNA MlNAL KHAASIRIIN".'
              },
              {
                'arabic': 'رَبَّنَا وَلاَ تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِ يْنَ مِنْ قَبْلِنَا',
                'latin': '"RABBANAA WALAA TAHMIL\'ALAINAA ISHRAN KAMA HAMALTAHUL\'ALAL LADZIINA MIN QABLINAA."'
              },
              {
                'arabic': 'رَبَّنَا وَلاَ تُحَمِّلْنَا مَا لاَ طَا قَتَا لَنَا بِهِ, وَاعْفُ عَنَّا وَاغْفِرْلَنَا وَارْحَمْنَا أَنْتَ مَوْلاَ نَا فَا نْصُرْنَا عَلَى الْقَوْمِ الْكَا فِرِيْنَ',
                'latin': '"RABBANAA WALAA TUHAMMILNAA MAALAA THAAQATA LANAA BIHII WA\'FU\'ANNAA WAGHFIR LANAA WARHAMNAA ANTA MAULAANAA FANSHURNAA \'ALAL QAUMIL KAAFIRIIN".'
              },
              {
                'arabic': 'رَبَّنَا لاَ تُزِغْ قُلُوْ بَنَا بَعْدَ إِذْ هَدَ يْتَنَا وَهَبْ لَنَا مِنْ لَّدُ نْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
                'latin': '"RABBANAA LAA TUZIGH QULUUBANAA BA\'DA IDZHADAITANAA W\'AHABLANAA MIN LADUNKA RAHMATAN INNAKA ANTAL WAHHAAB".'
              },
              {
                'arabic': 'رَبَّنَا غْفِرْلَنَا وَلِوَالِدِيْنَ وَلِجَمِيْعِ الْمُسْلِمِيْنَ وَالْمُسْلِمَاتِ وَالْمُؤْمِنِيْنَ وَالْمُؤْمِنَاتِ أَلْأَ حْيَآءِمِنْهُمْ وَاْلأَ مْوَاتِ, اِنَّكَ عَلَى قُلِّ ثَيْءٍقَدِيْرِ',
                'latin': '"RABBANAGHFIR LANAA WALIWAALIDINAA WALIJAMI\'IL MUSLIMIIN WALMUSLIMAATI WAL MU\'MINIINA WALMU\'MINATI. AL AHYAA-I-MINHUM WAL AMWAATI, INNAKA ALAA KULI SYAI\'N QADIIR".'
              },
              {
                'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي اْلآ خِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
                'latin': '"RABBANAA AATINAA FIDDUNYAA HASANATAN WAFIL AAKHIRATI HASANATAN WAQINAA ADZAABAN-NAAR".'
              },
              {
                'arabic': 'اللهم اغفر لنا ذنوبناوكفرعنا سيئاتنا وتوفنا مَعَ الْأَ بْرَارِ',
                'latin': '"ALLAHUMMAGHFIRLANAA DZUNUUBANAA WAKAFFIR ANNAA SAYYIAATINAA WATAWAFFANAA MAALABRAARI".'
              },
              {
                'arabic': 'سُبْحَانَ رَبِّكِ رَبِّ الْعِزَةِ عَمَّا يَصِفُوْنَ، وَسَلاَمٌ عَلَى الْمُرْ سَلِيْنَ، وَالْحَمْدُ لِلهِ رَبِّ الْعَالَمِيْنَ',
                'latin': '"SUBHAANA RABBIKA RABBIL I\'ZZATI AMMAA YASHIFUUNA WASALAAMUN \'ALAL MURSALHNA WAL-HAMDU LILLAAHI RABBIL\'AALAMIINA".'
              }
            ],
            translation: '"Dengan menyebut nama Allah Yang Maha Pengasih dan Maha Penyayang.Segala puji bagi Allah Tuhan seru sekalian alam. Dengan puji yang sebanding dengan nikmat-Nya dan menjamin tambahannya. Ya Allah Tuhan Kami, bagi-Mu segala puji dan segala apa yang patut atas keluhuran DzatMu dan Keagungan kekuasaanMu. Ya Allah! Limpahkanlah rahmat dan salam atas junjungan kita Nabi Muhammad dan sanak keluarganya.\n\nYa Allah terima sholat kami, puasa kami, ruku kami, sujud kami, duduk rebah kami, khusyu\' kami, pengabdian kami, dan sempurnakanlah apa yang kami lakukan selama sholat ya Allah. Tuhan seru sekalian alam.\n\nYa Allah, Kami telah aniaya terhadap diri kami sendiri, karena itu ya Allah jika tidak dengan limpahan ampunan-Mu dan rahmat-Mu niscaya kami akan jadi orang yang sesat. Ya Allah Tuhan kami, janganlah Engkau pikulkan atas diri kami beban yang berat sebagaimana yang pernah Engkau bebankan kepada orang yang terdahulu dari kami. Ya Allah Tuhan kami, janganlah Engkau bebankan atas diri kami apa yang di luar kesanggupan kami. Ampunilah dan limpahkanlah rahmat ampunan terhadap diri kami ya Allah. Ya Allah Tuhan kami, berilah kami pertolongan untuk melawan orang yang tidak suka kepada agamaMu.\n\nYa Allah Tuhan kami, janganlah engkau sesatkan hati kami sesudah mendapat petunjuk, berilah kami karunia. Engkaulah yang maha Pemurah.\n\nYa Allah Ya Tuhan kami, ampunilah dosa kami dan dosa dosa orang tua kami, dan bagi semua orang Islam laki-laki dan perempuan, orang orang mukmin laki-laki dan perempuan. Sesungguhnya Engkau dzat Yang Maha Kuasa atas segala-galanya.\n\nMaha suci Engkau, Tuhan segala kemuliaan. Suci dari segala apa yang dikatakan oleh orang-orang kafir. Semoga kesejahteraan atas para Rasul dan segala puji bagi Allah Tuhan seru sekalian alam."',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContentBox({required String title, String? subtitle, required String arabic, required String latin, String? translation}) {
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
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              subtitle,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
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
          ]
        ],
      ),
    );
  }

  Widget _buildLongContentBox({required String title, String? subtitle, required List<Map<String, String>> contentBlocks, String? translation}) {
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
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              subtitle,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...contentBlocks.expand((block) {
            return [
              SelectableText(
                block['arabic'] ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              SelectableText(
                block['latin'] ?? '',
                style: TextStyle(
                  color: secondaryColor.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
            ];
          }),
          if (translation != null) ...[
            const Divider(),
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
          ]
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
              "dikutip dari kitab al-adzkar karangan imam nawawi",
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
