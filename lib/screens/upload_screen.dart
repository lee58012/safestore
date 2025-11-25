import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

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

  // 갤러리에서 영상 선택 및 썸네일 준비
  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);

      _thumbnailController?.dispose(); // 기존 컨트롤러 해제

      _thumbnailController = VideoPlayerController.file(videoFile);
      try {
        await _thumbnailController!.initialize();
        await _thumbnailController!.setVolume(0.0); // 소리 끄기

        // [수정된 부분] 갤러리 썸네일과 비슷하게 만들기 위해 '1초' 지점으로 이동
        // 영상 길이가 1초보다 길면 1초 지점의 화면을 보여줍니다.
        if (_thumbnailController!.value.duration > Duration(seconds: 1)) {
          await _thumbnailController!.seekTo(Duration(seconds: 1));
        }

        await _thumbnailController!.pause(); // 재생하지 않고 일시정지 상태 유지

        setState(() {
          _selectedVideo = videoFile;
        });
      } catch (e) {
        print("비디오 초기화 오류: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비디오를 불러오는 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  // 서버로 영상 전송
  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() { _isUploading = true; });

    try {
      // TODO: 실제 백엔드 IP로 변경 (예: http://192.168.0.5:8000/upload)
      var uri = Uri.parse('http://YOUR_BACKEND_IP:8000/upload');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('file', _selectedVideo!.path));

      var response = await request.send().timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('분석 요청 성공!')));
        setState(() {
          _selectedVideo = null;
          _thumbnailController?.dispose();
          _thumbnailController = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('업로드 실패: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('업로드 중 에러 발생: $e')));
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('영상 분석 요청'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
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
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedVideo != null && !_isUploading) ? _uploadVideo : null,
                child: _isUploading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 15),
                    Text('서버로 전송 중...'),
                  ],
                )
                    : Text('서버로 전송 및 분석 시작', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blue.withOpacity(0.5),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}