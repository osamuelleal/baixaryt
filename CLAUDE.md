# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

BaixarYT: a Flutter **Windows-only** desktop app that downloads YouTube / YouTube Music links as MP4 (video) or MP3 (audio) by shelling out to `yt-dlp.exe` and `ffmpeg.exe`. UI strings are Portuguese; code, comments and commits are English.

## Commands

```bash
flutter run -d windows                         # run in debug
flutter build windows --release                # output: build/windows/x64/runner/Release/
powershell -ExecutionPolicy Bypass -File install.ps1   # build + install to %LOCALAPPDATA%\Programs\BaixarYT with shortcuts (-Uninstall)
flutter analyze
flutter test                                   # all tests
flutter test test/yt_dlp_test.dart --name parsePercent   # single test
```

## External binaries

- Put `yt-dlp.exe` and `ffmpeg.exe` in `<project>/bin/` (gitignored). A rule appended to `windows/CMakeLists.txt` copies that folder next to the built `.exe`, so `flutter run` and release builds both get them.
- `YtDlp` (`lib/services/yt_dlp.dart`) resolves each binary from `<exe dir>\bin\`, falling back to PATH. If `ffmpeg` comes from PATH, `--ffmpeg-location` is omitted.
- `YtDlp.updated` runs `yt-dlp -U` once at launch; every yt-dlp call awaits it. This is why the app installs per-user: the bundled exe must stay writable.
- Recent yt-dlp versions need a JS runtime for full YouTube support; the app enables Deno and Node (`--js-runtimes`). Without either, formats go missing.

## Architecture

- `lib/services/yt_dlp.dart` holds every yt-dlp interaction:
  - `fetchInfo` runs `yt-dlp -J` and parses the result into `VideoInfo`. The available video heights drive the MP4 quality list.
  - `download` streams stdout. The `--progress-template` lines are progress. The single `--print after_move:filepath` line is the final saved path. Progress restarts for each stream (video, then audio), and the post-processing step reports nothing, which the UI shows as "Finalizando...".
  - Format selection lives in `formatArgs`: MP4 = `-S res:<h>,vcodec:h264,ext:mp4:m4a` (H.264 for player compatibility when available); MP3 = `-x --audio-format mp3` plus embedded metadata and thumbnail.
  - Files are saved to `%USERPROFILE%\Downloads`.
- UI follows Atomic Design: `lib/components/molecules/*` are stateless and prop-driven. `lib/pages/home_page.dart` owns all state (fetch → preview → pick format → download → "Mostrar na pasta").
- The app icon (`windows/runner/resources/app_icon.ico`) is an original design; never use the YouTube logo.
- Output is forced to UTF-8 with the `PYTHONUTF8` environment variable, so non-ASCII titles and paths decode correctly.

## GitHub account (mandatory)

- This is a **personal** project: use **only** the `osamuelleal` GitHub account. Remote: `https://github.com/osamuelleal/baixaryt`.
- **Never** create, push to, comment on or otherwise touch anything under the company account `samuelnestveterinary` or any Nest org/repo.
- The machine's active `gh` account is the Nest one; **do not run `gh auth switch`**. Instead, scope each gh command to the personal account: `GH_TOKEN=$(gh auth token --user osamuelleal) gh ...`.
- `git push`/`fetch` already use the personal account through a repo-local credential helper in `.git/config` (it calls `gh auth token --user osamuelleal`). Commit author is pinned locally to `osamuelleal <samuelleal1997@gmail.com>`.
- Before any GitHub action, confirm the account with `GH_TOKEN=$(gh auth token --user osamuelleal) gh api user --jq .login` → must print `osamuelleal`.
