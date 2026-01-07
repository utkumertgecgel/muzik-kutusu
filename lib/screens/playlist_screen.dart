import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../widgets/mini_player.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _dbHelper.getAllPlaylists();
    setState(() {
      _playlists = playlists;
      _isLoading = false;
    });
  }

  Future<void> _createPlaylist() async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Çalma Listesi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Liste adı',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final playlist = Playlist(
        name: result,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _dbHelper.insertPlaylist(playlist);
      await _loadPlaylists();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$result" oluşturuldu'),
            backgroundColor: AppTheme.surfaceBlack,
          ),
        );
      }
    }
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Listeyi Sil'),
        content: Text('"${playlist.name}" listesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deletePlaylist(playlist.id!);
      await _loadPlaylists();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Liste silindi'),
            backgroundColor: AppTheme.surfaceBlack,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalma Listeleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createPlaylist,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryGreen,
                AppTheme.backgroundBlack,
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.queue_music,
                        size: 80,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz çalma listesi yok',
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createPlaylist,
                        icon: const Icon(Icons.add),
                        label: const Text('Liste Oluştur'),
                      ),
                    ],
                  ),
                )
              : Consumer<MusicProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        top: 8,
                        bottom: provider.currentSong != null ? 150 : 80,
                      ),
                      itemCount: _playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = _playlists[index];
                        return FutureBuilder<int>(
                          future: _dbHelper.getPlaylistSongCount(playlist.id!),
                          builder: (context, snapshot) {
                            final songCount = snapshot.data ?? 0;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryGreen.withOpacity(0.8),
                                        AppTheme.primaryGreen.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.queue_music,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                title: Text(
                                  playlist.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  '$songCount şarkı',
                                  style: const TextStyle(color: AppTheme.textGrey),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deletePlaylist(playlist);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Sil'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _openPlaylist(playlist),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }

  void _openPlaylist(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    ).then((_) => _loadPlaylists());
  }
}

// Çalma listesi detay ekranı
class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await _dbHelper.getSongsInPlaylist(widget.playlist.id!);
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  Future<void> _addSongsToPlaylist() async {
    final allSongs = await _dbHelper.getAllSongs();
    final playlistSongIds = _songs.map((s) => s.id).toSet();
    final availableSongs = allSongs.where((s) => !playlistSongIds.contains(s.id)).toList();

    if (availableSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eklenecek şarkı yok'),
          backgroundColor: AppTheme.surfaceBlack,
        ),
      );
      return;
    }

    final selectedSongs = await showDialog<List<Song>>(
      context: context,
      builder: (context) => _SongPickerDialog(songs: availableSongs),
    );

    if (selectedSongs != null && selectedSongs.isNotEmpty) {
      for (final song in selectedSongs) {
        await _dbHelper.addSongToPlaylist(widget.playlist.id!, song.id!);
      }
      await _loadSongs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedSongs.length} şarkı eklendi'),
            backgroundColor: AppTheme.surfaceBlack,
          ),
        );
      }
    }
  }

  Future<void> _removeSongFromPlaylist(Song song) async {
    await _dbHelper.removeSongFromPlaylist(widget.playlist.id!, song.id!);
    await _loadSongs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${song.title}" listeden çıkarıldı'),
          backgroundColor: AppTheme.surfaceBlack,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.playlist.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.backgroundBlack,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.queue_music,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addSongsToPlaylist,
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_songs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.music_off,
                      size: 80,
                      color: AppTheme.textGrey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bu listede şarkı yok',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _addSongsToPlaylist,
                      icon: const Icon(Icons.add),
                      label: const Text('Şarkı Ekle'),
                    ),
                  ],
                ),
              ),
            )
          else
            Consumer<MusicProvider>(
              builder: (context, provider, _) {
                return SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: provider.currentSong != null ? 80 : 16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = _songs[index];
                        return Dismissible(
                          key: Key(song.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _removeSongFromPlaylist(song),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceBlack,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                provider.currentSong?.id == song.id
                                    ? Icons.equalizer
                                    : Icons.music_note,
                                color: provider.currentSong?.id == song.id
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textGrey,
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                color: provider.currentSong?.id == song.id
                                    ? AppTheme.primaryGreen
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              song.artist ?? 'Bilinmeyen Sanatçı',
                              style: const TextStyle(color: AppTheme.textGrey),
                            ),
                            onTap: () => provider.playSongAt(index, _songs),
                          ),
                        );
                      },
                      childCount: _songs.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      // Mini Player - Playlist ekranında da göster
      bottomNavigationBar: Consumer<MusicProvider>(
        builder: (context, provider, child) {
          if (provider.currentSong == null) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            child: const MiniPlayer(),
          );
        },
      ),
    );
  }
}

// Şarkı seçme dialogu
class _SongPickerDialog extends StatefulWidget {
  final List<Song> songs;

  const _SongPickerDialog({required this.songs});

  @override
  State<_SongPickerDialog> createState() => _SongPickerDialogState();
}

class _SongPickerDialogState extends State<_SongPickerDialog> {
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Şarkı Seç'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: widget.songs.length,
          itemBuilder: (context, index) {
            final song = widget.songs[index];
            final isSelected = _selectedIds.contains(song.id);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIds.add(song.id!);
                  } else {
                    _selectedIds.remove(song.id);
                  }
                });
              },
              title: Text(song.title),
              subtitle: Text(song.artist ?? 'Bilinmeyen Sanatçı'),
              activeColor: AppTheme.primaryGreen,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            final selectedSongs = widget.songs
                .where((s) => _selectedIds.contains(s.id))
                .toList();
            Navigator.pop(context, selectedSongs);
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}
