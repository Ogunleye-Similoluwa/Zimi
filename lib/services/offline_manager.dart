import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'database_service.dart';

class OfflineManager {
  final DatabaseService _db;
  final _connectivityStream = BehaviorSubject<bool>();

  OfflineManager(this._db) {
    _initConnectivity();
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      _connectivityStream.add(result != ConnectivityResult.none);
    });
  }

  Stream<bool> get isOnline => _connectivityStream.stream;

  Future<void> cacheForOffline(String songId, String lyrics, List<int> albumArt) async {
    await _db.cacheLyrics(songId, lyrics);
    await _db.cacheImage(songId, albumArt);
  }

  Future<bool> isContentCached(String songId) async {
    final hasLyrics = await _db.getCachedLyrics(songId) != null;
    final hasImage = await _db.getCachedImage(songId) != null;
    return hasLyrics && hasImage;
  }

  void dispose() {
    _connectivityStream.close();
  }
} 