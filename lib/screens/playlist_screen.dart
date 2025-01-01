import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zimi/models/song.dart';
import 'package:zimi/screens/lyrics_screen.dart';
import '../models/playlist.dart';
import '../widgets/reorderable_playlist.dart';
import '../services/database_service.dart';
import '../widgets/create_playlist_dialog.dart';
import '../blocs/song_bloc.dart';
import '../services/theme_service.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final int playlistIndex;

  const PlaylistScreen({
    super.key,
    required this.playlist,
    required this.playlistIndex,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SongBloc, SongState>(
      listener: (context, state) {
        if (state is SongError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.play_circle_filled, size: 32),
              onPressed: _playPlaylist,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'play_next',
                  child: Row(
                    children: [
                      const Icon(Icons.queue_music),
                      const SizedBox(width: 12),
                      const Text('Play Next'),
                    ],
                  ),
                  onTap: () => _addToQueue(PlaybackPosition.next),
                ),
                PopupMenuItem<String>(
                  value: 'add_queue',
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_add),
                      const SizedBox(width: 12),
                      const Text('Add to Queue'),
                    ],
                  ),
                  onTap: () => _addToQueue(PlaybackPosition.last),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 12),
                      const Text('Edit Playlist'),
                    ],
                  ),
                  onTap: () => _editPlaylist(context),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 12),
                      const Text('Delete Playlist', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () => _deletePlaylist(context),
                ),
              ],
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: context.watch<ThemeService>().backgroundGradient,
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Playlist Cover with blur
                      if (widget.playlist.coverUrl.isNotEmpty || widget.playlist.songs.isNotEmpty)
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.network(
                            widget.playlist.coverUrl.isNotEmpty
                                ? widget.playlist.songs.first.image
                                : widget.playlist.songs.first.image,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                              Colors.black,
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                      // Playlist info
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.playlist.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.playlist.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.playlist.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${widget.playlist.songs.length} ${widget.playlist.songs.length == 1 ? "song" : "songs"}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Created ${_formatDate(widget.playlist.createdAt)}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.playlist.songs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No songs yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddSongsDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Songs'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ReorderablePlaylist(
                      songs: widget.playlist.songs,
                      onReorder: _handleReorder,
                      onTap: _handleSongTap,
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddSongsDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Songs'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'today';
    } else if (difference.inDays < 2) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddSongsDialog(BuildContext context) {
    // TODO: Show dialog to add songs to playlist
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Songs'),
        content: const Text('Feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _editPlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePlaylistDialog(
        initialSong: widget.playlist.songs.isNotEmpty ? widget.playlist.songs.first : null,
      ),
    ).then((updatedPlaylist) {
      if (updatedPlaylist != null) {
        // Create new playlist with existing songs
        final newPlaylist = Playlist(
          name: updatedPlaylist.name,
          description: updatedPlaylist.description,
          coverUrl: updatedPlaylist.coverUrl,
          songs: widget.playlist.songs,
          createdAt: widget.playlist.createdAt,
        );
        
        setState(() {
          _db.updatePlaylist(widget.playlistIndex, newPlaylist);
        });
      }
    });
  }

  void _deletePlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${widget.playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _db.deletePlaylist(widget.playlistIndex);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to library
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _playPlaylist() {
    if (widget.playlist.songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No songs in playlist')),
      );
      return;
    }

    // Add all songs to queue and play first song
    context.read<SongBloc>().add(
      PlaySongs(
        songs: widget.playlist.songs,
        startIndex: 0,
      ),
    );

    // Navigate to now playing screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LyricsScreen(
          song: widget.playlist.songs.first,
        ),
      ),
    );
  }

  void _addToQueue(PlaybackPosition position) {
    if (widget.playlist.songs.isEmpty) return;

    context.read<SongBloc>().add(
      AddSongsToQueue(
        songs: widget.playlist.songs,
        position: position,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          position == PlaybackPosition.next
              ? 'Playing next: ${widget.playlist.name}'
              : 'Added to queue: ${widget.playlist.name}',
        ),
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final song = widget.playlist.songs.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      widget.playlist.songs.insert(newIndex, song);
      _db.updatePlaylist(widget.playlistIndex, widget.playlist);
    });
  }

  void _handleSongTap(Song song) {
    final songIndex = widget.playlist.songs.indexOf(song);
    context.read<SongBloc>().add(
      PlaySongs(
        songs: widget.playlist.songs,
        startIndex: songIndex,
      ),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LyricsScreen(song: song),
      ),
    );
  }
}

enum PlaybackPosition { next, last } 