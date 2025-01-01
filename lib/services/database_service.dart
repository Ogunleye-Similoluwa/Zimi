import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song.dart';
import '../models/playlist.dart';
import 'package:hive/hive.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String songsBoxName = 'songs';
  static const String historyBoxName = 'history';
  static const String searchHistoryBoxName = 'searchHistory';
  static const String cacheLyricsBoxName = 'cachedLyrics';
  static const String cacheImagesBoxName = 'cachedImages';
  static const String recentlyPlayedBoxName = 'recentlyPlayed';

  late SharedPreferences _prefs;
  Box<Song>? _songsBox;
  Box<Song>? _historyBox;
  Box<String>? _searchHistoryBox;
  Box<String>? _cacheLyricsBox;
  Box<List<int>>? _cacheImagesBox;
  Box<Song>? _recentlyPlayedBox;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();

    // Open boxes for other data
    _songsBox = await Hive.openBox<Song>(songsBoxName);
    _historyBox = await Hive.openBox<Song>(historyBoxName);
    _searchHistoryBox = await Hive.openBox<String>(searchHistoryBoxName);
    _cacheLyricsBox = await Hive.openBox<String>(cacheLyricsBoxName);
    _cacheImagesBox = await Hive.openBox<List<int>>(cacheImagesBoxName);
    _recentlyPlayedBox = await Hive.openBox<Song>(recentlyPlayedBoxName);

    _isInitialized = true;
  }

  // Favorites methods using SharedPreferences
  Future<void> toggleFavorite(Song song) async {
    final favorites = getFavorites();
    final songJson = song.toJson();
    
    if (isFavorite(song)) {
      favorites.removeWhere((s) => s['id'] == song.id);
    } else {
      favorites.add(songJson);
    }
    
    await _prefs.setString('favorites', jsonEncode(favorites));
  }

  bool isFavorite(Song song) {
    final favorites = getFavorites();
    return favorites.any((s) => s['id'] == song.id);
  }

  List<Map<String, dynamic>> getFavorites() {
    final String? data = _prefs.getString('favorites');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  List<Song> getFavoritesList() {
    return getFavorites().map((json) => Song.fromJson(json)).toList();
  }

  // Playlist methods using SharedPreferences
  Future<void> createPlaylist(Playlist playlist) async {
    final playlists = getPlaylistsJson();
    playlists.add(playlist.toJson());
    await _prefs.setString('playlists', jsonEncode(playlists));
  }

  Future<void> updatePlaylist(int index, Playlist playlist) async {
    final playlists = getPlaylistsJson();
    playlists[index] = playlist.toJson();
    await _prefs.setString('playlists', jsonEncode(playlists));
  }

  Future<void> deletePlaylist(int index) async {
    final playlists = getPlaylistsJson();
    playlists.removeAt(index);
    await _prefs.setString('playlists', jsonEncode(playlists));
  }

  Future<List<Playlist>> getPlaylists() async {
    final String? data = _prefs.getString('playlists');
    if (data == null) return [];
    final List<Map<String, dynamic>> jsonList = List<Map<String, dynamic>>.from(jsonDecode(data));
    return jsonList.map((json) => Playlist.fromJson(json)).toList();
  }

  List<Map<String, dynamic>> getPlaylistsJson() {
    final String? data = _prefs.getString('playlists');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  List<Playlist> getPlaylistsList() {
    final String? data = _prefs.getString('playlists');
    if (data == null) return [];
    final List<Map<String, dynamic>> jsonList = List<Map<String, dynamic>>.from(jsonDecode(data));
    return jsonList.map((json) => Playlist.fromJson(json)).toList();
  }

  // History methods using Hive
  Future<void> addToHistory(Song song) async {
    await _ensureInitialized();
    if (_historyBox == null) {
      _historyBox = await Hive.openBox<Song>(historyBoxName);
    }
    
    // Add with timestamp as key to maintain order
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _historyBox!.put(timestamp, song);
    
    // Keep only last 100 songs
    if (_historyBox!.length > 100) {
      final keysToDelete = _historyBox!.keys.take(_historyBox!.length - 100);
      await _historyBox!.deleteAll(keysToDelete);
    }
  }

  Future<List<Song>> getHistory() async {
    await _ensureInitialized();
    if (_historyBox == null) {
      _historyBox = await Hive.openBox<Song>(historyBoxName);
    }
    
    // Sort by timestamp (key) in reverse order
    final entries = _historyBox!.toMap().entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
      
    return entries.map((e) => e.value).toList();
  }

  // Cache methods using Hive
  Future<void> cacheLyrics(String songId, String lyrics) async {
    await _cacheLyricsBox!.put(songId, lyrics);
  }

  Future<String?> getCachedLyrics(String songId) async {
    return _cacheLyricsBox!.get(songId);
  }

  Future<void> cacheImage(String url, List<int> imageBytes) async {
    await _cacheImagesBox!.put(url, imageBytes);
  }

  Future<List<int>?> getCachedImage(String url) async {
    return _cacheImagesBox!.get(url);
  }

  // Recently played methods using Hive
  Future<void> addToRecentlyPlayed(Song song) async {
    final songId = '${song.title}_${song.artist}';
    await _recentlyPlayedBox!.put(songId, song);
    
    if (_recentlyPlayedBox!.length > 20) {
      final keysToDelete = _recentlyPlayedBox!.keys.take(_recentlyPlayedBox!.length - 20);
      await _recentlyPlayedBox!.deleteAll(keysToDelete);
    }
  }

  Future<List<Song>> getRecentlyPlayed() async {
    return _recentlyPlayedBox!.values.toList().reversed.toList();
  }

  Future<void> addSongToPlaylist(int index, Song song) async {
    final playlists = getPlaylistsList();
    if (index >= 0 && index < playlists.length) {
      playlists[index].songs.add(song);
      await updatePlaylist(index, playlists[index]);
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
} 