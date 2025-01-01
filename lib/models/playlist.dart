import 'package:hive/hive.dart';
import 'song.dart';

// part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final List<Song> songs;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String coverUrl;

  Playlist({
    required this.name,
    this.description = '',
    List<Song>? songs,
    String? coverUrl,
    DateTime? createdAt,
  })  : songs = songs ?? [],
        coverUrl = coverUrl ?? '',
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'coverUrl': coverUrl,
    'songs': songs.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    name: json['name'],
    description: json['description'] ?? '',
    coverUrl: json['coverUrl'] ?? '',
    songs: (json['songs'] as List?)?.map((s) => Song.fromJson(s)).toList() ?? [],
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  );
} 