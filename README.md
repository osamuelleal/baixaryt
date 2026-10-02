<div align="center">

# 🎬 BaixarYT

**Download YouTube and YouTube Music as MP4 or MP3: paste, pick, done.**

A small Windows desktop app built with Flutter, powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [FFmpeg](https://ffmpeg.org/).

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6?logo=windows)
![Flutter](https://img.shields.io/badge/Flutter-3.27-02569B?logo=flutter)
![yt-dlp](https://img.shields.io/badge/powered%20by-yt--dlp-red)

</div>

---

## ✨ Features

- 🔗 **Paste any link**: works with `youtube.com`, `youtu.be` and `music.youtube.com`. Playlist parameters are ignored, so you get only the track you pasted.
- 🖼️ **Preview before downloading**: thumbnail, title, channel/artist and duration.
- 🎞️ **MP4 video**: choose from the resolutions actually available for that video. H.264 is preferred, so files play in any Windows player.
- 🎵 **MP3 audio**: 320 / 256 / 192 / 128 kbps, with title, artist and cover art embedded.
- 📊 **Live progress**, plus a one-click **"Show in folder"** button when the download finishes.
- 🔄 **Keeps itself working**: yt-dlp updates itself in the background every time the app starts.
- 🌗 Light and dark theme that follows your Windows setting.

Files are saved to your **Downloads** folder.

## 📦 Requirements

| What | Why |
|------|-----|
| Windows 10 or 11 (x64) | Target platform |
| [`yt-dlp.exe`](https://github.com/yt-dlp/yt-dlp/releases/latest) | Fetches video info and downloads streams |
| [`ffmpeg.exe`](https://www.gyan.dev/ffmpeg/builds/) | Merges video and audio, converts to MP3 |
| [Node.js](https://nodejs.org/) **or** [Deno](https://deno.com/) | yt-dlp needs a JS runtime to see every YouTube format |
| [Flutter](https://docs.flutter.dev/get-started/install/windows/desktop) + Visual Studio (C++ desktop workload) | Building from source only |

The app looks for `yt-dlp.exe` and `ffmpeg.exe` in a `bin\` folder next to `baixaryt.exe` first, then on your `PATH`.

## 🚀 Getting started

```bash
git clone https://github.com/osamuelleal/baixaryt.git
cd baixaryt

# Drop the binaries into bin/ (it's gitignored)
mkdir bin
curl -L -o bin/yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
# ...and copy ffmpeg.exe into bin/ as well (or have it on PATH)

flutter run -d windows
```

The build automatically copies `bin\` next to the executable.

### Build the installer

Requires [Inno Setup 6](https://jrsoftware.org/isinfo.php) (`winget install JRSoftware.InnoSetup`).

```bash
flutter build windows --release
iscc installer\baixaryt.iss
```

This produces `dist\BaixarYT-Setup-<version>.exe`, a regular Windows installer. It installs per-user (no admin needed), adds Start Menu and optional Desktop shortcuts, and registers an uninstaller under **Settings → Apps**.

### Portable build

```bash
flutter build windows --release
```

Your app is in `build\windows\x64\runner\Release\`. Zip that whole folder to share it.

## 🧭 How to use

1. Paste a YouTube or YouTube Music link and press **Buscar** (or Enter).
2. Check the preview.
3. Pick **MP4** + resolution, or **MP3** + bitrate.
4. Hit **Baixar**. When it's done, click **Mostrar na pasta** to open the file's folder.

## 🛠️ Development

```bash
flutter analyze
flutter test
```

All yt-dlp interaction lives in `lib/services/yt_dlp.dart`. The UI follows Atomic Design (`lib/components/molecules`, `lib/pages`).

**Tip:** if downloads start failing, YouTube probably changed something. The app updates yt-dlp on every launch, so try reopening it first.

## ⚖️ Disclaimer

This project is for personal use. Only download content you own or have permission to download, and respect YouTube's Terms of Service and copyright law.
