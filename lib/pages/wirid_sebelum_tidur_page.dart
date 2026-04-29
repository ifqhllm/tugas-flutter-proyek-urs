import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class WiridSebelumTidurPage extends StatefulWidget {
  final int materialNumber;

  const WiridSebelumTidurPage({super.key, this.materialNumber = 3});

  @override
  State<WiridSebelumTidurPage> createState() => _WiridSebelumTidurPageState();
}

class _WiridSebelumTidurPageState extends State<WiridSebelumTidurPage> {
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
              'Wirid Sebelum Tidur',
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
              'Ada 13 dzikir yang bisa diamalkan sebelum tidur. Semoga tidurnya penuh berkah, dapat ketenangan dan selamat dari gangguan.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          _buildContentBox(
            title: '1. Mengusap Tubuh dengan Ayat-ayat Perlindungan',
            faedah: 'Mengumpulkan dua telapak tangan. Lalu ditiup dan dibacakan surat Al Ikhlas, Al Falaq dan An Naas. Kemudian dua telapak tangan tersebut mengusap tubuh yang dapat dijangkau, dimulai dari kepala, wajah dan tubuh bagian depan. Semisal itu diulang sampai tiga kali.[1]',
            arabic: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ لَمْ يَلِدْ وَلَمْ يُولَدْ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ\n\nبِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِن شَرِّ مَا خَلَقَ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ\n\nبِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ النَّاسِ إِلَهِ النَّاسِ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ مِنَ الْجِنَّةِ وَ النَّاسِ',
            translation: '“Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang. Katakanlah: Dialah Allah, Yang Maha Esa. Allah adalah ilah yang bergantung kepada-Nya segala urusan. Dia tidak beranak dan tiada pula diperanakkan, dan tidak ada seorang pun yang setara dengan Dia.” (QS. Al Ikhlas: 1-4)\n\n“Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang. Katakanlah: Aku berlindung kepada Rabb yang menguasai Shubuh, dari kejahatan makhluk-Nya, dan dari kejahatan malam apabila telah gelap gulita, dan dari kejahatan-kejahatan wanita tukang sihir yang menghembus pada buhul-buhul, dan dari kejahatan orang yang dengki apabila ia dengki”. (QS. Al Falaq: 1-5)\n\n“Dengan menyebut nama Allah Yang Maha Pengasih lagi Maha Penyayang. Katakanlah: Aku berlindung kepada Rabb manusia. Raja manusia. Sembahan manusia, dari kejahatan (bisikan) syaitan yang biasa bersembunyi, yang membisikkan (kejahatan) ke dalam dada manusia, dari jin dan manusia.” (QS. An Naas: 1-6)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '2. Membaca Ayat Kursi',
            faedah: 'Faedah: Siapa yang membaca ayat Kursi sebelum tidur, maka ia akan terus dijaga oleh Allah dan terlindungi dari gangguan setan hingga pagi hari.[2]',
            translation: '“Allah, tidak ada ilah (yang berhak disembah) melainkan Dia, yang hidup kekal lagi terus menerus mengurus (makhluk-Nya). Dia tidak mengantuk dan tidak tidur. Kepunyaan-Nya apa yang di langit dan di bumi. Tiada yang dapat memberi syafa’at di sisi-Nya tanpa seizin-Nya. Dia mengetahui apa-apa yang di hadapan mereka dan di belakang mereka. Mereka tidak mengetahui apa-apa dari ilmu Allah melainkan apa yang dikehendaki-Nya. Kursi Allah meliputi langit dan bumi. Dia tidak merasa berat memelihara keduanya. Dan Dia Maha Tinggi lagi Maha besar.” (QS. Al Baqarah: 255)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '3. Membaca Surat Al Baqarah ayat 285-286',
            faedah: 'Faedah: Siapa yang membaca dua ayat tersebut pada malam hari, maka dua ayat tersebut telah memberi kecukupan baginya.[3]',
            arabic: 'آَمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ كُلٌّ آَمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ وَقَالُوا سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ * لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلاَّ وُسْعَهَا لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
            translation: '“Rasul telah beriman kepada Al-Qur’an yang diturunkan kepadanya dari Rabbnya, demikian pula orang-orang yang beriman. Semuanya beriman kepada Allah, malaikat-malaikat-Nya, kitab-kitab-Nya dan rasul-rasul-Nya. (Mereka mengatakan): “Kami tidak membeda-bedakan antara seorang pun (dengan yang lain) dari rasul-rasul-Nya”, dan mereka mengatakan: “Kami dengar dan kami ta’at”. (Mereka berdoa): “Ampunilah kami ya Rabb kami dan kepada Engkaulah tempat kembali”. Allah tidak membebani seseorang melainkan sesuai dengan kesanggupannya. Ia mendapat pahala (dari kebajikan) yang diusahakannya dan mendapat siksa (dari kejahatan) yang dikerjakannya. (Mereka berdoa): “Ya Rabb kami, janganlah Engkau hukum kami jika kami lupa atau kami bersalah. Ya Rabb kami, janganlah Engkau bebankan kepada kami beban yang berat sebagaimana Engkau bebankan kepada orang-orang yang sebelum kami. Ya Rabb kami, janganlah Engkau pikulkan kepada kami apa yang tak sanggup kami memikulnya. Beri maaflah kami; ampunilah kami; dan rahmatilah kami. Engkaulah Penolong kami, maka tolonglah kami terhadap kaum yang kafir“. (QS. Al Baqarah: 285-286)',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '4. Doa Sebelum Tidur I',
            arabic: 'بِاسْمِكَ رَبِّيْ وَضَعْتُ جَنْبِيْ، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِيْ فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِيْنَ',
            latin: 'Bismika robbi wadho’tu jambii, wa bika arfa’uh, fa-in amsakta nafsii farhamhaa, wa in arsaltahaa fahfazh-haa bimaa tahfazh bihi ‘ibaadakash shoolihiin.',
            translation: 'Artinya:\n“Dengan nama Engkau, wahai Rabbku, aku meletakkan lambungku. Dan dengan namaMu pula aku bangun daripadanya. Apabila Engkau menahan rohku (mati), maka berilah rahmat padanya. Tapi, apabila Engkau melepaskannya, maka peliharalah (dari kejahatan setan dan kejelekan dunia), sebagaimana Engkau memelihara hamba-hambaMu yang shalih.” (Dibaca 1 x)',
            faedah: 'Faedah: Apabila akan tidur, maka hendaklah tempat tidur tersebut dibersihkan karena siapa tahu ada kotoran yang membahayakan di situ, lalu membaca dzikir di atas.[4]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '5. Doa Sebelum Tidur II',
            arabic: 'اَللَّهُمَّ إِنَّكَ خَلَقْتَ نَفْسِيْ وَأَنْتَ تَوَفَّاهَا، لَكَ مَمَاتُهَا وَمَحْيَاهَا، إِنْ أَحْيَيْتَهَا فَاحْفَظْهَا، وَإِنْ أَمَتَّهَا فَاغْفِرْ لَهَا. اَللَّهُمَّ إِنِّيْ أَسْأَلُكَ الْعَافِيَةَ',
            latin: 'Allahumma innaka kholaqta nafsii wa anta tawaffaahaa, laka mamaatuhaa wa mahyaahaa, in ahyaytahaa fahfazh-haa, wa in ammatahaa faghfir lahaa. Allahumma innii as-alukal ‘aafiyah.',
            translation: 'Artinya:\n“Ya Allah, sesungguhnya Engkau menciptakan diriku, dan Engkaulah yang akan mematikannya. Mati dan hidupnya hanya milik-Mu. Apabila Engkau menghidupkannya, maka peliharalah (dari berbagai kejelekan). Apabila Engkau mematikannya, maka ampunilah. Ya Allah, sesungguhnya aku memohon kepada-Mu keselamatan.” (Dibaca 1 x)[5]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '6. Doa Sebelum Tidur III',
            arabic: 'اَللَّهُمَّ قِنِيْ عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
            latin: 'Allahumma qinii ‘adzaabak, yawma tab’atsu ‘ibaadak.',
            translation: 'Artinya:\n“Ya Allah, jauhkanlah aku dari siksaanMu pada hari Engkau membangkitkan hamba-hambaMu (yaitu pada hari kiamat).” (Dibaca 1 x).',
            faedah: 'Faedah: Apabila Rasulullah shallallahu’alaihi wa sallam hendak tidur, beliau meletakkan tangan kanannya di bawah pipinya, kemudian membaca dzikir di atas.[6]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '7. Doa Sebelum Tidur IV',
            arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوْتُ وَأَحْيَا',
            latin: 'Bismika allahumma amuutu wa ahyaa.',
            translation: 'Artinya:\n“Dengan namaMu, ya Allah! Aku mati dan hidup.” (Dibaca 1 x)[7]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '8. Tasbih, Tahmid, Takbir',
            arabic: 'سُبْحَانَ اللهِ (33×)\nالْحَمْدُ لِلَّهِ (33×)\nاللهُ أَكْبَرُ (34×)',
            latin: 'Subhanallah (33 x)\nAlhamdulillah (33 x)\nAllahu Akbar (34 x)',
            translation: 'Artinya:\n“Maha suci Allah (33 x), segala puji bagi Allah (33 x), Allah Maha Besar (34 x).”',
            faedah: 'Faedah: Bacaan di atas lebih baik daripada memiliki pembantu di rumah. Demikian dikatakan oleh Nabi shallallahu ‘alaihi wa sallam pada puterinya, Fatimah dan istri tercintanya, ‘Aisyah radhiyallahu ‘anhuma.[8]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '9. Doa Sebelum Tidur V',
            arabic: 'اَللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَرَبَّ الْعَرْشِ الْعَظِيْمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَاْلإِنْجِيْلِ وَالْفُرْقَانِ، أَعُوْذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ. اَللَّهُمَّ أَنْتَ اْلأَوَّلُ فَلَيْسَ قَبْلَكَ شَيْءٌ، وَأَنْتَ اْلآخِرُ فَلَيْسَ بَعْدَكَ شَيْءٌ، وَأَنْتَ الظَّاهِرُ فَلَيْسَ فَوْقَكَ شَيْءٌ، وَأَنْتَ الْبَاطِنُ فَلَيْسَ دُوْنَكَ شَيْءٌ، اِقْضِ عَنَّا الدَّيْنَ وَأَغْنِنَا مِنَ الْفَقْرِ',
            latin: 'Allahumma robbas-samaawaatis sab’i wa robbal ‘arsyil ‘azhiim, robbanaa wa robba kulli syai-in, faaliqol habbi wan-nawaa wa munzilat-tawrooti wal injiil wal furqoon. A’udzu bika min syarri kulli syai-in anta aakhidzum binaa-shiyatih. Allahumma antal awwalu falaysa qoblaka syai-un wa antal aakhiru falaysa ba’daka syai-un, wa antazh zhoohiru fa laysa fawqoka syai-un, wa antal baathinu falaysa duunaka syai-un, iqdhi ‘annad-dainaa wa aghninaa minal faqri.',
            translation: 'Artinya:\n“Ya Allah, Rabb yang menguasai langit yang tujuh, Rabb yang menguasai ‘Arsy yang agung, Rabb kami dan Rabb segala sesuatu. Rabb yang membelah butir tumbuh-tumbuhan dan biji buah, Rabb yang menurunkan kitab Taurat, Injil dan Furqan (Al-Qur’an). Aku berlindung kepadaMu dari kejahatan segala sesuatu yang Engkau memegang ubun-ubunnya (semua makhluk atas kuasa Allah). Ya Allah, Engkau-lah yang awal, sebelum-Mu tidak ada sesuatu. Engkaulah yang terakhir, setelahMu tidak ada sesuatu. Engkau-lah yang lahir, tidak ada sesuatu di atasMu. Engkau-lah yang Batin, tidak ada sesuatu yang luput dari-Mu[9]. Lunasilah utang kami dan berilah kami kekayaan (kecukupan) hingga terlepas dari kefakiran.”[10]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '10. Doa Sebelum Tidur VI',
            arabic: 'الْحَمْدُ لِلَّهِ الَّذِيْ أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا، فَكَمْ مِمَّنْ لاَ كَافِيَ لَهُ وَلاَ مُؤْوِيَ',
            latin: 'Alhamdulillahilladzi ath’amanaa wa saqoonaa wa kafaanaa wa aawaanaa, fakam mimman laa kaafiya lahu wa laa mu’wiya.',
            translation: 'Artinya:\n“Segala puji bagi Allah yang memberi makan kami, memberi minum kami, mencukupi kami, dan memberi tempat berteduh. Berapa banyak orang yang tidak mendapatkan siapa yang memberi kecukupan dan tempat berteduh.”[11]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '11. Doa Sebelum Tidur VII',
            arabic: 'اَللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَاْلأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيْكَهُ، أَشْهَدُ أَنْ لاَ إِلَـهَ إِلاَّ أَنْتَ، أَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِيْ، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِيْ سُوْءًا أَوْ أَجُرُّهُ إِلَى مُسْلِمٍ',
            latin: 'Allahumma ‘aalimal ghoybi wasy-syahaadah faathiros samaawaati wal ardh. Robba kulli syai-in wa maliikah. Asyhadu alla ilaha illa anta. A’udzu bika min syarri nafsii wa min syarrisy-syaythooni wa syirkihi, wa an aqtarifa ‘alaa nafsii suu-an aw ajurruhu ilaa muslim.',
            translation: 'Artinya:\n“Ya Allah, Rabb yang mengetahui yang ghaib dan yang nyata, Rabb pencipta langit dan bumi, Rabb yang menguasai segala sesuatu dan yang merajainya. Aku bersaksi bahwa tiada Rabb yang berhak disembah kecuali Engkau. Aku berlindung kepadaMu dari kejahatan diriku, kejahatan setan dan balatentaranya, atau aku berbuat kejelekan pada diriku atau aku mendorongnya kepada seorang Muslim.”',
            faedah: 'Faedah: Do’a ini diajarkan oleh Rasulullah shallallahu ‘alaihi wa sallam pada Abu Bakr Ash Shiddiq untuk dibaca pada pagi, petang dan saat akan tidur.[12]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '12. Membaca Surat As-Sajdah dan Al-Mulk',
            translation: 'Membaca “alif lam mim tanzil” (surat As-Sajdah) dan “tabaarokal ladzii biyadihil mulk” (surat Al Mulk).[13]',
          ),
          const SizedBox(height: 12),
          _buildContentBox(
            title: '13. Doa Sebelum Tidur VIII',
            arabic: 'اَللَّهُمَّ أَسْلَمْتُ نَفْسِيْ إِلَيْكَ، وَفَوَّضْتُ أَمْرِيْ إِلَيْكَ، وَوَجَّهْتُ وَجْهِيَ إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِيْ إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لاَ مَلْجَأَ وَلاَ مَنْجَا مِنْكَ إِلاَّ إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِيْ أَنْزَلْتَ وَبِنَبِيِّكَ الَّذِيْ أَرْسَلْتَ',
            latin: 'Allahumma aslamtu nafsii ilaik, wa fawwadh-tu amrii ilaik, wa wajjahtu wajhiya ilaik, wa alja’tu zhohrii ilaik, rogh-batan wa rohbatan ilaik, laa malja-a wa laa manjaa minka illa ilaik. Aamantu bikitaabikalladzi anzalta wa bi nabiyyikalladzi arsalta.',
            translation: 'Artinya:\n“Ya Allah, aku menyerahkan diriku kepadaMu, aku menyerahkan urusanku kepadaMu, aku menghadapkan wajahku kepadaMu, aku menyandarkan punggungku kepadaMu, karena senang (mendapatkan rahmatMu) dan takut pada (siksaanMu, bila melakukan kesalahan). Tidak ada tempat perlindungan dan penyelamatan dari (ancaman)Mu, kecuali kepadaMu. Aku beriman pada kitab yang telah Engkau turunkan, dan (kebenaran) NabiMu yang telah Engkau utus.” Apabila Engkau meninggal dunia (di waktu tidur), maka kamu akan meninggal dunia dengan memegang fitrah (agama Islam)”.',
            faedah: 'Faedah: Jika seseorang membaca dzikir di atas ketika hendak tidur lalu ia mati, maka ia mati di atas fithrah (mati di atas Islam).[14]',
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: secondaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 120,
              child: Scrollbar(
                thumbVisibility: true,
                child: const SingleChildScrollView(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SelectableText(
                    "[1] HR. Bukhari no. 5017 dan Muslim no. 2192.\n\n[2] HR. Bukhari no. 3275\n\n[3] HR. Bukhari no. 4008 dan Muslim no. 807.\n\n[4] HR. Al-Bukhari no. 6320 dan Muslim no. 2714.\n\n[5] HR. Muslim no. 2712.\n\n[6] HR. Tirmidzi no. 3398 dan Abu Daud no. 5045. Al Hafizh Abu Thohir mengatakan hadits ini shahih. Syaikh Al Albani mengkritik tentang penyebutan dzikir ini tiga kali. Yang tepat riwayat tersebut tanpa penyebutan tiga kali. Lihat As Silsilah Ash Shahihah no. 2754, 6: 588.\n\n[7] HR. Bukhari no. 6312 dan Muslim no. 2711.\n\n[8] HR. Bukhari no. 3705 dan Muslim no. 2727.\n\n[9] Maksud “فَلَيْسَ دُوْنَكَ شَيْءٌ” adalah kiasan akan ilmu Allah yang meliputi segala sesuatu. Walaupun Allah itu Maha Tinggi, akan tetapi Allah begitu dekat. Ketinggian Allah tidak menafikan kedekatan Allah. (Lihat Syarh Al ‘Aqidah Al Wasithiyah, hal. 113)\n\n[10] HR. Muslim no. 2713.\n\n[11] HR. Muslim no. 2715.\n\n[12] HR. Tirmidzi no. 3392 dan Abu Daud no. 5067. Al Hafizh Abu Thohir mengatakan bahawa sanad hadits ini shahih. Adapun kalimat terakhir (وَأَنْ أَقْتَرِفَ عَلَى نَفْسِيْ سُوْءًا أَوْ أَجُرُّهُ إِلَى مُسْلِمٍ) adalah tambahan dari riwayat Ahmad 2: 196. Dikomentari oleh Syaikh Syu’aib Al Arnauth bahwa hadits tersebut shahih dilihat dari jalur lainnya (shahih lighoirihi).\n\n[13] HR. Tirmidzi no. 3404. Al Hafizh Abu Thohir mengatakan bahwa hadits ini adalah hadits yang hasan.\n\n[14] HR. Al-Bukhari no. 6313 dan Muslim no. 2710.",
                    style: TextStyle(
                      color: Color(0xFF8B4513),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
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
