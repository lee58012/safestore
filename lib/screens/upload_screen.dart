
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedVideo;
  bool _isUploading = false;

  // 갤러리에서 영상 선택
  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
      });
    }
  }

  // 서버로 영상 전송
  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() { _isUploading = true; });

    try {
      // TODO: 실제 백엔드 업로드 URL로 변경 필요
      var uri = Uri.parse('http://YOUR_BACKEND_IP:8000/upload');
      var request = http.MultipartRequest('POST', uri);

      // 파일 추가
      request.files.add(await http.MultipartFile.fromPath('file', _selectedVideo!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('분석 요청 성공!')));
        setState(() { _selectedVideo = null; }); // 초기화
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('업로드 실패: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('에러 발생: $e')));
    } finally {
      setState(() { _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _selectedVideo == null
              ? Icon(Icons.cloud_upload, size: 100, color: Colors.grey)
              : Icon(Icons.check_circle, size: 100, color: Colors.green),
          SizedBox(height: 20),
          Text(
            _selectedVideo == null ? '분석할 영상을 선택해주세요' : '영상 선택 완료',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),

          // 영상 선택 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(Icons.video_library),
              label: Text('갤러리에서 선택'),
              onPressed: _pickVideo,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.all(15)),
            ),
          ),
          SizedBox(height: 10),

          // 업로드 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedVideo != null && !_isUploading) ? _uploadVideo : null,
              child: _isUploading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('서버로 전송 및 분석 시작'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}