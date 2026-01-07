class Playlist {
  final int? id;
  final String name;
  final String? createdAt;

  Playlist({
    this.id,
    required this.name,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      name: map['name'],
      createdAt: map['createdAt'],
    );
  }

  Playlist copyWith({
    int? id,
    String? name,
    String? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Playlist{id: $id, name: $name}';
  }
}
