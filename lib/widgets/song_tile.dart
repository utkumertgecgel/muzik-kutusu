import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onDelete,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isPlaying ? AppTheme.surfaceLight : AppTheme.surfaceBlack,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPlaying
                  ? [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.6)]
                  : [AppTheme.surfaceLight, AppTheme.surfaceBlack],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPlaying ? Icons.equalizer : Icons.music_note,
            color: isPlaying ? Colors.black : AppTheme.textGrey,
            size: 28,
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            color: isPlaying ? AppTheme.primaryGreen : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist ?? 'Bilinmeyen Sanatçı',
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPlaying)
              Consumer<MusicProvider>(
                builder: (context, provider, _) {
                  return IconButton(
                    icon: Icon(
                      provider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppTheme.primaryGreen,
                    ),
                    onPressed: () => provider.togglePlay(),
                  );
                },
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.textGrey),
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Sil'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
