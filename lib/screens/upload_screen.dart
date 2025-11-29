import 'dart:io';
import 'dart:convert'; // JSON 파싱을 위해 필요
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../models/abnormal_log.dart'; // 모델 import

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedVideo;
  VideoPlayerController? _thumbnailController;
  bool _isUploading = false;

  @override
  void dispose() {
    _thumbnailController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);
      _thumbnailController?.dispose();
      _thumbnailController = VideoPlayerController.file(videoFile);
      try {
        await _thumbnailController!.initialize();
        await _thumbnailController!.setVolume(0.0);
        if (_thumbnailController!.value.duration > Duration(seconds: 1)) {
          await _thumbnailController!.seekTo(Duration(seconds: 1));
        }
        await _thumbnailController!.pause();
        setState(() {
          _selectedVideo = videoFile;
        });
      } catch (e) {
        print("비디오 로드 에러: $e");
      }
    }
  }

  // [수정] 서버로 보내고 결과를 받아서 화면 이동
  Future<void> _uploadAndAnalyze() async {
    if (_selectedVideo == null) return;

    setState(() { _isUploading = true; });

    try {
      // ngrok 주소 확인 필수
      // [수정된 코드]
      var uri = Uri.parse('https://becomingly-vowless-peggy.ngrok-free.dev/upload');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _selectedVideo!.path));

      // 서버 응답 대기 (분석 시간에 따라 오래 걸릴 수 있음)
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // JSON 파싱
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> logsJson = jsonResponse['data']; // 서버가 보낸 리스트

        // 모델로 변환
        List<AbnormalLog> analysisResults = logsJson.map((json) => AbnormalLog(
          timestamp: json['timestamp'] ?? '',
          videoUrl: json['videoUrl'] ?? '', // 현재는 빈 문자열일 수 있음
          // type: json['type'] ?? '', // 모델에 type 필드가 있다면 추가
        )).toList();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('분석 완료!')));

          // 결과를 보여주는 화면으로 이동 (여기서는 LogListScreen을 재활용하거나 새로 만듦)
          // *주의: LogListScreen이 데이터를 받을 수 있게 수정해야 함.
          // 간단하게 결과를 팝업으로 띄우거나, LogListScreen에 전달.

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("분석 결과"),
              content: Container(
                width: double.maxFinite,
                height: 300,
                child: analysisResults.isEmpty
                    ? Center(child: Text("이상행동이 발견되지 않았습니다."))
                    : ListView.builder(
                  itemCount: analysisResults.length,
                  itemBuilder: (context, index) {
                    var log = analysisResults[index];
                    // AbnormalLog 모델에 'type' 필드가 없으면 timestamp만 표시됨
                    // 필요하면 모델에 type 필드 추가 권장
                    return ListTile(
                      leading: Icon(Icons.warning, color: Colors.red),
                      title: Text("이상행동 감지"),
                      subtitle: Text("시간: ${log.timestamp}"),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text("확인"))
              ],
            ),
          );
        }
      } else {
        print("서버 에러: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('분석 실패: 서버 오류')));
      }
    } catch (e) {
      print("에러: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러 발생: $e')));
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('영상 업로드 분석'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedVideo == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("분석할 영상을 선택해주세요", style: TextStyle(color: Colors.grey)),
                  ],
                )
                    : _thumbnailController != null && _thumbnailController!.value.isInitialized
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AspectRatio(
                    aspectRatio: _thumbnailController!.value.aspectRatio,
                    child: VideoPlayer(_thumbnailController!),
                  ),
                )
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.video_library),
                label: Text(_selectedVideo == null ? '갤러리에서 선택' : '다른 영상 선택'),
                onPressed: _pickVideo,
                style: OutlinedButton.styleFrom(padding: EdgeInsets.all(15)),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedVideo != null && !_isUploading) ? _uploadAndAnalyze : null,
                child: _isUploading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 15),
                    Text('영상 분석 중...'), // 텍스트 변경
                  ],
                )
                    : Text('업로드 및 분석 시작', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}