import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/abnormal_log.dart';
import 'video_player_screen.dart';

class LogListScreen extends StatefulWidget {
  final bool showAll;
  const LogListScreen({Key? key, this.showAll = true}) : super(key: key);

  @override
  _LogListScreenState createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  List<AbnormalLog> _logs = [];
  bool _isLoading = true;

  // [주의] 여기에 현재 실행 중인 ngrok 주소를 꼭 넣으세요! (끝에 슬래시 없음)
  final String baseUrl = "https://becomingly-vowless-peggy.ngrok-free.dev";

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  // 서버에서 진짜 로그 목록 가져오기
  Future<void> _fetchLogs() async {
    setState(() { _isLoading = true; });
    try {
      var uri = Uri.parse('$baseUrl/logs'); // /logs 엔드포인트 호출
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        List<AbnormalLog> fetchedLogs = data.map((json) {
          // 서버에서 준 videoUrl은 '/videos/...' 형태이므로 앞에 도메인을 붙여줌
          String fullVideoUrl = baseUrl + (json['videoUrl'] ?? '');

          return AbnormalLog(
            timestamp: "${json['upload_date']} (${json['timestamp']})", // 날짜 + 영상시간
            videoUrl: fullVideoUrl,
            // type: json['type'] ?? '알 수 없음', // 모델에 type이 있다면 추가
          );
        }).toList();

        setState(() {
          _logs = fetchedLogs.reversed.toList(); // 최신순 정렬
          _isLoading = false;
        });
      } else {
        throw Exception('서버 연결 실패');
      }
    } catch (e) {
      print("로그 불러오기 에러: $e");
      setState(() {
        _logs = []; // 에러 시 빈 리스트
        _isLoading = false;
      });

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('기록을 불러오지 못했습니다. 서버 상태를 확인하세요.')),
        );
      }
    }
  }

  // 로그 삭제 (현재는 앱 화면에서만 지움 - 실제 서버 삭제 API 필요 시 추가 구현)
  void _deleteLog(int index) {
    setState(() {
      _logs.removeAt(index);
    });
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
              onPressed: _fetchLogs // 새로고침 버튼
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? Center(child: Text('저장된 이상행동 기록이 없습니다.'))
          : ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: _logs.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Dismissible(
            key: Key(log.timestamp + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteLog(index),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.red[50],
                  child: Icon(Icons.warning_rounded, color: Colors.red),
                ),
                title: Text('이상행동 감지', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(log.timestamp, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                trailing: IconButton(
                  icon: Icon(Icons.play_circle_fill, color: Colors.blue, size: 32),
                  onPressed: () {
                    if (log.videoUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: log.videoUrl)),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}