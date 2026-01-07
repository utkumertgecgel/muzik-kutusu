# 🎵 Müzik Kutusu

Flutter ile geliştirilmiş, çevrimdışı çalışabilen güzel bir müzik çalar uygulaması. Müzik kütüphanenizi düzenleyin, çalma listeleri oluşturun ve Spotify'dan ilham alan şık arayüzle şarkılarınızın keyfini çıkarın.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

## ✨ Özellikler

- **🔐 Şifre Koruması** - Müzik kütüphanenizi kişisel PIN ile koruyun
- **📁 Yerel Müzik Ekleme** - Cihazınızdaki şarkıları uygulamaya ekleyin
- **📋 Çalma Listesi Yönetimi** - Özel çalma listeleri oluşturun ve düzenleyin
- **🎨 Spotify Tarzı Arayüz** - Canlı yeşil vurgulu koyu tema
- **🔀 Karışık ve Tekrar Modu** - Çoklu çalma modları
- **🔍 Arama** - Şarkı adı veya sanatçıya göre hızlı arama
- **📴 Çevrimdışı Çalışma** - İnternet gerektirmez, tüm veriler yerel olarak saklanır

## 📱 Ekran Görüntüleri

| Giriş | Ana Ekran | Çalar |
|-------|-----------|-------|
| Şifre koruması | Arama özellikli şarkı kütüphanesi | Kontrollü tam ekran çalar |

## 🛠️ Kullanılan Teknolojiler

- **Framework:** Flutter 3.x
- **Dil:** Dart
- **Veritabanı:** SQLite (sqflite)
- **State Yönetimi:** Provider
- **Ses:** audioplayers
- **Dosya İşlemleri:** file_picker, path_provider

## 📦 Kurulum

1. **Depoyu klonlayın**
   ```bash
   git clone https://github.com/utkumertgecgel/muzik-kutusu.git
   cd muzik-kutusu
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 🏗️ Proje Yapısı

```
lib/
├── main.dart              # Uygulama giriş noktası
├── database/
│   └── database_helper.dart   # SQLite işlemleri
├── models/
│   ├── song.dart          # Şarkı veri modeli
│   └── playlist.dart      # Çalma listesi veri modeli
├── providers/
│   └── music_provider.dart    # State yönetimi
├── screens/
│   ├── login_screen.dart      # Kimlik doğrulama
│   ├── home_screen.dart       # Ana müzik kütüphanesi
│   ├── player_screen.dart     # Tam ekran çalar
│   └── playlist_screen.dart   # Çalma listesi yönetimi
├── widgets/
│   ├── song_tile.dart     # Şarkı liste öğesi
│   └── mini_player.dart   # Alt mini çalar
└── theme/
    └── app_theme.dart     # Spotify tarzı tema
```

## 💾 Veritabanı Şeması

Uygulama üç tablolu SQLite veritabanı kullanır:

```sql
-- Şarkılar tablosu
CREATE TABLE songs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  artist TEXT,
  filePath TEXT NOT NULL,
  duration INTEGER,
  createdAt TEXT NOT NULL
);

-- Çalma listeleri tablosu
CREATE TABLE playlists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  createdAt TEXT NOT NULL
);

-- Çoktan-çoğa ilişki tablosu
CREATE TABLE playlist_songs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  playlistId INTEGER NOT NULL,
  songId INTEGER NOT NULL,
  FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE,
  FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
);
```

## 🎨 Tasarım

Arayüz Spotify tasarım dilini takip eder:
- **Ana Renk:** `#1DB954` (Spotify Yeşili)
- **Arka Plan:** `#121212` (Zengin Siyah)
- **Yüzey:** `#1E1E1E` (Koyu Gri)
- Akıcı animasyonlar ve geçişler
- Çalma sırasında dönen albüm kapağı

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Yapmanız gerekenler:
1. Depoyu fork'layın
2. Özellik dalı oluşturun
3. Pull request gönderin

## 📄 Lisans

Bu proje açık kaynaklıdır ve [MIT Lisansı](LICENSE) altında sunulmaktadır.

---

<p align="center">❤️ ve Flutter ile yapıldı</p>
