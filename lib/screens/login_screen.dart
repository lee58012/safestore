
import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  // 텍스트 입력을 제어하는 컨트롤러
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Safestore',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: 백엔드 로그인 API 연동 위치
                // 현재는 버튼 누르면 바로 메인 화면으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('로그인', style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {}, // 회원가입 화면 연결
              child: Text('계정이 없으신가요? 회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}