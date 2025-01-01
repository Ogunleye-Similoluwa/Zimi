import 'package:flutter/material.dart';
import 'package:zimi/blocs/song_bloc.dart';
import 'package:zimi/widgets/create_playlist_dialog.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/database_service.dart';
import '../widgets/animated_playlist_card.dart';
import '../widgets/song_tile.dart';
import '../screens/playlist_screen.dart';
import '../screens/lyrics_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SongBloc, SongState>(
      listener: (context, state) {
        if (state is FavoriteToggled || state is PlaylistUpdated) {
          setState(() {});
        }
      },
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Playlists'),
              Tab(text: 'Favorites'),
              Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                setState(() {});
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlaylistsGrid(),
                  _buildFavoritesList(),
                  _buildHistoryList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return BlocBuilder<SongBloc, SongState>(
      buildWhen: (previous, current) => current is FavoriteToggled,
      builder: (context, state) {
        final songs = _db.getFavoritesList();
        
        if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: songs.length,
          itemBuilder: (context, index) => SongTile(
            song: songs[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LyricsScreen(song: songs[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return FutureBuilder<List<Song>>(
      future: _db.getHistory(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading history: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final songs = snapshot.data!;
        if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No listening history yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            return SongTile(
              song: songs[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LyricsScreen(song: songs[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsGrid() {
    return BlocBuilder<SongBloc, SongState>(
      buildWhen: (previous, current) => current is PlaylistUpdated,
      builder: (context, state) {
        final playlists = _db.getPlaylistsList();
        
        if (playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.queue_music, size: 64, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No playlists yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const CreatePlaylistDialog(),
                  ),
                  child: const Text('Create Playlist'),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) => AnimatedPlaylistCard(
            playlist: playlists[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistScreen(
                  playlist: playlists[index],
                  playlistIndex: index,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 