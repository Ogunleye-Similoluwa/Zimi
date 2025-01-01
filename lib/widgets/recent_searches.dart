import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zimi/screens/lyrics_screen.dart';
import 'package:zimi/widgets/song_tile.dart';
import '../models/song.dart';
import '../blocs/song_bloc.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<SongBloc, SongState>(
            builder: (context, state) {
              return FutureBuilder<List<Song>>(
                future: context.read<SongBloc>().storageService.getRecentSearches(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No recent searches',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final song = snapshot.data![index];
                      return SongTile(
                        song: song,
                        onTap: () async {
                          // Fetch lyrics before navigating
                          final lyrics = await context.read<SongBloc>().lyricsService.getLyrics(
                            song.artist,
                            song.title,
                          );
                          if (!context.mounted) return;
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LyricsScreen(
                                song: song.copyWith(lyrics: lyrics),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 