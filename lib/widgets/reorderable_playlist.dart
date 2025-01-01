import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';

class ReorderablePlaylist extends StatelessWidget {
  final List<Song> songs;
  final Function(int, int) onReorder;
  final Function(Song) onTap;

  const ReorderablePlaylist({
    super.key,
    required this.songs,
    required this.onReorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: songs.length * 80.0, // Approximate height per song tile
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Parent handles scrolling
        itemCount: songs.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          return SongTile(
            key: ValueKey(songs[index].id),
            song: songs[index],
            onTap: () => onTap(songs[index]),
          );
        },
      ),
    );
  }
} 