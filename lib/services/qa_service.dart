class QAService {
  // Database pertanyaan-jawaban tentang haid, nifas, istihadah
  late Map<String, List<String>> _qaDatabase;
  bool _isLoaded = false;

  QAService() {
    _loadData();
  }

  void _loadData() {
    _qaDatabase = {};

    // Menggunakan penjelasan lengkap sebelumnya sebagai basis pengetahuan
    const String knowledgeText = """
## 🩸 Definisi dan Batasan Darah Wanita

Menurut Madzhab Syafi'i, darah yang keluar dari kemaluan wanita setelah usia minimal haid (9 tahun Qamariyah) hanya terbagi menjadi tiga jenis: Haid, Nifas, dan Istihadah.

### 1. Haid (Menstruasi)
**Definisi:** Darah yang keluar dari kemaluan wanita secara teratur dalam kondisi sehat (bukan karena melahirkan atau penyakit).
**Batasan Waktu (Madzhab Syafi'i):**
* Minimal: Sehari semalam (24 jam). Jika kurang dari 24 jam, dihukumi Istihadah.
* Maksimal: 15 hari 15 malam. Jika darah keluar melebihi 15 hari, kelebihannya dihukumi Istihadah.
* Masa Suci Minimal: 15 hari 15 malam.
**Larangan:** Haram Shalat, Puasa (wajib qadha), Thawaf, Menyentuh/Membawa Mushaf, Membaca Al-Qur'an (niat tilawah), Berdiam di Masjid, Bersetubuh.

### 2. Nifas (Darah Setelah Melahirkan)
**Definisi:** Darah yang keluar dari kemaluan wanita setelah keluarnya seluruh janin.
**Batasan Waktu (Madzhab Syafi'i):**
* Minimal: Sebentar (satu lahdhah).
* Maksimal: 60 hari 60 malam. Jika darah keluar melebihi 60 hari, kelebihannya dihukumi Istihadah.
**Larangan:** Sama seperti Haid.

### 3. Istihadah (Darah Penyakit)
**Definisi:** Darah yang keluar di luar batas waktu Haid atau Nifas. Dianggap darah penyakit (darah urat).
**Hukum:** Wanita yang Istihadah dihukumi suci dari hadats besar. Wajib melaksanakan ibadah seperti Shalat dan Puasa.

## 🧼 Tata Cara Bersuci (Thaharah)
### Mandi Wajib Setelah Haid dan Nifas
* Wajib Niat (contoh: Nawaitul ghusla li raf'il hadatsil akbari minal haidhi fardhan lillahi ta'ala).
* Meratakan air ke seluruh badan, termasuk kulit kepala.

### Bersuci Bagi Wanita Istihadah
Diwajibkan bersuci khusus untuk **setiap shalat fardhu**:
1. Membersihkan kemaluan.
2. Menyumbat dan memakai pembalut (jika perlu).
3. Berwudhu **setelah masuk waktu shalat**.
4. Segera Shalat setelah berwudhu (tidak boleh menunda kecuali untuk kemaslahatan shalat).
5. Niat wudhu adalah untuk diperbolehkan shalat (bukan mengangkat hadats).
    """;

    // Split the text into manageable chunks based on newlines/headings
    final lines = knowledgeText
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // Helper function to find related sentences/lines
    List<String> findRelated(String keyword) {
      return lines.where((s) => s.toLowerCase().contains(keyword)).toList();
    }

    // Populate the database
    _qaDatabase['haid'] = findRelated('haid') + findRelated('menstruasi');
    _qaDatabase['nifas'] = findRelated('nifas');
    _qaDatabase['istihadah'] = findRelated('istihadah') + findRelated('istihadhah');
    _qaDatabase['batasan waktu haid'] = findRelated('minimal')
        .where((s) => s.toLowerCase().contains('haid') || s.toLowerCase().contains('suci'))
        .toList();
    _qaDatabase['batasan waktu nifas'] = findRelated('minimal')
        .where((s) => s.toLowerCase().contains('nifas'))
        .toList();
    _qaDatabase['larangan haid'] = findRelated('larangan');
    _qaDatabase['hukum istihadah'] = findRelated('hukum').where((s) => s.toLowerCase().contains('istihadah')).toList();
    _qaDatabase['tata cara bersuci istihadah'] = findRelated('wudhu') + findRelated('bersuci khusus');
    _qaDatabase['mandi wajib'] = findRelated('mandi wajib') + findRelated('niat')
        .where((s) => s.toLowerCase().contains('mandi')).toList();

    // Add default responses
    _qaDatabase['default'] = [
      'Maaf, saya tidak menemukan jawaban spesifik di basis pengetahuan untuk pertanyaan Anda. Saya dapat menjawab tentang definisi, batasan waktu, larangan, atau tata cara bersuci (mandi wajib/istihadah) dari haid, nifas, dan istihadah menurut Madzhab Syafi\'i.',
      'Silakan ajukan pertanyaan yang lebih spesifik mengenai Haid, Nifas, atau Istihadah berdasarkan penjelasan Madzhab Syafi\'i.',
    ];

    // Clean up lists (remove duplicates and markdown artifacts if any)
    _qaDatabase.forEach((key, value) {
      _qaDatabase[key] = value.toSet().toList().map((s) => s.replaceAll(RegExp(r'[\*\#]'), '').trim()).toList();
    });

    _isLoaded = true;
  }

  Future<String> getAnswer(String question) async {
    // Wait for data to load if not loaded
    while (!_isLoaded) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final lowerQuestion = question.toLowerCase();

    // Keywords prioritizing detail
    const prioritizedKeywords = [
      'tata cara bersuci istihadah', 'batasan waktu haid', 'batasan waktu nifas',
      'larangan haid', 'hukum istihadah', 'mandi wajib', 'haid', 'nifas', 'istihadah'
    ];

    // Cari keyword di database
    for (var keyword in prioritizedKeywords) {
      if (lowerQuestion.contains(keyword)) {
        final answers = _qaDatabase[keyword];
        if (answers != null && answers.isNotEmpty) {
          // Gabungkan beberapa jawaban terkait untuk konteks yang lebih kaya
          final selectedAnswers = answers.sublist(0, answers.length.clamp(1, 3)).join(' ');
          return selectedAnswers.trim();
        }
      }
    }
    
    // Fallback search for general topics
    for (var entry in _qaDatabase.entries) {
      if (entry.key != 'default' && lowerQuestion.contains(entry.key.split(' ').last)) {
         final answers = entry.value;
         if (answers.isNotEmpty) {
             final selectedAnswers = answers.sublist(0, answers.length.clamp(1, 2)).join(' ');
             return selectedAnswers.trim();
         }
      }
    }

    // Jika tidak ada match, kembalikan default
    final defaults = _qaDatabase['default'] ?? ['Maaf, data belum dimuat.'];
    return defaults[DateTime.now().millisecondsSinceEpoch % defaults.length];
  }

  List<String> getSuggestedQuestions() {
    return [
      'Apa definisi Haid menurut Syafi\'i?',
      'Apa saja larangan bagi wanita Haid?',
      'Berapa batas maksimal Nifas?',
      'Bagaimana tata cara bersuci bagi wanita Istihadah?',
      'Apa hukum wanita yang mengalami Istihadah?',
      'Bagaimana niat mandi wajib setelah Haid?',
    ];
  }
}