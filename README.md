# 🎵 Müzik Kutusu

A beautiful, offline-first music player app built with Flutter. Organize your music library, create playlists, and enjoy your favorite tracks with a sleek Spotify-inspired interface.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

## ✨ Features

- **🔐 Password Protection** - Secure your music library with a personal PIN
- **📁 Local Music Import** - Add songs from your device storage
- **📋 Playlist Management** - Create, edit, and organize custom playlists
- **🎨 Spotify-Inspired UI** - Dark theme with vibrant green accents
- **🔀 Shuffle & Repeat** - Multiple playback modes
- **🔍 Search** - Quickly find songs by title or artist
- **📴 Offline First** - No internet required, all data stored locally

## 📱 Screenshots

| Login | Home | Player |
|-------|------|--------|
| Password protection | Song library with search | Full-screen player with controls |

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x
- **Language:** Dart
- **Database:** SQLite (sqflite)
- **State Management:** Provider
- **Audio:** audioplayers
- **File Handling:** file_picker, path_provider

## 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/muzik-kutusu.git
   cd muzik-kutusu
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── database/
│   └── database_helper.dart   # SQLite operations
├── models/
│   ├── song.dart          # Song data model
│   └── playlist.dart      # Playlist data model
├── providers/
│   └── music_provider.dart    # State management
├── screens/
│   ├── login_screen.dart      # Authentication
│   ├── home_screen.dart       # Main music library
│   ├── player_screen.dart     # Full-screen player
│   └── playlist_screen.dart   # Playlist management
├── widgets/
│   ├── song_tile.dart     # Song list item
│   └── mini_player.dart   # Bottom mini player
└── theme/
    └── app_theme.dart     # Spotify-inspired theme
```

## 💾 Database Schema

The app uses SQLite with three tables:

```sql
-- Songs table
CREATE TABLE songs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  artist TEXT,
  filePath TEXT NOT NULL,
  duration INTEGER,
  createdAt TEXT NOT NULL
);

-- Playlists table
CREATE TABLE playlists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  createdAt TEXT NOT NULL
);

-- Many-to-many relationship
CREATE TABLE playlist_songs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  playlistId INTEGER NOT NULL,
  songId INTEGER NOT NULL,
  FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE,
  FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
);
```

## 🎨 Design

The UI follows Spotify's design language with:
- **Primary Color:** `#1DB954` (Spotify Green)
- **Background:** `#121212` (Rich Black)
- **Surface:** `#1E1E1E` (Dark Gray)
- Smooth animations and transitions
- Rotating album art during playback

## 🤝 Contributing

Contributions are welcome! Feel free to:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<p align="center">Made with ❤️ and Flutter</p>
