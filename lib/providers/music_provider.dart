import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../models/song.dart';
import '../database/database_helper.dart';

class MusicProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Song> _songs = [];
  List<Song> _currentPlaylist = []; // Mevcut çalınan playlist
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentIndex = -1;
  bool _isShuffleOn = false;
  bool _isRepeatOn = false;

  // Getters
  List<Song> get songs => _songs;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  int get currentIndex => _currentIndex;
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isShuffleOn => _isShuffleOn;
  bool get isRepeatOn => _isRepeatOn;

  MusicProvider() {
    _initAudioPlayer();
    loadSongs();
  }

  void _initAudioPlayer() {
    // Çalma durumu değiştiğinde
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    // Şarkı süresi değiştiğinde
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners();
    });

    // Pozisyon değiştiğinde
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      notifyListeners();
    });

    // Şarkı bittiğinde
    _audioPlayer.onPlayerComplete.listen((event) async {
      if (_isRepeatOn && _currentSong != null) {
        // Tekrar modunda aynı şarkıyı baştan çal
        await playSong(_currentSong!, index: _currentIndex);
      } else {
        await playNext();
      }
    });
  }

  // Şarkıları yükle
  Future<void> loadSongs() async {
    _songs = await _dbHelper.getAllSongs();
    notifyListeners();
  }

  // Şarkı ekle
  Future<void> addSong(Song song) async {
    await _dbHelper.insertSong(song);
    await loadSongs();
  }

  // Şarkı sil
  Future<void> deleteSong(int id) async {
    await _dbHelper.deleteSong(id);
    if (_currentSong?.id == id) {
      await stop();
      _currentSong = null;
      _currentIndex = -1;
    }
    await loadSongs();
  }

  // Şarkı çal
  Future<void> playSong(Song song, {int? index}) async {
    try {
      _currentSong = song;
      _currentIndex = index ?? _songs.indexOf(song);
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(song.filePath));
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Şarkı çalma hatası: $e');
    }
  }

  // Listeden şarkı çal (index ile)
  Future<void> playSongAt(int index, List<Song> playlist) async {
    if (index >= 0 && index < playlist.length) {
      _currentPlaylist = List.from(playlist); // Playlist'i kaydet
      _currentIndex = index;
      await playSong(playlist[index], index: index);
    }
  }

  // Oynat/Duraklat
  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  // Durdur
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  // Sonraki şarkı
  Future<void> playNext() async {
    // Mevcut playlist'i kullan, boşsa tüm şarkıları kullan
    final playlist = _currentPlaylist.isNotEmpty ? _currentPlaylist : _songs;
    
    if (playlist.isNotEmpty) {
      if (_isShuffleOn && playlist.length > 1) {
        // Karışık modda rastgele şarkı seç (mevcut şarkı hariç)
        final random = Random();
        int newIndex;
        do {
          newIndex = random.nextInt(playlist.length);
        } while (newIndex == _currentIndex);
        _currentIndex = newIndex;
      } else {
        _currentIndex = (_currentIndex + 1) % playlist.length;
      }
      await playSong(playlist[_currentIndex], index: _currentIndex);
    }
  }

  // Karışık modu aç/kapat
  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    if (_isShuffleOn) {
      _isRepeatOn = false; // Shuffle açılınca repeat kapat
    }
    notifyListeners();
  }

  // Tekrar modu aç/kapat
  void toggleRepeat() {
    _isRepeatOn = !_isRepeatOn;
    if (_isRepeatOn) {
      _isShuffleOn = false; // Repeat açılınca shuffle kapat
    }
    notifyListeners();
  }

  // Önceki şarkı
  Future<void> playPrevious() async {
    // Mevcut playlist'i kullan, boşsa tüm şarkıları kullan
    final playlist = _currentPlaylist.isNotEmpty ? _currentPlaylist : _songs;
    
    if (playlist.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + playlist.length) % playlist.length;
      await playSong(playlist[_currentIndex], index: _currentIndex);
    }
  }

  // Belirli bir pozisyona git
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Arama
  Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) {
      return _songs;
    }
    return await _dbHelper.searchSongs(query);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
