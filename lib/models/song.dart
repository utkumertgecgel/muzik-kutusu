class Song {
  final int? id;
  final String title;
  final String? artist;
  final String filePath;
  final int? duration;
  final String? createdAt;

  Song({
    this.id,
    required this.title,
    this.artist,
    required this.filePath,
    this.duration,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'duration': duration,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      filePath: map['filePath'],
      duration: map['duration'],
      createdAt: map['createdAt'],
    );
  }

  Song copyWith({
    int? id,
    String? title,
    String? artist,
    String? filePath,
    int? duration,
    String? createdAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Song{id: $id, title: $title, artist: $artist, filePath: $filePath}';
  }
}
