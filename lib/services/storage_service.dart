import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song.dart';

class StorageService {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> addRecentSearch(Song song) async {
    final recentSearches = await getRecentSearches();
    
    // Remove if already exists
    recentSearches.removeWhere((s) => s.title == song.title && s.artist == song.artist);
    
    // Add to beginning
    recentSearches.insert(0, song);
    
    // Keep only last N searches
    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeLast();
    }

    // Save to storage
    await _prefs.setString(
      _recentSearchesKey,
      jsonEncode(recentSearches.map((s) => s.toJson()).toList()),
    );
  }

  Future<List<Song>> getRecentSearches() async {
    final String? searchesJson = _prefs.getString(_recentSearchesKey);
    if (searchesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(searchesJson);
    return decoded.map((json) => Song.fromJson(json)).toList();
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_recentSearchesKey);
  }
} 