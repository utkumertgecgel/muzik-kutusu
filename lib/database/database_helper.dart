import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('music_box.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Şarkılar tablosu
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT,
        filePath TEXT NOT NULL,
        duration INTEGER,
        createdAt TEXT
      )
    ''');

    // Çalma listeleri tablosu
    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT
      )
    ''');

    // Çalma listesi-şarkı ilişki tablosu
    await db.execute('''
      CREATE TABLE playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlistId INTEGER,
        songId INTEGER,
        FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== ŞARKI İŞLEMLERİ ====================

  Future<int> insertSong(Song song) async {
    final db = await database;
    return await db.insert('songs', song.toMap());
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final result = await db.query('songs', orderBy: 'createdAt DESC');
    return result.map((map) => Song.fromMap(map)).toList();
  }

  Future<Song?> getSongById(int id) async {
    final db = await database;
    final result = await db.query('songs', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Song.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateSong(Song song) async {
    final db = await database;
    return await db.update(
      'songs',
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    // Önce playlist_songs tablosundan sil
    await db.delete('playlist_songs', where: 'songId = ?', whereArgs: [id]);
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Song>> searchSongs(String query) async {
    final db = await database;
    final result = await db.query(
      'songs',
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Song.fromMap(map)).toList();
  }

  // ==================== ÇALMA LİSTESİ İŞLEMLERİ ====================

  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist.toMap());
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final result = await db.query('playlists', orderBy: 'createdAt DESC');
    return result.map((map) => Playlist.fromMap(map)).toList();
  }

  Future<int> updatePlaylist(Playlist playlist) async {
    final db = await database;
    return await db.update(
      'playlists',
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<int> deletePlaylist(int id) async {
    final db = await database;
    // Önce playlist_songs tablosundan sil
    await db.delete('playlist_songs', where: 'playlistId = ?', whereArgs: [id]);
    return await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ÇALMA LİSTESİ-ŞARKI İLİŞKİSİ ====================

  Future<int> addSongToPlaylist(int playlistId, int songId) async {
    final db = await database;
    // Önce var mı kontrol et
    final existing = await db.query(
      'playlist_songs',
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
    );
    if (existing.isNotEmpty) {
      return 0; // Zaten ekli
    }
    return await db.insert('playlist_songs', {
      'playlistId': playlistId,
      'songId': songId,
    });
  }

  Future<int> removeSongFromPlaylist(int playlistId, int songId) async {
    final db = await database;
    return await db.delete(
      'playlist_songs',
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
    );
  }

  Future<List<Song>> getSongsInPlaylist(int playlistId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT songs.* FROM songs
      INNER JOIN playlist_songs ON songs.id = playlist_songs.songId
      WHERE playlist_songs.playlistId = ?
      ORDER BY songs.title
    ''', [playlistId]);
    return result.map((map) => Song.fromMap(map)).toList();
  }

  Future<int> getPlaylistSongCount(int playlistId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM playlist_songs WHERE playlistId = ?',
      [playlistId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Veritabanını kapat
  Future close() async {
    final db = await database;
    db.close();
  }
}
