import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import 'dzikir_pagi_page.dart';
import 'dzikir_petang_page.dart';
import 'wirid_setelah_shalat_page.dart';
import 'wirid_sebelum_tidur_page.dart';
import 'wirid_istighfar_page.dart';
import 'doa_pertama_haid_page.dart';
import 'amalan_wanita_haid_page.dart';
import 'dzikir_tolak_bala_page.dart';
import 'doa_agar_selalu_bersyukur_page.dart';
import 'doa_saat_rasa_nyeri_datang_page.dart';
import 'doa_masuk_rumah_page.dart';
import 'doa_keluar_rumah_page.dart';
import 'doa_sebelum_tidur_page.dart';
import 'doa_bangun_tidur_page.dart';
import 'doa_masuk_kamar_mandi_page.dart';
import 'doa_keluar_kamar_mandi_page.dart';
import 'doa_sesudah_adzan_page.dart';

class WiridAndDuaPage extends StatefulWidget {
  const WiridAndDuaPage({super.key});

  @override
  State<WiridAndDuaPage> createState() => _WiridAndDuaPageState();
}

class _WiridAndDuaPageState extends State<WiridAndDuaPage> {
  int _selectedIndex = 0; // 0 for Wirid, 1 for Doa, 2 for Tasbih
  int _tasbihCount = 0;
  Set<int> _savedWiridBookmarks = {};
  Set<int> _savedDoaBookmarks = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWirid = prefs.getStringList('bookmarked_wirid') ?? [];
    final savedDoa = prefs.getStringList('bookmarked_doa') ?? [];
    setState(() {
      _savedWiridBookmarks = savedWirid.map((e) => int.parse(e)).toSet();
      _savedDoaBookmarks = savedDoa.map((e) => int.parse(e)).toSet();
    });
  }

  Future<void> _toggleBookmark(int number) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_selectedIndex == 0) {
        if (_savedWiridBookmarks.contains(number)) {
          _savedWiridBookmarks.remove(number);
        } else {
          _savedWiridBookmarks.add(number);
        }
      } else {
        if (_savedDoaBookmarks.contains(number)) {
          _savedDoaBookmarks.remove(number);
        } else {
          _savedDoaBookmarks.add(number);
        }
      }
    });

    final wiridBookmarks = _savedWiridBookmarks.map((e) => e.toString()).toList();
    final doaBookmarks = _savedDoaBookmarks.map((e) => e.toString()).toList();
    
    await prefs.setStringList('bookmarked_wirid', wiridBookmarks);
    await prefs.setStringList('bookmarked_doa', doaBookmarks);

    if (mounted) {
      final isSaved = _selectedIndex == 0
          ? _savedWiridBookmarks.contains(number)
          : _savedDoaBookmarks.contains(number);
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSaved ? 'Berhasil disimpan!' : 'Dihapus dari favorit',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: secondaryColor,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Sample data for wirid list
  final List<Map<String, dynamic>> _wiridList = [
    {'number': 1, 'title': 'Dzikir Pagi'},
    {'number': 2, 'title': 'Dzikir Petang'},
    {'number': 3, 'title': 'Wirid Sebelum Tidur'},
    {'number': 4, 'title': 'Wirid Setelah Shalat'},
    {'number': 5, 'title': 'Wirid Istighfar'},
    {'number': 6, 'title': 'Amalan Wanita Haid'},
  ];

  // Sample data for doa list
  final List<Map<String, dynamic>> _doaList = [
    {'number': 1, 'title': 'Doa Pertama Kali Haid'},
    {'number': 2, 'title': 'Doa Tolak Bala Wanita Haid'},
    {'number': 3, 'title': 'Doa Agar Selalu Bersyukur'},
    {'number': 4, 'title': 'Doa Saat Rasa Nyeri'},
    {'number': 5, 'title': 'Doa Masuk Rumah'},
    {'number': 6, 'title': 'Doa Keluar Rumah'},
    {'number': 7, 'title': 'Doa Sebelum Tidur'},
    {'number': 8, 'title': 'Doa Bangun Tidur'},
    {'number': 9, 'title': 'Doa Masuk Kamar Mandi'},
    {'number': 10, 'title': 'Doa Keluar Kamar Mandi'},
    {'number': 11, 'title': 'Doa Sesudah Adzan'},
  ];

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
              _buildAppBar(),
              if (_selectedIndex < 2) ...[
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildListView(),
                ),
              ] else ...[
                Expanded(
                  child: _buildTasbihView(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          _buildToggleSwitch(),
          if (_selectedIndex < 2)
            IconButton(
            icon: Icon(
              (_selectedIndex == 0 ? _savedWiridBookmarks : _savedDoaBookmarks).isNotEmpty
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: secondaryColor,
            ),
            onPressed: () {
              final hasAnyBookmark = (_selectedIndex == 0 ? _savedWiridBookmarks : _savedDoaBookmarks).isNotEmpty;
              if (hasAnyBookmark) {
                _showSavedMaterials();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Belum ada materi yang disimpan',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: secondaryColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSavedMaterials() {
    final currentList = _selectedIndex == 0 ? _wiridList : _doaList;
    final savedBookmarks = _selectedIndex == 0 ? _savedWiridBookmarks : _savedDoaBookmarks;
    final savedItems = currentList.where((item) => savedBookmarks.contains(item['number'])).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Materi Tersimpan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (savedItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Belum ada materi tersimpan di bagian ini',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ...savedItems.map((item) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${item['number']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      item['title'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await _toggleBookmark(item['number']);
                        Navigator.pop(context);
                        _showSavedMaterials();
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateWithRefresh(item);
                    },
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _navigateWithRefresh(Map<String, dynamic> item) {
    if (item['title'] == 'Dzikir Pagi') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DzikirPagiPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Dzikir Petang') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DzikirPetangPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Wirid Setelah Shalat') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WiridSetelahShalatPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Wirid Sebelum Tidur') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WiridSebelumTidurPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Wirid Istighfar') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WiridIstighfarPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Amalan Wanita Haid') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AmalanWanitaHaidPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Pertama Kali Haid') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaPertamaHaidPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Tolak Bala Wanita Haid') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DzikirTolakBalaPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Agar Selalu Bersyukur') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaAgarSelaluBersyukurPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Saat Rasa Nyeri') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaSaatRasaNyeriDatangPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Masuk Rumah') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaMasukRumahPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Keluar Rumah') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaKeluarRumahPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Sebelum Tidur') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaSebelumTidurPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Bangun Tidur') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaBangunTidurPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Masuk Kamar Mandi') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaMasukKamarMandiPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Keluar Kamar Mandi') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaKeluarKamarMandiPage())).then((_) => _loadBookmarks());
    } else if (item['title'] == 'Doa Sesudah Adzan') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaSesudahAdzanPage())).then((_) => _loadBookmarks());
    }
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Wirid', 0),
          _buildToggleButton('Doa', 1),
          _buildToggleButton('Tasbih', 2),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: _selectedIndex == 0 ? 'Cari Wirid' : 'Cari Doa',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final list = _selectedIndex == 0 ? _wiridList : _doaList;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildCard(list[index]);
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        _navigateWithRefresh(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              // Left side - Pink container with number
              Container(
                width: 50,
                height: 70,
                color: secondaryColor,
                child: Center(
                  child: Text(
                    '${item['number']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Center - Title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Right side - Bookmark icon (top right)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _toggleBookmark(item['number']),
                  child: Icon(
                    (_selectedIndex == 0 ? _savedWiridBookmarks : _savedDoaBookmarks).contains(item['number'])
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: secondaryColor.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasbihView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: secondaryColor.withOpacity(0.3),
                  width: 8,
                ),
              ),
              child: Center(
                child: Text(
                  '$_tasbihCount',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 320,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _tasbihCount++;
                  });
                },
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        secondaryColor,
                        primaryColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: -5,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'TAP',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Reset Button (Left)
              Positioned(
                bottom: 25,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _tasbihCount = 0;
                    });
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.refresh,
                        color: primaryColor,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              // Decrement Button (Right)
              Positioned(
                bottom: 25,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    if (_tasbihCount > 0) {
                      setState(() {
                        _tasbihCount--;
                      });
                    }
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.remove,
                        color: primaryColor,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
