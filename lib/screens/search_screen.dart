import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zimi/screens/lyrics_screen.dart';
import '../widgets/song_tile.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';
import '../models/song.dart';
import '../blocs/song_bloc.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showHistory = true;

  // Add debouncer to prevent too many API calls
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() => _showHistory = true);
      } else {
        setState(() => _showHistory = false);
        // Trigger search
        print('Searching for: $query'); // Debug print
        context.read<SongBloc>().add(SearchSongs(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Column(
        children: [
          // Search Bar with glassmorphism
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search songs, artists...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _showHistory = true);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),
            ),
          ),

          // Results or History
          Expanded(
            child: _showHistory
                ? _buildSearchHistory()
                : BlocBuilder<SongBloc, SongState>(
                    builder: (context, state) {
                      if (state is SongLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      } else if (state is SongsLoaded) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.songs.length,
                          itemBuilder: (context, index) {
                            final song = state.songs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: 
                              
                              
                              SongTile(
                                song: song,
                                onTap: () async {
                                  try {

                                    print("tapped");
                                    print(song.artist);
                                    print(song.title);
                                    print(song.youtubeId);
                                    print(song.lyrics);
                                    // Show loading indicator
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fetching lyrics...'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );

                                    // Clean up artist and title
                                    final cleanArtist = song.artist.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
                                    final cleanTitle = song.title.replaceAll(RegExp(r'\([^)]*\)'), '').trim();

                                    // Fetch lyrics before navigating
                                    final lyrics = await context.read<SongBloc>().getLyricsService.getLyrics(
                                      cleanArtist,
                                      cleanTitle,
                                    );

                                    if (!mounted) return;

                                    // Add to recent searches
                                    await context.read<SongBloc>().storageService.addRecentSearch(song);
                                    
                                    // Navigate with lyrics
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LyricsScreen(
                                          song: song.copyWith(
                                            lyrics: lyrics,
                                            youtubeId: song.youtubeId,
                                          ),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error fetching lyrics: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return FutureBuilder<List<Song>>(
      future: context.read<SongBloc>().storageService.getRecentSearches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No recent searches',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final song = snapshot.data![index];
            return Dismissible(
              key: Key(song.title + song.artist),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                // Remove from history
              },
              child: SongTile(song: song),
            );
          },
        );
      },
    );
  }
} 