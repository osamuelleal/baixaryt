import 'dart:convert';
import 'dart:io';

import '../models/video_info.dart';

enum OutputFormat { mp4, mp3 }

const mp3Bitrates = [320, 256, 192, 128];

/// Thin wrapper around yt-dlp.exe. Looks for `bin\yt-dlp.exe` / `bin\ffmpeg.exe`
/// next to the app executable, falling back to whatever is on PATH.
class YtDlp {
  static final _binDir = '${File(Platform.resolvedExecutable).parent.path}\\bin';
  static final _ytDlp = _resolve('yt-dlp');
  static final _ffmpeg = _resolve('ffmpeg');

  static String _resolve(String name) {
    final local = '$_binDir\\$name.exe';
    return File(local).existsSync() ? local : name;
  }

  /// Self-update of yt-dlp (YouTube breaks old versions often). Started once at app launch;
  /// every yt-dlp call waits for it so the exe is never replaced mid-run. Failures are ignored.
  static final Future<void> updated = Process.run(_ytDlp, ['-U'])
      .timeout(const Duration(seconds: 60))
      .then<void>((_) {}, onError: (_) {});

  // ponytail: assumes the default Downloads location; add a folder picker if users relocate it.
  static String get downloadsDir => '${Platform.environment['USERPROFILE']}\\Downloads';

  static List<String> get _commonArgs => [
        '--no-playlist',
        // Without this, yt-dlp prints in the Windows ANSI codepage and accented titles break UTF-8 decoding.
        '--encoding', 'utf-8',
        // Deno is yt-dlp's default JS runtime; also allow Node, which is more commonly installed.
        '--js-runtimes', 'deno', '--js-runtimes', 'node',
        if (_ffmpeg != 'ffmpeg') ...['--ffmpeg-location', _ffmpeg],
      ];

  static Future<VideoInfo> fetchInfo(String url) async {
    await updated;
    final result = await Process.run(
      _ytDlp,
      [..._commonArgs, '-J', url],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) throw YtDlpException(result.stderr as String);
    return VideoInfo.fromJson(jsonDecode(result.stdout as String));
  }

  static List<String> formatArgs(OutputFormat format, int quality) => switch (format) {
        OutputFormat.mp4 => ['-f', 'bv*+ba/b', '-S', 'res:$quality,vcodec:h264,ext:mp4:m4a', '--merge-output-format', 'mp4'],
        OutputFormat.mp3 => [
            '-x', '--audio-format', 'mp3', '--audio-quality', '${quality}K',
            '--embed-metadata', '--embed-thumbnail',
          ],
      };

  /// Downloads [url] into the Downloads folder and returns the final file path.
  /// [onProgress] receives 0..1; yt-dlp restarts it per stream (video, then audio).
  static Future<String> download(
    String url,
    OutputFormat format,
    int quality, {
    required void Function(double) onProgress,
  }) async {
    // YouTube intermittently answers 403 on stream URLs (no PO token); a fresh extraction usually succeeds.
    for (var attempt = 1;; attempt++) {
      try {
        return await _downloadOnce(url, format, quality, onProgress);
      } on YtDlpException catch (e) {
        if (attempt == 3 || !e.stderr.contains('HTTP Error 403')) rethrow;
      }
    }
  }

  static Future<String> _downloadOnce(
    String url,
    OutputFormat format,
    int quality,
    void Function(double) onProgress,
  ) async {
    await updated;
    final process = await Process.start(
      _ytDlp,
      [
        ..._commonArgs,
        ...formatArgs(format, quality),
        '-P', downloadsDir,
        '-o', '%(title)s.%(ext)s',
        '--newline', '--progress',
        '--progress-template', 'download:%(progress._percent_str)s',
        '--print', 'after_move:filepath',
        url,
      ],
    );

    String? path;
    final stderr = StringBuffer();
    final errDone = process.stderr.transform(utf8.decoder).forEach(stderr.write);
    await for (final line in process.stdout.transform(utf8.decoder).transform(const LineSplitter())) {
      final percent = parsePercent(line);
      if (percent != null) {
        onProgress(percent);
      } else if (line.trim().isNotEmpty) {
        path = line.trim();
      }
    }
    await errDone;

    if (await process.exitCode != 0 || path == null) throw YtDlpException(stderr.toString());
    return path;
  }

  static double? parsePercent(String line) {
    final match = RegExp(r'^\s*([\d.]+)%\s*$').firstMatch(line);
    return match == null ? null : double.parse(match[1]!) / 100;
  }

  static Future<void> showInFolder(String path) => Process.start('explorer.exe', ['/select,', path]);

  /// Opens the file with its default Windows app.
  static Future<void> open(String path) => Process.start('explorer.exe', [path]);
}

class YtDlpException implements Exception {
  final String stderr;
  YtDlpException(this.stderr);

  @override
  String toString() {
    final errors = stderr.split('\n').where((l) => l.startsWith('ERROR:'));
    if (stderr.isEmpty) return 'yt-dlp não retornou nenhum arquivo.';
    return errors.isNotEmpty ? errors.last.substring(6).trim() : stderr.trim();
  }
}
