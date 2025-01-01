import 'package:flutter/material.dart';
import '../models/song.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NowPlayingQueue extends StatefulWidget {
  final List<Song> queue;
  final int currentIndex;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(Song song) onRemove;

  const NowPlayingQueue({
    super.key,
    required this.queue,
    required this.currentIndex,
    required this.onReorder,
    required this.onRemove,
  });

  @override
  State<NowPlayingQueue> createState() => _NowPlayingQueueState();
}

class _NowPlayingQueueState extends State<NowPlayingQueue> {
  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ReorderableListView.builder(
        itemCount: widget.queue.length,
        onReorder: widget.onReorder,
        itemBuilder: (context, index) {
          final song = widget.queue[index];
          final isPlaying = index == widget.currentIndex;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Dismissible(
                  key: Key(song.title + song.artist),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => widget.onRemove(song),
                  child: Container(
                    key: ValueKey(song),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              song.albumArt,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isPlaying)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        song.title,
                        style: TextStyle(
                          fontWeight: isPlaying ? FontWeight.bold : null,
                        ),
                      ),
                      subtitle: Text(song.artist),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 