import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';

class PlayerScreen extends StatefulWidget {
  final Song song;
  
  const PlayerScreen({super.key, required this.song});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1DB954),
              Color(0xFF0D5C2A),
              AppTheme.backgroundBlack,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Consumer<MusicProvider>(
            builder: (context, provider, child) {
              final song = provider.currentSong ?? widget.song;
              
              // Animasyonu kontrol et
              if (provider.isPlaying) {
                _rotationController.repeat();
              } else {
                _rotationController.stop();
              }

              return Column(
                children: [
                  // Üst bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'ŞIMDI ÇALINIYOR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 48), // Boş alan (üç nokta kaldırıldı)
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Albüm kapağı
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.surfaceLight,
                            AppTheme.surfaceBlack,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryGreen.withOpacity(0.8),
                              AppTheme.primaryGreen.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Şarkı bilgisi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          song.artist ?? 'Bilinmeyen Sanatçı',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                          ),
                          child: Slider(
                            value: provider.position.inSeconds.toDouble(),
                            max: provider.duration.inSeconds.toDouble() > 0
                                ? provider.duration.inSeconds.toDouble()
                                : 1.0,
                            onChanged: (value) {
                              provider.seekTo(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(provider.position),
                                style: const TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(provider.duration),
                                style: const TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Kontrol butonları
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: provider.isShuffleOn ? AppTheme.primaryGreen : AppTheme.textGrey,
                          ),
                          iconSize: 28,
                          onPressed: () => provider.toggleShuffle(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 40,
                          onPressed: () => provider.playPrevious(),
                        ),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryGreen,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              provider.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                            ),
                            iconSize: 40,
                            onPressed: () => provider.togglePlay(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          iconSize: 40,
                          onPressed: () => provider.playNext(),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.repeat,
                            color: provider.isRepeatOn ? AppTheme.primaryGreen : AppTheme.textGrey,
                          ),
                          iconSize: 28,
                          onPressed: () => provider.toggleRepeat(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
