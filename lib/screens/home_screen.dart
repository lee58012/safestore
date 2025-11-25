
import 'package:flutter/material.dart';
import 'upload_screen.dart';
import 'log_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 탭별 화면 정의
  final List<Widget> _pages = [
    UploadScreen(),   // 0번 인덱스: 영상 업로드
    LogListScreen(),  // 1번 인덱스: 결과 리스트
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: '영상 분석',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '결과 리스트',
          ),
        ],
      ),
    );
  }
}