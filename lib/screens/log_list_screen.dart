import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/abnormal_log.dart';
import 'video_player_screen.dart'; // 다음 단계에서 만들 플레이어 화면

class LogListScreen extends StatefulWidget {
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
      // TODO: 실제 백엔드 조회 URL로 변경 필요
      // 예시 더미 데이터 사용 (서버 연동 전 테스트용)
      await Future.delayed(Duration(seconds: 1)); // 로딩 흉내
      List<AbnormalLog> dummyLogs = [
        AbnormalLog(timestamp: '2024-05-24 14:10:00', videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
        AbnormalLog(timestamp: '2024-05-24 16:45:23', videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
      ];

      setState(() {
        _logs = dummyLogs;
        // _logs = serverData.map((json) => AbnormalLog.fromJson(json)).toList(); // 실제 연동 시
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이상행동 감지 기록'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: () {
            setState(() { _isLoading = true; });
            _fetchLogs();
          }),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? Center(child: Text('감지된 이상행동이 없습니다.'))
          : ListView.separated(
        itemCount: _logs.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final log = _logs[index];
          return ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red),
            ),
            title: Text(
              '이상행동 감지',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '발생 시간: ${log.timestamp}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            trailing: Icon(Icons.play_circle_fill, color: Colors.blue, size: 32),
            onTap: () {
              // 영상 재생 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(videoUrl: log.videoUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}