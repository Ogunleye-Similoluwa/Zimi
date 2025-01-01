import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zimi/models/timed_lyrics.dart';
import 'package:zimi/screens/playlist_screen.dart';
import '../models/song.dart';
import '../services/lyrics_service.dart';
import '../services/song_matching_service.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../services/share_service.dart';

// Events
abstract class SongEvent {}

class RecognizeSong extends SongEvent {}
class SearchSongs extends SongEvent {
  final String query;
  SearchSongs(this.query);
}

class ToggleFavorite extends SongEvent {
  final Song song;
  ToggleFavorite(this.song);
}

class PlaySongs extends SongEvent {
  final List<Song> songs;
  final int startIndex;
  PlaySongs({required this.songs, required this.startIndex});
}

class AddSongsToQueue extends SongEvent {
  final List<Song> songs;
  final PlaybackPosition position;
  AddSongsToQueue({required this.songs, required this.position});
}

class ShareSong extends SongEvent {
  final Song song;
  ShareSong(this.song);
}

class AddToRecentlyPlayed extends SongEvent {
  final Song song;
  AddToRecentlyPlayed(this.song);
}

class AddToPlaylist extends SongEvent {
  final Song song;
  final int playlistIndex;
  AddToPlaylist(this.song, this.playlistIndex);
}

// States
abstract class SongState {}

class SongInitial extends SongState {}
class SongLoading extends SongState {}
class SongRecognized extends SongState {
  final Song song;
  SongRecognized(this.song);
}
class SongError extends SongState {
  final String message;
  SongError(this.message);
}
class SongsLoaded extends SongState {
  final List<Song> songs;
  SongsLoaded(this.songs);
}
class FavoriteToggled extends SongState {
  final bool isFavorite;
  FavoriteToggled(this.isFavorite);
}
class PlaylistUpdated extends SongState {}
class SongShared extends SongState {}
class RecentlyPlayedUpdated extends SongState {}

// Bloc
class SongBloc extends Bloc<SongEvent, SongState> {
  final LyricsService lyricsService;
  final SongMatchingService songMatchingService;
  final StorageService storageService;
  final DatabaseService databaseService;
  final ShareService shareService;

  // Add these fields to manage queue
  List<Song> _queue = [];
  int _currentIndex = 0;

  // Add getters
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _queue.isNotEmpty ? _queue[_currentIndex] : null;

  LyricsService get getLyricsService => lyricsService;

  SongBloc(
    this.lyricsService,
    this.songMatchingService,
    this.storageService,
    this.databaseService,
    this.shareService,
  ) : super(SongInitial()) {
    on<RecognizeSong>((event, emit) => _onRecognizeSong(event, emit));
    on<SearchSongs>((event, emit) => _onSearchSongs(event, emit));
    on<ToggleFavorite>((event, emit) => _onToggleFavorite(event, emit));
    on<PlaySongs>((event, emit) => _onPlaySongs(event, emit));
    on<AddSongsToQueue>((event, emit) => _onAddSongsToQueue(event, emit));
    on<ShareSong>((event, emit) => _onShareSong(event, emit));
    on<AddToRecentlyPlayed>((event, emit) => _onAddToRecentlyPlayed(event, emit));
    on<AddToPlaylist>((event, emit) => _onAddToPlaylist(event, emit));
  }

  Future<void> _onRecognizeSong(RecognizeSong event, Emitter<SongState> emit) async {
    try {
      emit(SongLoading());
      print('Starting song recognition...'); // Debug print
      
      final song = await songMatchingService.startRecognition();
      
      if (song != null) {
        print('Song found: ${song.title}'); // Debug print
        await _fetchLyricsAndSave(song);
        emit(SongRecognized(song));
      } else {
        print('No song found'); // Debug print
        emit(SongError('No song found'));
      }
    } catch (e) {
      print('Error in recognition: $e'); // Debug print
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onSearchSongs(SearchSongs event, Emitter<SongState> emit) async {
    try {
      emit(SongLoading());
      final songs = await lyricsService.searchSongs(event.query);
      emit(SongsLoaded(songs));
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _fetchLyricsAndSave(Song song) async {
    if (song.youtubeId.isNotEmpty) {
      final lyrics = await lyricsService.getLyrics(
        song.artist, 
        song.title,
      );
      song.lyrics = lyrics;
      await storageService.addRecentSearch(song);
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<SongState> emit) async {
    try {
      await databaseService.toggleFavorite(event.song);
      event.song.isFavorite = !event.song.isFavorite; // Update the song's state
      emit(FavoriteToggled(event.song.isFavorite));
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onPlaySongs(PlaySongs event, Emitter<SongState> emit) async {
    try {
      // Replace current queue with new playlist
      _queue = List.from(event.songs);
      _currentIndex = event.startIndex;
      
      final currentSong = _queue[_currentIndex];
      await databaseService.addToRecentlyPlayed(currentSong);
      
      // Get lyrics if needed
      if (currentSong.lyrics.isEmpty) {
        final lyrics = await lyricsService.getLyrics(
          currentSong.artist,
          currentSong.title,
        );
        currentSong.lyrics = lyrics;
      }
      
      emit(SongRecognized(currentSong));
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onAddSongsToQueue(AddSongsToQueue event, Emitter<SongState> emit) async {
    try {
      if (event.position == PlaybackPosition.next) {
        // Insert songs after current song
        _queue.insertAll(_currentIndex + 1, event.songs);
      } else {
        // Add songs to end of queue
        _queue.addAll(event.songs);
      }
      emit(PlaylistUpdated());
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onShareSong(ShareSong event, Emitter<SongState> emit) async {
    await shareService.shareSong(event.song);
    emit(SongShared());
  }

  Future<void> _onAddToRecentlyPlayed(AddToRecentlyPlayed event, Emitter<SongState> emit) async {
    await databaseService.addToRecentlyPlayed(event.song);
    emit(RecentlyPlayedUpdated());
  }

  Future<void> _onAddToPlaylist(AddToPlaylist event, Emitter<SongState> emit) async {
    await databaseService.addSongToPlaylist(event.playlistIndex, event.song);
    emit(PlaylistUpdated());
  }

  // Add methods to control playback
  void playNext() {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _queue.length;
    add(PlaySongs(songs: _queue, startIndex: _currentIndex));
  }

  void playPrevious() {
    if (_queue.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    add(PlaySongs(songs: _queue, startIndex: _currentIndex));
  }

  Future<bool> isFavorite(Song song) async {
    return databaseService.isFavorite(song);
  }

  // StorageService get storageService => storageService;
} 
