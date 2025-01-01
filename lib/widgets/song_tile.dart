import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/song.dart';
import '../screens/lyrics_screen.dart';
import '../blocs/song_bloc.dart';
import '../services/database_service.dart';
import '../widgets/add_to_playlist_dialog.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongBloc, SongState>(
      buildWhen: (previous, current) => current is FavoriteToggled,
      builder: (context, state) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song.image.isNotEmpty ? song.image : song.albumArt,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[850],
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
            ),
          ),
          title: Text(
            song.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<bool>(
                future: context.read<SongBloc>().isFavorite(song),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? song.isFavorite;
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.pinkAccent : Colors.white54,
                    ),
                    onPressed: () {
                      context.read<SongBloc>().add(ToggleFavorite(song));
                      song.isFavorite = !isFavorite;  // Update local state
                    },
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'playlist',
                    child: const Text('Add to Playlist'),
                    onTap: () {
                      Future.delayed(
                        const Duration(milliseconds: 100),
                        () => showDialog(
                          context: context,
                          builder: (context) => AddToPlaylistDialog(song: song),
                        ),
                      );
                    },
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: const Text('Share'),
                    onTap: () => context.read<SongBloc>().add(ShareSong(song)),
                  ),
                ],
              ),
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }
} 