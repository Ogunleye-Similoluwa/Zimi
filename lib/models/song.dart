import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId: 0)
class Song extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  String image;

  @HiveField(3)
  final String artist;

  @HiveField(4)
  final String albumArt;

  @HiveField(5)
  String youtubeId;

  @HiveField(6)
  String lyrics;

  @HiveField(7)
  final DateTime addedAt;

  @HiveField(8)
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.youtubeId,
     this.image='',
    this.lyrics = '',
    DateTime? addedAt,
    this.isFavorite = false,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'albumArt': albumArt,
    'youtubeId': youtubeId,
    'lyrics': lyrics,
    'image': image,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: json['title'],
    artist: json['artist'],
    albumArt: json['albumArt'],
    youtubeId: json['youtubeId'],
    image: json['image'] ?? '',
    lyrics: json['lyrics'],
  );

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? image,
    String? albumArt,
    String? youtubeId,
    String? lyrics,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      image: image ?? this.image,
      albumArt: albumArt ?? this.albumArt,
      youtubeId: youtubeId ?? this.youtubeId,
      lyrics: lyrics ?? this.lyrics,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class LyricLine {
  final String text;
  final Duration? timestamp;

  LyricLine({
    required this.text,
    this.timestamp,
  });
}