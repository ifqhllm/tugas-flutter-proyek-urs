import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class DzikirPetangPage extends StatefulWidget {
  final int materialNumber;

  const DzikirPetangPage({super.key, this.materialNumber = 2});

  @override
  State<DzikirPetangPage> createState() => _DzikirPetangPageState();
}

class _DzikirPetangPageState extends State<DzikirPetangPage> {
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
              'Dzikir Petang',
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
            title: '1. Membaca Ayat Kursi',
            arabic: 'اللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ الۡحَـىُّ الۡقَيُّوۡمُۚ لَا تَاۡخُذُهٗ سِنَةٌ وَّلَا نَوۡمٌؕ لَهٗ مَا فِى السَّمٰوٰتِ وَمَا فِى الۡاَرۡضِؕ مَنۡ ذَا الَّذِىۡ يَشۡفَعُ عِنۡدَهٗۤ اِلَّا بِاِذۡنِهٖؕ يَعۡلَمُ مَا بَيۡنَ اَيۡدِيۡهِمۡ وَمَا خَلۡفَهُمۡۚ وَلَا يُحِيۡطُوۡنَ بِشَىۡءٍ مِّنۡ عِلۡمِهٖۤ اِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرۡسِيُّهُ السَّمٰوٰتِ وَالۡاَرۡضَۚ وَلَا يَـــُٔوۡدُهٗ حِفۡظُهُمَا ۚ وَ هُوَ الۡعَلِىُّ الۡعَظِيۡمُ‏',
            latin: 'Allāhu Lā ilāha illā Huwa Al-Ḥayyu Al-Qayyūmu, Lā takhużuhū sinatun walā nawmun. Lahu mā fis-samāwāti wa mā fil-arḍ. Man żallazī yashfa\'u \'indahu illā bi-idhnihi. Ya\'lamu mā bayna aīdīhim wa mā khalfahum, wa lā yuḥīṭūna bishai\'in min \'ilmihi illā bimā shā\'. Wa si\'a kursīyuhu as-samāwāti wal-arḍa, wa lā ya\'ūduhu ḥifẓuhumā. Wa Huwa Al-\'Alīyu Al-\'Aẓīm.',
            translation: '"Allah, tidak ada tuhan selain Dia. Yang Mahahidup, Yang terus menerus mengurus (makhluk-Nya), tidak mengantuk dan tidak tidur. Milik-Nya apa yang ada di langit dan apa yang ada di bumi. Tidak ada yang dapat memberi syafaat di sisi-Nya tanpa izin-Nya. Dia mengetahui apa yang dihadapan mereka dan apa yang di belakang mereka, dan mereka tidak mengetahui sesuatu apa pun tentang ilmu-Nya melainkan apa yang Dia kehendaki. Kursi-Nya meliputi langit dan bumi. Dan Dia tidak merasa berat memelihara keduanya, dan Dia Mahatinggi, Mahabesar."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '2. Baca Surat Al-Ikhlas, Al-Falaq, dan An-Nas (3 Kali)',
            arabic: 'قُلْ هُوَ اللهُ أَحَدُ. اللَّهُ الصَّمَدُ. لَمْ يَلِدْ وَلَمْ يُولَدْ. وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ\n\nقُلۡ اَعُوۡذُ بِرَبِّ الۡفَلَقِۙ. مِنۡ شَرِّ مَا خَلَقَۙ. وَمِنۡ شَرِّ غَاسِقٍ اِذَا وَقَبَۙ. وَمِنۡ شَرِّ النَّفّٰثٰتِ فِى الۡعُقَدِۙ. وَمِنۡ شَرِّ حَاسِدٍ اِذَا حَسَدَ\n\nقُلْ اَعُوْذُ بِرَبِّ النَّاسِۙ. مَلِكِ النَّاسِۙ. اِلٰهِ النَّاسِۙ. مِنْ شَرِّ الْوَسْوَاسِ ەۙ الْخَنَّاسِۖ. الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِۙ. مِنَ الْجِنَّةِ وَالنَّاسِ ࣖ',
            latin: 'Qul huwa Allahu ahad, Allahu samad, lam yalid wa lam yulad, wa lam yakun lahu kufuwan ahad.\n\nQul a\'uzuu bi rabbil-falaq. Min sharri ma khalaq. Wa min sharri ghasiqin iza waqab. Wa min sharrin-naffaa-thaati fil \'uqad. Wa min shar ri haasidin iza hasad.\n\nQul a\'ụżu birabbin-nās, malikin-nās, ilāhin-nās, min sharril-waswāsil-khannās, allażī yuwas wisu fī ṣudụrin-nās, minal-jinnati wan-nās',
            translation: '"Katakanlah, \'Dia-lah Allah Yang Maha Esa. Allah adalah Tuhan yang bergantung kepada-Nya segala sesuatu. Dia tiada beranak dan tidak pula diperanakkan. Dan, tidak ada seorang pun yang setara dengan Dia." (QS. Al-Ikhlas: 1-4)\n\n"Katakanlah, "Aku berlindung kepada Tuhan yang menguasai subuh (fajar), dari kejahatan (makhluk yang) Dia ciptakan, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan (perempuan-perempuan) penyihir yang meniup pada buhul-buhul (talinya), dan dari kejahatan orang yang dengki apabila dia dengki." (QS. Al-Falaq: 1-5)\n\n"Aku berlindung kepada Tuhannya manusia, Raja manusia, Sembahan manusia, dari kejahatan (bisikan) setan yang bersembunyi yang membisikkan (kejahatan) ke dalam dada manusia, dari (golongan) jin dan manusia." (QS. An-Nas: 1-6)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '3. Baca Doa I',
            arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرُ اللَّهُمَّ أَسْأَلُكَ خَيْرَ هُذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا وَأَعُوْذُ بِكَ مِنْ شَرِّ هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا. اللَّهُمَّ إِنِّي أَعُوْذُ بِكَ مِنَ الْكَسَلِ وَسُوْءِ الْكِبَرِ اللَّهُمَّ إِنِّي أَعُوْذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
            latin: 'Amsainaa wa amsal muluk lillaaahi walhamdulillaahi laa ilaaha illallaahu wahdahuu laa syariika lah. Lahul mulku walahul hamdu wahuwa \'alaa kuli syai-in qadiir. Allaahumma as-aluka khaira maa fii haadzihil lailati wa khaira maa ba\'dahaa wa a\'uudzubika min syarri haadzihil lailati wasyarri maa ba\'dahaa. Allaahumma innii a\'uudzubika minal kasali wasuu-il kibari. Allaahumma innii a\'uudzubika min \'adzaabin finnaari wa \'adzaabin fil qabri.',
            translation: '"Kami telah memasuki waktu sore dan kerajaan hanya milik Allah, segala puji bagi Allah. Tidak ada Tuhan (yang berhak disembah) kecuali Allah Yang Maha Esa, tidak sekutu bagi-Nya. Bagi-Nya kerajaan dan bagi-Nya pujian. Dialah Yang Maha Kuasa atas segala sesuatu. Ya Allah, aku mohon kepada-Mu kebaikan pada hari ini dan kebaikan setelahnya. Aku berlindung kepada-Mu dari kejahatan hari ini dan kejahatan setelahnya. Ya Allah, aku berlindung kepada-Mu dari kemalasan dan kejelekan pada hari tua. Ya Allah, aku berlindung kepada-Mu dari siksaan di neraka dan kubur."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '4. Membaca Dzikir I',
            arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْنَا، وَبِكَ نَمُوْتُ وَإِلَيْكَ الْمَصِيرُ.',
            latin: 'Allaahumma bika amsainaa, wabika ashbahnaa, wabika nahnaa, wabika namuutu wa-ilaikal mashiir.',
            translation: '"Ya Allah, dengan rahmat dan pertolongan-Mu kami memasuki waktu petang, dan waktu pagi. Dengan rahmat dan pertolongan-Mu kami hidup dan kami mati. Dan, kepada-Mu tempat kembali."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '5. Baca Dzikir II',
            arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوْءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوْبَ إِلَّا أَنْتَ.',
            latin: 'Allaahumma anta rabbi laa ilaaha illaa anta, khalaqtanii wa ana \'abduka, wa ana \'alaa \'ahdika wawa\'dika mastatha\'tu, a\'uudzubika min syarri maa shana\'tu, abuu-u laka bini\'matika \'alayya, wa abuu-u bidzanbii faghfirlii fainnahuu laa yaghfirudz dzunuuba illaa anta.',
            translation: '"Ya Allah, Engkau adalah Tuhanku, tidak ada Tuhan yang berhak disembah kecuali Engkau. Engkaulah yang menciptakan aku. Aku adalah hamba-Mu. Aku akan setia pada perjanjianku dengan-Mu semampuku. Aku berlindung kepada-Mu dari kejelekan yang kuperbuat. Aku mengakui nikmat-Mu kepadaku dan aku mengakui dosaku. Oleh karena itu, ampunilah aku. Sesungguhnya, tidak ada yang mengampuni dosa kecuali Engkau."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '6. Baca Dzikir III (3 Kali)',
            arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ اللَّهُمَّ إِنِّي أَعُوْذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوْذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ.',
            latin: 'Allaahumma \'aafinii fii badani, allaahumma \'aafinii fii sam\'ii, allaahumma \'aafinii fii basharii, laa ilaaha illaa anta. Allaahumma innii a\'uudzubika minal kufri wal faqri, wa a\'uudzubika min \'adzaabil qabri, laa ilaaha illaa anta.',
            translation: '"Ya Allah, selamatkan tubuhku. Ya Allah, selamatkan pendengaranku. Ya Allah, selamatkan penglihatanku. Tidak ada Tuhan (yang berhak disembah) kecuali Engkau. Ya Allah, sesungguhnya aku berlindung kepada-Mu dari kekufuran dan kefakiran. Aku berlindung kepada-Mu dari siksa kubur, tidak ada Tuhan (yang berhak disembah) kecuali Engkau." (HR Abu Dawud, Ahmad, dan Nasa\'i)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '7. Membaca Dzikir IV',
            arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ. اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي. اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِيْنِيْ، وَعَنْ شِمَالِيْ، وَمِنْ فَوْقِيْ، وَأَعُوْذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِيْ.',
            latin: 'Allaahumma innii as-alukal \'afwa wal \'aafiyata fid dun-yaa wal aakhirah. Allaahumma innii as-alukal \'afwa wal \'aafiyata fii diinii wadun-yaaya wa ahlii wa maalii. Allaahummastur \'auraatii wa aamin rau\'aatii. Allaahummah-fazhnii min baini yadayya, wa min khalfii, wa \'an yamiinii, wa \'an syimaalii, wa min fauqii, wa a\'uudzu bi\'azhamatika an ughtaala min tahtii.',
            translation: '"Ya Allah, sesungguhnya aku memohon kebajikan dan keselamatan di dunia dan akhirat. Ya Allah, sesungguhnya aku memohon kebajikan dan keselamatan dalam agama, dunia, keluarga, dan hartaku. Ya Allah, tutupilah auratku (aib dan sesuatu yang tidak layak dilihat orang) dan tenteramkanlah aku dari rasa takut. Ya Allah, Peliharalah aku dari depan, belakang, kanan, kiri, dan atasku. Aku berlindung dengan kebesaran-Mu, agar aku tidak disambar dari bawahku." (HR Abu Dawud dan Ibnu Majah, Shahih Ibnu Majah 2/332)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '8. Membaca Doa II',
            arabic: 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيْكَهُ. أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوْءًا أَوْ أَجُرُّهُ إِلَى مُسْلِمٍ.',
            latin: 'Allaahumma \'aalimal ghaibi wasysyahaadati faathiras samaawaati wal ardhi, rabba kulli syai- in wamaliikahuu. Asyhadu allaa ilaaha illaa anta, a\'uudzubika min syarri nafsii, wamin syarrisy syaithaani wasyirkihii, wa an aqtarifa \'alaa nafsii suu-an aw ajurruhuu ilaa muslim.',
            translation: '"Ya Allah Yang Maha Mengetahui yang gaib dan yang nyata, wahai Tuhan pencipta langit dan bumi, Tuhan segala sesuatu dan yang merajainya. Aku bersaksi bahwa tidak ada Tuhan yang berhak disembah kecuali Engkau. Aku berlindung kepada-Mu dari kejahatan diriku, setan dan bala tentaranya, dan aku (berlindung kepada-Mu) dari berbuat kejelekan terhadap diriku atau menyeretnya kepada seorang muslim." (HR Tirmidzi dan Abu Dawud, Shahih At-Tirmidzi 3/142)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '9. Membaca Dzikir V (3 Kali)',
            arabic: 'بِسْمِ اللَّهِ لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
            latin: 'Bismillaahii laa yadhurru ma\'asmihi syai-un fil ardhi wa laa fissamaa-i wahuwas samii\'ul \'aliim.',
            translation: '"Dengan nama Allah yang jika disebut, segala sesuatu di bumi dan langit tidak akan berbahaya. Dialah Yang Maha Mendengar lagi Maha Mengetahui."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '10. Membaca Doa III',
            arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيْتُ، أَصْلِحْ لِي شَأْنِي كُلَهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.',
            latin: 'Yaa hayyu yaa qayyuumu birahmatika astaghiits, ashlih lil sya\'nii kullahuu walaa takilnii ilaa nafsii tharfata \'ainin.',
            translation: '"Wahai Tuhan Yang Maha Hidup, wahai Tuhan Yang Berdiri Sendiri, dengan rahmat-Mu aku meminta pertolongan, perbaikilah segala urusanku dan jangan diserahkan kepadaku sekalipun sekejap mata." (HR Hakim)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '11. Membaca Doa IV',
            arabic: 'أَمْسَيْنَا عَلَى فِطْرَةِ الْإِسْلَامِ وَعَلَى كَلِمَةِ الْإِخْلَاصِ وَعَلَى دِيْنِ نَبِيِّنَا مُحَمَّدٍ صَلَّ اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِيْنَا إِبْرَاهِيْمَ، حَنِيْفًا مُسْلِمًا وَمَا كَانَ مِنَ الْمُشْرِكِيْنَ.',
            latin: '"Amsainaa \'alaa fithratil islaami wa \'alaa kalimatil ikhlaashi, wa \'alaa diini nabiyyinaa muhammadin shallallaahu \'alaihi wasallama, wa \'alaa millati abiinaa ibraahiima, haniifam muslimaw wamaa kaana minal musyrikiin."',
            translation: '"Pada waktu petang kami memegang agama Islam, kalimat ikhlas, agama Nabi kita Muhammad, dan agama ayah kami Ibrahim, yang berdiri di atas jalan yang lurus, muslim dan tidak tergolong orang-orang musyrik."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '12. Baca Dzikir VI (100 Kali)',
            arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ.',
            latin: 'Subhaanallaahi wabihamdih.',
            translation: '"Maha Suci Allah sambil memuji-Nya."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '13. Baca Dzikir VII',
            arabic: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرُ.',
            latin: 'Laa ilaaha illallaahu wahdahuu laa syariika lah. lahul mulku walahul hamdu wahuwa \'alaa kulli syai-in qadiir.',
            translation: '"Tidak ada Tuhan yang berhak disembah selain Allah Yang Maha Esa, tidak ada sekutu bagi-Nya. Bagi-Nya kerajaan dan segala pujian. Dia-lah yang berkuasa atas segala sesuatu."',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '14. Baca Dzikir VIII (3 Kali)',
            arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
            latin: 'A\'uudzu bikalimaatillaahit taammaati min syarri maa khalaq.',
            translation: '"Aku berlindung dengan kalimat-kalimat Allah yang sempurna dari kejahatan makhluk yang diciptakan- Nya."',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContentBox({required String title, required String arabic, required String latin, required String translation}) {
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
              "Dikutip dari buku Dzikir Pagi Petang Imam An-Nawawi & Sa'id Al-Qahthani oleh H Brilly El-Rasheed, SPd",
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
