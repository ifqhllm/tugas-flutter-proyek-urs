import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredFaqList = [];
  int? _expandedIndex;

  final List<Map<String, String>> faqList = [
    {
      "question": "Apa itu haid?",
      "answer": "Haid adalah darah yang keluar dari rahim wanita dalam kondisi normal, bukan karena penyakit atau melahirkan, yang terjadi pada waktu-waktu tertentu sesuai ketetapan Allah bagi kaum hawa."
    },
    {
      "question": "Berapa lama masa minimal dan maksimal haid?",
      "answer": "Menurut madzhab Syafi'i, masa minimal haid adalah sehari semalam (24 jam), sedangkan masa maksimalnya adalah 15 hari 15 malam. Kebiasaan umumnya adalah 6 atau 7 hari."
    },
    {
      "question": "Apa saja hal-hal yang dilarang saat haid?",
      "answer": "Hal-hal yang dilarang saat haid antara lain: Shalat, puasa, thawaf, menyentuh dan membawa mushaf Al-Qur'an, berdiam diri di masjid, serta berhubungan suami istri."
    },
    {
      "question": "Bagaimana cara bersuci setelah haid selesai?",
      "answer": "Cara bersuci dari haid adalah dengan mandi wajib (mandi junub) yang meliputi niat dan meratakan air ke seluruh bagian tubuh mulai dari ujung rambut hingga ujung kaki."
    },
    {
      "question": "Apakah boleh memotong kuku dan rambut saat haid?",
      "answer": "Tidak ada dalil yang shahih yang melarang memotong kuku atau rambut saat haid. Keduanya diperbolehkan dan tidak diwajibkan untuk memandikan potongan rambut atau kuku tersebut saat mandi wajib."
    },
    {
      "question": "Bagaimana hukum darah jika keluar lebih dari 15 hari bagi pemula (mubtada'ah)?",
      "answer": "Bagi wanita yang pertama kali haid (mubtada'ah), jika darah keluar melebihi 15 hari, maka 15 hari pertama dihukumi sebagai Haid dan sisa hari setelahnya dihukumi sebagai Istihadah (darah penyakit). Hal ini merupakan ketentuan syariat karena batas maksimal haid adalah 15 hari."
    },
    {
      "question": "Bagaimana hukum darah lebih dari 15 hari bagi wanita yang sudah punya kebiasaan (mu'tadah)?",
      "answer": "Bagi wanita yang sudah biasa haid (mu'tadah), jika darahnya keluar melebihi 15 hari, maka yang dihukumi sebagai haid dikembalikan pada durasi kebiasaan haidnya (adat) di bulan-bulan sebelumnya, sedangkan selebihnya dihukumi sebagai Istihadah."
    },
    {
      "question": "Apakah wajib mengqadha shalat jika suci dari haid di akhir waktu shalat?",
      "answer": "Menurut Madzhab Syafi'i, jika seorang wanita suci di waktu Ashar, ia wajib mengerjakan shalat Ashar dan mengqadha shalat Dzuhur. Jika ia suci di waktu Isya, ia wajib mengerjakan shalat Isya dan mengqadha shalat Maghrib. Hal ini berlaku jika sisa waktu shalat cukup untuk melakukan minimal satu rakaat (termasuk takbiratul ihram)."
    },
    {
      "question": "Apa itu darah Istihadah dan bagaimana kewajiban ibadahnya?",
      "answer": "Darah Istihadah adalah darah penyakit yang keluar di luar waktu haid dan nifas. Wanita yang istihadah (mustahadah) tetap dihukumi suci sehingga wajib shalat, puasa, dan boleh membaca Al-Qur'an. Sebelum shalat, ia wajib membersihkan kemaluannya, menyumbatnya dengan pembalut, berwudhu setiap kali masuk waktu shalat fardhu, dan langsung shalat tanpa menunda."
    },
    {
      "question": "Bagaimana hukum membaca Al-Qur'an lewat HP/Aplikasi digital saat haid?",
      "answer": "Diperbolehkan membaca atau menyentuh layar HP yang menampilkan ayat Al-Qur'an saat haid, karena HP/layar digital tidak dihukumi sebagai mushaf fisik Al-Qur'an. Namun, sangat dianjurkan untuk tidak melafalkan ayat Al-Qur'an dengan niat membaca (tilawah), melainkan diniatkan untuk dzikir, doa, atau belajar tafsir."
    },
    {
      "question": "Apa tanda utama berakhirnya masa haid (suci)?",
      "answer": "Ada dua tanda utama suci dari haid: 1) Keluarnya cairan putih bening (al-qassah al-baydha') dari kemaluan, atau 2) Kondisi benar-benar kering (al-jafaf) jika kapas/tisu yang dimasukkan ke kemaluan keluar dalam keadaan bersih tanpa ada bekas darah, cairan kuning, atau keruh."
    },
    {
      "question": "Bagaimana hukum cairan kuning (shufrah) atau keruh (kudrah)?",
      "answer": "Menurut Madzhab Syafi'i, cairan berwarna kuning atau keruh yang keluar pada hari-hari kemungkinan haid (dalam rentang 15 hari dari awal haid) dihukumi sebagai darah Haid. Jika keluar di luar rentang 15 hari atau setelah tanda suci yang jelas, maka dihukumi sebagai Istihadah/cairan biasa dan tidak mencegah shalat."
    },
    {
      "question": "Apakah boleh menunda shalat qadha puasa ramadhan bagi wanita haid?",
      "answer": "Wanita haid wajib mengqadha (mengganti) puasa Ramadhan yang ditinggalkannya. Waktu mengqadha puasa ini longgar mulai dari bulan Syawal hingga bulan Sya'ban berikutnya. Namun, sangat dianjurkan untuk segera mengqadhanya agar terbebas dari tanggungan syariat lebih cepat."
    },
    {
      "question": "Bagaimana jika haid tiba-tiba datang beberapa menit setelah waktu shalat masuk?",
      "answer": "Jika waktu shalat sudah masuk dan telah berlalu waktu yang cukup untuk melakukan shalat secara ringan (minimal durasi 1 rakaat atau pengerjaan shalat fardhu standar) namun ia belum sempat shalat lalu haidnya datang, maka ia wajib mengqadha shalat tersebut setelah suci kelak."
    },
    {
      "question": "Bagaimana hukum meminum obat/pil penunda haid untuk ibadah Haji atau Puasa?",
      "answer": "Secara fiqih, hukum meminum obat penunda haid diperbolehkan (mubah) asalkan obat tersebut aman dan direkomendasikan oleh dokter medis sehingga tidak menimbulkan bahaya (dharar) bagi kesehatan wanita tersebut."
    },
    {
      "question": "Apakah wanita haid boleh mendengarkan lantunan ayat Al-Qur'an?",
      "answer": "Boleh dan bahkan dianjurkan bagi wanita haid untuk mendengarkan bacaan Al-Qur'an, baik melalui murottal HP, radio, maupun bacaan orang lain. Mendengarkan Al-Qur'an mendatangkan rahmat dan pahala serta tidak termasuk dalam hal-hal yang dilarang saat haid."
    },
    {
      "question": "Apakah wanita haid tetap mendapatkan pahala ibadah sehari-hari?",
      "answer": "Ya, wanita haid tetap mendapatkan pahala penuh atas kebiasaan ibadah yang rutin ia lakukan saat suci (seperti shalat malam, puasa sunnah, dll.) berdasarkan kemurahan Allah. Selain itu, kepatuhannya untuk menjauhi larangan haid (seperti tidak shalat demi menaati syariat) juga dicatat sebagai bentuk ibadah dan ketaatan kepada Allah."
    },
    {
      "question": "Apa perbedaan mendasar antara Haid, Istihadah, dan Nifas?",
      "answer": "Haid adalah darah alami yang keluar secara periodik dari rahim dalam keadaan sehat. Istihadah adalah darah penyakit yang keluar di luar masa haid atau nifas. Sedangkan Nifas adalah darah yang keluar dari rahim wanita setelah melahirkan (persalinan), dengan masa maksimal 60 hari menurut madzhab Syafi'i."
    },
    {
      "question": "Bagaimana hukum darah terputus-putus (sehari keluar, sehari bersih) dalam rentang 15 hari?",
      "answer": "Dalam madzhab Syafi'i, hal ini diatur dalam hukum al-Sahb (menarik benang merah): hari-hari bersih di antara hari-hari keluarnya darah dalam rentang maksimal 15 hari semuanya ditarik/dihukumi sebagai masa Haid, dengan syarat total akumulasi durasi darah yang keluar mencapai minimal 24 jam."
    },
    {
      "question": "Ibadah apa saja yang tetap bisa dilakukan wanita saat sedang haid?",
      "answer": "Wanita haid tetap dapat melakukan banyak ibadah, antara lain: berdoa, membaca dzikir (pagi-petang, istighfar, tasbih, tahmid, tahlil), bershalawat kepada Nabi, membaca buku-buku agama/tafsir, bersedekah, melayani suami/keluarga, serta mendengarkan ceramah agama atau lantunan Al-Qur'an."
    }
  ];

  @override
  void initState() {
    super.initState();
    _filteredFaqList = faqList;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFaqList = faqList;
      } else {
        _filteredFaqList = faqList.where((faq) {
          final question = faq["question"]!.toLowerCase();
          final answer = faq["answer"]!.toLowerCase();
          return question.contains(query) || answer.contains(query);
        }).toList();
      }
      _expandedIndex = null; // Tutup accordion saat mencari
    });
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
              Color(0xFFFFF0F5), // Soft pink
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _filteredFaqList.isEmpty
                    ? Center(
                        child: Text(
                          'Pertanyaan tidak ditemukan.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredFaqList.length,
                        itemBuilder: (context, index) {
                          final faq = _filteredFaqList[index];
                          final isExpanded = _expandedIndex == index;
                          return FAQItem(
                            question: faq["question"]!,
                            answer: faq["answer"]!,
                            isExpanded: isExpanded,
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedIndex = null;
                                } else {
                                  _expandedIndex = index;
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
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
              'Tanya Jawab',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balancing space for back button
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari pertanyaan...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'Poppins',
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFFB6C1)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0, // 0.5 = 180 degrees
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFFFFB6C1),
                              ),
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Container(
                          height: isExpanded ? null : 0,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              answer,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: Colors.black.withOpacity(0.6),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: 4,
                color: const Color(0xFFFFB6C1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
