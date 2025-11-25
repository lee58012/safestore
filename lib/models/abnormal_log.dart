class AbnormalLog {
  final String timestamp; // 이상행동 발생 시간 (예: 2024-05-20 14:30:05)
  final String videoUrl;  // 해당 시점의 영상 URL

  AbnormalLog({
    required this.timestamp,
    required this.videoUrl,
  });

  // 서버 JSON 데이터를 객체로 변환
  factory AbnormalLog.fromJson(Map<String, dynamic> json) {
    return AbnormalLog(
      timestamp: json['timestamp'] ?? 'Unknown Time',
      videoUrl: json['video_url'] ?? '',
    );
  }
}