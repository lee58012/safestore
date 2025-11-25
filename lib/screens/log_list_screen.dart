import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 비교를 위해 추가
import 'package:http/http.dart' as http;
import '../models/abnormal_log.dart';
import 'video_player_screen.dart';

class LogListScreen extends StatefulWidget {
  final bool showAll; // true: 전체 보기, false: 오늘 날짜만 보기

  // 생성자에서 옵션을 받도록 수정 (기본값은 전체 보기)
  const LogListScreen({Key? key, this.showAll = true}) : super(key: key);

  @override
  _LogListScreenState createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  List<AbnormalLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  // 서버에서 로그 목록 가져오기
  Future<void> _fetchLogs() async {
    try {
      // TODO: 실제 백엔드 URL 연동 필요
      await Future.delayed(Duration(seconds: 1)); // 로딩 흉내

      // 더미 데이터 생성 (오늘 날짜 포함)
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      List<AbnormalLog> dummyLogs = [
        AbnormalLog(timestamp: '$today 14:10:00', videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
        AbnormalLog(timestamp: '$today 16:45:23', videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
        AbnormalLog(timestamp: '2023-05-20 09:00:00', videoUrl: ''), // 과거 데이터
      ];

      List<AbnormalLog> filteredLogs = dummyLogs;

      // 오늘 날짜만 보기 옵션인 경우 필터링
      if (!widget.showAll) {
        filteredLogs = dummyLogs.where((log) => log.timestamp.startsWith(today)).toList();
      }

      setState(() {
        _logs = filteredLogs;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() { _isLoading = false; });
    }
  }

  // 로그 삭제 함수
  void _deleteLog(int index) {
    // TODO: 실제 서버 삭제 API 호출 필요
    setState(() {
      _logs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("기록이 삭제되었습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showAll ? '전체 감지 기록' : '오늘의 감지 기록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() { _isLoading = true; });
                _fetchLogs();
              }
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? Center(child: Text('감지된 이상행동이 없습니다.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _logs.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final log = _logs[index];
          // Dismissible을 사용하여 스와이프 삭제 기능 추가
          return Dismissible(
            key: Key(log.timestamp + index.toString()),
            direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로 스와이프
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteLog(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_rounded, color: Colors.red, size: 24),
                ),
                title: Text(
                  '이상행동 감지',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${log.timestamp}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.play_circle_fill, color: Colors.blue, size: 32),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(videoUrl: log.videoUrl),
                          ),
                        );
                      },
                    ),
                    if (widget.showAll) // 전체 보기 탭에서만 명시적 삭제 버튼 표시 (옵션)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => _deleteLog(index),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}