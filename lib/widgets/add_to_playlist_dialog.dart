import 'package:flutter/material.dart';
import 'package:zimi/widgets/create_playlist_dialog.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/database_service.dart';

class AddToPlaylistDialog extends StatefulWidget {
  final Song song;

  const AddToPlaylistDialog({
    super.key,
    required this.song,
  });

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Add to Playlist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _createNewPlaylist(context),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder<List<Playlist>>(
            future: _db.getPlaylists(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final playlists = snapshot.data!;
              if (playlists.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No playlists yet. Create one!'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  final alreadyAdded = playlist.songs
                      .any((s) => s.id == widget.song.id);

                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: playlist.coverUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.song.image),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: playlist.coverUrl.isEmpty
                          ? const Icon(Icons.music_note, color: Colors.white)
                          : null,
                    ),
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.songs.length} songs'),
                    trailing: alreadyAdded
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () async {
                      if (!alreadyAdded) {
                        await _db.addSongToPlaylist(index, widget.song);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added to ${playlist.name}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _createNewPlaylist(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreatePlaylistDialog(
        initialSong: widget.song,
      ),
    ).then((newPlaylist) async {
      if (newPlaylist != null) {
        try {
          await _db.createPlaylist(newPlaylist);
          if (mounted) {
            Navigator.pop(context);  // Close the add to playlist dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Created playlist: ${newPlaylist.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating playlist: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }
} 