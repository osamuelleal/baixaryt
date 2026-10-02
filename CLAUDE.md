# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

BaixarYT: a Flutter **Windows-only** desktop app that downloads YouTube / YouTube Music links as MP4 (video) or MP3 (audio) by shelling out to `yt-dlp.exe` and `ffmpeg.exe`. UI strings are Portuguese; code, comments and commits are English.

## Commands

```bash
flutter run -d windows                         # run in debug
flutter build windows --release                # output: build/windows/x64/runner/Release/
flutter analyze
flutter test                                   # all tests
flutter test test/yt_dlp_test.dart --name parsePercent   # single test
```

## External binaries

- Put `yt-dlp.exe` and `ffmpeg.exe` in `<project>/bin/` (gitignored). A rule appended to `windows/CMakeLists.txt` copies that folder next to the built `.exe`, so `flutter run` and release builds both get them.
- `YtDlp` (`lib/services/yt_dlp.dart`) resolves each binary from `<exe dir>\bin\`, falling back to PATH. If `ffmpeg` comes from PATH, `--ffmpeg-location` is omitted.
- Recent yt-dlp versions need a JS runtime (Deno) for full YouTube format support; missing it shows up as few or no formats.

## Architecture

- `lib/services/yt_dlp.dart` holds every yt-dlp interaction:
  - `fetchInfo` runs `yt-dlp -J` and parses the result into `VideoInfo`. The available video heights drive the MP4 quality list.
  - `download` streams stdout. The `--progress-template` lines are progress. The single `--print after_move:filepath` line is the final saved path. Progress restarts for each stream (video, then audio), and the post-processing step reports nothing, which the UI shows as "Finalizando...".
  - Format selection lives in `formatArgs`: MP4 = `-S res:<h>,ext:mp4:m4a`; MP3 = `-x --audio-format mp3` plus embedded metadata and thumbnail.
  - Files are saved to `%USERPROFILE%\Downloads`.
- UI follows Atomic Design: `lib/components/molecules/*` are stateless and prop-driven. `lib/pages/home_page.dart` owns all state (fetch → preview → pick format → download → "Mostrar na pasta").
- Output is forced to UTF-8 with the `PYTHONUTF8` environment variable, so non-ASCII titles and paths decode correctly.
