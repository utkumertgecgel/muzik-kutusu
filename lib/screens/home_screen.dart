import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import 'player_screen.dart';
import 'playlist_screen.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  bool _isSearching = false;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _addSong() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Uygulama klasörüne kopyala
        final appDir = await getApplicationDocumentsDirectory();
        final musicDir = Directory('${appDir.path}/music');
        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }
        
        final fileName = p.basename(file.path);
        final newPath = '${musicDir.path}/$fileName';
        
        // Dosyayı kopyala
        await file.copy(newPath);
        
        // Veritabanına ekle
        final song = Song(
          title: p.basenameWithoutExtension(fileName),
          artist: 'Bilinmeyen Sanatçı',
          filePath: newPath,
          createdAt: DateTime.now().toIso8601String(),
        );

        if (mounted) {
          await context.read<MusicProvider>().addSong(song);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${song.title} eklendi')),
                ],
              ),
              backgroundColor: AppTheme.surfaceBlack,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchSongs(String query) async {
    final provider = context.read<MusicProvider>();
    final results = await provider.searchSongs(query);
    setState(() {
      _filteredSongs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildMusicList(),
              const PlaylistScreen(),
            ],
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Consumer<MusicProvider>(
              builder: (context, provider, child) {
                return ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: FloatingActionButton.extended(
                    onPressed: _addSong,
                    icon: const Icon(Icons.add),
                    label: const Text('Şarkı Ekle'),
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Consumer<MusicProvider>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundBlack,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini Player - bottom nav'ın hemen üstünde
                if (provider.currentSong != null) const MiniPlayer(),
                // Bottom Navigation Bar
                BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.library_music),
                      label: 'Şarkılar',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.queue_music),
                      label: 'Çalma Listeleri',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMusicList() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          pinned: true,
          expandedHeight: 120,
          backgroundColor: AppTheme.backgroundBlack,
          flexibleSpace: FlexibleSpaceBar(
            title: !_isSearching
                ? const Text(
                    'Müzik Kutusu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                : null,
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
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filteredSongs = [];
                  }
                });
              },
            ),
          ],
        ),

        // Arama alanı
        if (_isSearching)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Şarkı veya sanatçı ara...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppTheme.surfaceBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _searchSongs,
              ),
            ),
          ),

        // Şarkı listesi
        Consumer<MusicProvider>(
          builder: (context, provider, child) {
            final songs = _isSearching && _searchController.text.isNotEmpty
                ? _filteredSongs
                : provider.songs;

            if (songs.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSearching ? Icons.search_off : Icons.music_off,
                        size: 80,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSearching
                            ? 'Sonuç bulunamadı'
                            : 'Henüz şarkı eklenmedi',
                        style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 18,
                        ),
                      ),
                      if (!_isSearching) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Şarkı eklemek için + butonuna tıklayın',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: provider.currentSong != null ? 150 : 80,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = songs[index];
                    return SongTile(
                      song: song,
                      onTap: () => provider.playSongAt(index, songs),
                      onDelete: () => _showDeleteDialog(song),
                      isPlaying: provider.currentSong?.id == song.id,
                    );
                  },
                  childCount: songs.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteDialog(Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şarkıyı Sil'),
        content: Text('"${song.title}" şarkısını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<MusicProvider>().deleteSong(song.id!);
              // Dosyayı da sil
              try {
                final file = File(song.filePath);
                if (await file.exists()) {
                  await file.delete();
                }
              } catch (e) {
                debugPrint('Dosya silme hatası: $e');
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şarkı silindi'),
                    backgroundColor: AppTheme.surfaceBlack,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
