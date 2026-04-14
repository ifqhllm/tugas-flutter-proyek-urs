import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../constants/colors.dart';

class DuaPage extends StatefulWidget {
  const DuaPage({super.key});

  @override
  State<DuaPage> createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  int _selectedIndex = 0; // 0 for Haid, 1 for Istihadah, 2 for Nifas
  
  final List<Map<String, dynamic>> _haidList = [
    {'number': 1, 'title': 'Pengertian Haid'},
    {'number': 2, 'title': 'Tanda-tanda Haid'},
    {'number': 3, 'title': 'Lama Haid dalam Islam'},
    {'number': 4, 'title': 'Hukum Haid dalam Islam'},
    {'number': 5, 'title': 'Things yang Harus Dihindari Saat Haid'},
    {'number': 6, 'title': 'Bacaan Doa saat Haid'},
    {'number': 7, 'title': 'Cara Mandi Wajib setelah Haid'},
    {'number': 8, 'title': 'Qadha Puasa saat Haid'},
    {'number': 9, 'title': 'Qadha Shalat saat Haid'},
    {'number': 10, 'title': 'Haid Setelah Melahirkan'},
  ];

  final List<Map<String, dynamic>> _istihadahList = [
    {'number': 1, 'title': 'Pengertian Istihadah'},
    {'number': 2, 'title': 'Perbedaan Haid dan Istihadah'},
    {'number': 3, 'title': 'Hukum Istihadah dalam Islam'},
    {'number': 4, 'title': 'Lama Istihadah'},
    {'number': 5, 'title': 'Shalat saat Istihadah'},
    {'number': 6, 'title': 'Puasa saat Istihadah'},
    {'number': 7, 'title': 'Bacaan Doa saat Istihadah'},
    {'number': 8, 'title': 'Wudhu saat Istihadah'},
    {'number': 9, 'title': 'Hukum Hubungan Intim saat Istihadah'},
    {'number': 10, 'title': 'Mandi Wajib setelah Istihadah'},
  ];

  final List<Map<String, dynamic>> _nifasList = [
    {'number': 1, 'title': 'Pengertian Nifas'},
    {'number': 2, 'title': 'Lama Nifas dalam Islam'},
    {'number': 3, 'title': 'Hukum Nifas dalam Islam'},
    {'number': 4, 'title': 'Tanda-tanda Selesai Nifas'},
    {'number': 5, 'title': 'Shalat saat Nifas'},
    {'number': 6, 'title': 'Puasa saat Nifas'},
    {'number': 7, 'title': 'Bacaan Doa saat Nifas'},
    {'number': 8, 'title': 'Cara Mandi Wajib setelah Nifas'},
    {'number': 9, 'title': 'Qadha Ibadah saat Nifas'},
    {'number': 10, 'title': 'Nifas dan Hubungan Intim'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildToggleSwitch(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
            ),
            onPressed: () {
            },
          ),
        ],
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
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

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton('Haid', 0),
          _buildToggleButton('Istihadah', 1),
          _buildToggleButton('Nifas', 2),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    String hintText;
    switch (_selectedIndex) {
      case 0:
        hintText = 'Cari Materi Haid';
        break;
      case 1:
        hintText = 'Cari Materi Istihadah';
        break;
      case 2:
        hintText = 'Cari Materi Nifas';
        break;
      default:
        hintText = 'Cari';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
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
    final list;
    switch (_selectedIndex) {
      case 0:
        list = _haidList;
        break;
      case 1:
        list = _istihadahList;
        break;
      case 2:
        list = _nifasList;
        break;
      default:
        list = _haidList;
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildCard(list[index]);
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
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
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.bookmark_border,
                color: secondaryColor.withOpacity(0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
