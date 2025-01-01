import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/song.dart';

class YouTubeService {
  static const _apiKey = 'AIzaSyBf_kuJONS8Eaf-pZcwK7y2yXaVGdrHRVc';

  Future<String?> searchVideo(Song song) async {
    try {
      // Create a more specific search query
      final searchQuery = Uri.encodeComponent(
        '${song.artist} - ${song.title} official music video'
      );
      
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search'
        '?part=snippet'
        '&q=$searchQuery'
        '&type=video'
        '&videoCategoryId=10' // Music category
        '&maxResults=1'
        '&key=$_apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items']?.isNotEmpty ?? false) {
          return data['items'][0]['id']['videoId'];
        }
      }
      return null;
    } catch (e) {
      print('Error searching YouTube video: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos'
        '?part=contentDetails,snippet'
        '&id=$videoId'
        '&key=$_apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items']?.isNotEmpty ?? false) {
          return data['items'][0];
        }
      }
      return null;
    } catch (e) {
      print('Error getting video details: $e');
      return null;
    }
  }
} 