import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import 'pengertia_haid_page.dart';
import 'pengertia_nifas_page.dart';
import 'pentingnya_ilmu_darah_page.dart';
import 'hukum_mempelajari_ilmu_page.dart';
import 'warna_darah_haid_page.dart';
import 'masa_keluarnya_darah_haid_page.dart';
import 'masa_keluarnya_darah_nifas_page.dart';
import 'ketentuan_darah_haid_page.dart';
import 'masa_suci_page.dart';
import 'larangan_haid_nifas_page.dart';
import 'penghalang_sholat_page.dart';
import 'hal_mubah_haid_nifas_page.dart';
import 'tatacara_bersuci_page.dart';
import 'hukum_darah_terputus_page.dart';
import 'penyebab_haid_tidak_lancar_page.dart';
import 'mengatasi_mood_emosi_page.dart';
import 'manajemen_haid_sehat_page.dart';
import 'mengatasi_nyeri_haid_page.dart';
import 'pengertia_istihadah_page.dart';
import 'macam_istihadah_page.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  int _selectedIndex = 0;
  Set<int> _savedBookmarks = {};
  bool _isLoading = true;

  final List<String> _haidList = [
    'Pengertian haid',
    'Pengertian nifas',
    'Pentingnya ilmu darah kewanitaan',
    'Hukum mempelajari ilmu darah kewanitaan',
    'Warna dan sifat darah haid',
    'Masa keluarnya darah haid',
    'Masa keluarnya darah nifas',
    'Ketentuan darah haid',
    'Masa suc]i',
    'Larangan khusus bagi perempuan haid dan nifas',
    'Penghalang sholat',
    'Hal yang mubah saat haid dan nifas',
    'Tatacara bersuci setelah haid dan nifas',
    'Hukum jika darah terputus – putus',
    'Penyebab haid tidak lancar',
    'Mengatasi perubahan mood dan emosi',
    'Manajemen haid yang sehat',
    'Mengatasi nyeri haid',
  ];

  final List<String> _istihadahList = [
    'Pengertian istihadah',
    'Macam – macam - istihadah',
    'Hukum perempuan istihadah',
    'Kewajiban perempuan istihadah',
    'Tatacara Sholat dan bersuci',
    'Mustahadah (perempuan istihadah)',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHaid = prefs.getStringList('bookmarked_haid') ?? [];
    final savedIstihadah = prefs.getStringList('bookmarked_istihadah') ?? [];
    setState(() {
      _savedBookmarks = {
        ...savedHaid.map((e) => int.parse(e)),
        ...savedIstihadah.map((e) => int.parse(e)),
      };
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark(int number) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_savedBookmarks.contains(number)) {
        _savedBookmarks.remove(number);
      } else {
        _savedBookmarks.add(number);
      }
    });
    final haidBookmarks =
        _savedBookmarks.where((e) => e <= 18).map((e) => e.toString()).toList();
    final istihadahBookmarks =
        _savedBookmarks.where((e) => e > 18).map((e) => e.toString()).toList();
    await prefs.setStringList('bookmarked_haid', haidBookmarks);
    await prefs.setStringList('bookmarked_istihadah', istihadahBookmarks);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _savedBookmarks.contains(number)
                ? 'Berhasil disimpan!'
                : 'Dihapus dari favorit',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: secondaryColor,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _navigateToPage(int number) {
    if (_selectedIndex == 0) {
      if (number == 1) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PengertiaHaidPage()));
      } else if (number == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PengertiaNifasPage()));
      } else if (number == 3) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PentingnyaIlmuDarahPage()));
      } else if (number == 4) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const HukumMempelajariIlmuPage()));
      } else if (number == 5) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WarnaDarahHaidPage()));
      } else if (number == 6) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MasaKeluarnyaDarahHaidPage()));
      } else if (number == 7) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MasaKeluarnyaDarahNifasPage()));
      } else if (number == 8) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const KetentuanDarahHaidPage()));
      } else if (number == 9) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MasaSuciPage()));
      } else if (number == 10) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const LaranganHaidNifasPage()));
      } else if (number == 11) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PenghalangSholatPage()));
      } else if (number == 12) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const HalMubahHaidNifasPage()));
      } else if (number == 13) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TatacaraBersuciPage()));
      } else if (number == 14) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const HukumDarahTerputusPage()));
      } else if (number == 15) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PenyebabHaidTidakLancarPage()));
      } else if (number == 16) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MengatasiMoodEmosiPage()));
      } else if (number == 17) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ManajemenHaidSehatPage()));
      } else if (number == 18) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MengatasiNyeriHaidPage()));
      }
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
              _buildAppBar(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final hasAnyBookmark = _savedBookmarks.isNotEmpty;
    final listLength =
        _selectedIndex == 0 ? _haidList.length : _istihadahList.length;
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
          IconButton(
            icon: Icon(
              hasAnyBookmark ? Icons.bookmark : Icons.bookmark_border,
              color: secondaryColor,
            ),
            onPressed: () {
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
    final currentListLength =
        _selectedIndex == 0 ? _haidList.length : _istihadahList.length;
    final currentListStart = _selectedIndex == 0 ? 1 : 19;
    final savedInCurrentTab = _savedBookmarks
        .where((e) =>
            e >= currentListStart && e < currentListStart + currentListLength)
        .toList();

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
              if (savedInCurrentTab.isEmpty)
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
                ...savedInCurrentTab.map((num) {
                  final list = _selectedIndex == 0 ? _haidList : _istihadahList;
                  final title = list[num - currentListStart];
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
                          '$num',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await _toggleBookmark(num);
                        Navigator.pop(context);
                        _showSavedMaterials();
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToPage(num);
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

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Haid', 0),
          _buildToggleButton('Istihadah', 1),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            fontFamily: 'Poppins',
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
            hintText: 'Cari Materi',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontFamily: 'Poppins',
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
    final list = _selectedIndex == 0 ? _haidList : _istihadahList;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildCard(list[index], index + 1);
      },
    );
  }

  Widget _buildCard(String title, int number) {
    return GestureDetector(
      onTap: () {
        if (_selectedIndex == 0) {
          if (number == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PengertiaHaidPage()),
            );
          } else if (number == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PengertiaNifasPage()),
            );
          } else if (number == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PentingnyaIlmuDarahPage()),
            );
          } else if (number == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HukumMempelajariIlmuPage()),
            );
          } else if (number == 5) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WarnaDarahHaidPage()),
            );
          } else if (number == 6) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MasaKeluarnyaDarahHaidPage()),
            );
          } else if (number == 7) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MasaKeluarnyaDarahNifasPage()),
            );
          } else if (number == 8) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const KetentuanDarahHaidPage()),
            );
          } else if (number == 9) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MasaSuciPage()),
            );
          } else if (number == 10) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LaranganHaidNifasPage()),
            );
          } else if (number == 11) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PenghalangSholatPage()),
            );
          } else if (number == 12) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HalMubahHaidNifasPage()),
            );
          } else if (number == 13) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TatacaraBersuciPage()),
            );
          } else if (number == 14) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HukumDarahTerputusPage()),
            );
          } else if (number == 15) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PenyebabHaidTidakLancarPage()),
            );
          } else if (number == 16) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MengatasiMoodEmosiPage()),
            );
          } else if (number == 17) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ManajemenHaidSehatPage()),
            );
          } else if (number == 18) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MengatasiNyeriHaidPage()),
            );
          }
        } else if (_selectedIndex == 1) {
          if (number == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PengertiaIstihadahPage()),
            );
          } else if (number == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MacamIstihadahPage()),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 70,
                color: secondaryColor,
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    int adjustedNumber = number;
                    if (_selectedIndex == 1) {
                      adjustedNumber = number + 18;
                    }
                    _toggleBookmark(adjustedNumber);
                  },
                  child: Icon(
                    _savedBookmarks.contains(number) ||
                            (_selectedIndex == 1 &&
                                _savedBookmarks.contains(number + 18))
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: Color.fromRGBO(
                      secondaryColor.r.toInt(),
                      secondaryColor.g.toInt(),
                      secondaryColor.b.toInt(),
                      0.7,
                    ),
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
}
