import 'package:hive/hive.dart';
import '../models/playlist.dart';

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 1;

  @override
  Playlist read(BinaryReader reader) {
    return Playlist(
      name: reader.read(),
      description: reader.read(),
      songs: reader.read(),
      coverUrl: reader.read(),
      createdAt: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer.write(obj.name);
    writer.write(obj.description);
    writer.write(obj.songs);
    writer.write(obj.coverUrl);
    writer.write(obj.createdAt);
  }
} 