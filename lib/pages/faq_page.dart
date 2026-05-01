import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
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
  ];

  int? _expandedIndex;

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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: faqList.length,
                  itemBuilder: (context, index) {
                    final faq = faqList[index];
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
          decoration: InputDecoration(
            hintText: 'Cari pertanyaan...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'Poppins',
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFFB6C1)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
