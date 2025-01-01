import 'package:hive/hive.dart';
import '../models/song.dart';

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 0;

  @override
  Song read(BinaryReader reader) {
    return Song(
      id: reader.read(),
      title: reader.read(),
      artist: reader.read(),
      albumArt: reader.read(),
      youtubeId: reader.read(),
      image: reader.read(),
      lyrics: reader.read(),
      isFavorite: reader.read(),
      addedAt: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.artist);
    writer.write(obj.albumArt);
    writer.write(obj.youtubeId);
    writer.write(obj.image);
    writer.write(obj.lyrics);
    writer.write(obj.isFavorite);
    writer.write(obj.addedAt);
  }
} 