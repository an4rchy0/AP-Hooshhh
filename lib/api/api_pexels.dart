import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/video_item.dart';

Future<List<VideoItem>> fetchVideos() async {
  final response = await http.get(
    Uri.parse('https://api.pexels.com/videos/search?query=dancing&orientation=portrait&size=medium'),
    headers: {
      'Authorization': '563492ad6f917000010000014e4c2d1ca31c4dc885a5369653c6f6b4', // Ganti dengan API kamu dari Pexels
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List videos = data['videos'];
    return videos.map<VideoItem>((video) {
      return VideoItem(url: video['video_files'][0]['link']);
    }).toList();
  } else {
    throw Exception('Failed to load videos');
  }
}
