import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../constants/colors.dart';

class WiridAndDuaPage extends StatefulWidget {
  const WiridAndDuaPage({super.key});

  @override
  State<WiridAndDuaPage> createState() => _WiridAndDuaPageState();
}

class _WiridAndDuaPageState extends State<WiridAndDuaPage> {
  int _selectedIndex = 0; // 0 for Wirid, 1 for Doa
  
  // Sample data for wirid list
  final List<Map<String, dynamic>> _wiridList = [
    {'number': 1, 'title': 'Wirid Pagi'},
    {'number': 2, 'title': 'Wirid Sore'},
    {'number': 3, 'title': 'Wirid Sebelum Tidur'},
    {'number': 4, 'title': 'Wirid Setelah Shalat'},
    {'number': 5, 'title': 'Wirid Tasbih'},
    {'number': 6, 'title': 'Wirid Istighfar'},
    {'number': 7, 'title': 'Wirid Shalawat'},
    {'number': 8, 'title': 'Wirid Dzikir'},
    {'number': 9, 'title': 'Wirid Hari Jumat'},
    {'number': 10, 'title': 'Wirid Akhir Bulan'},
  ];

  // Sample data for doa list
  final List<Map<String, dynamic>> _doaList = [
    {'number': 1, 'title': 'Doa Sesudah Shalat'},
    {'number': 2, 'title': 'Doa Perlindungan'},
    {'number': 3, 'title': 'Doa Rezeki'},
    {'number': 4, 'title': 'Doa Kesehatan'},
    {'number': 5, 'title': 'Doa Orang Tua'},
    {'number': 6, 'title': 'Doa Nikah'},
    {'number': 7, 'title': 'Doa Safar'},
    {'number': 8, 'title': 'Doa Makan'},
    {'number': 9, 'title': 'Doa Minum'},
    {'number': 10, 'title': 'Doa Tidur'},
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
              // TODO: Navigate to bookmarked items
            },
          ),
        ],
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 16),
              // List View
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
          _buildToggleButton('Wirid', 0),
          _buildToggleButton('Doa', 1),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.white,
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
            hintText: _selectedIndex == 0 ? 'Cari Wirid' : 'Cari Doa',
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
