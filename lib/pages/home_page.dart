import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../components/molecules/format_picker.dart';
import '../components/molecules/url_input.dart';
import '../components/molecules/video_preview.dart';
import '../models/video_info.dart';
import '../services/yt_dlp.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _url = TextEditingController();
  VideoInfo? _info;
  OutputFormat _format = OutputFormat.mp4;
  int _quality = 0;
  bool _loading = false;
  double? _progress;
  String? _error;
  String? _savedPath;

  bool get _busy => _loading || _progress != null;

  Future<void> _run(Future<void> Function() task) async {
    setState(() => _error = null);
    try {
      await task();
    } on ProcessException {
      setState(() => _error = 'yt-dlp.exe não encontrado. Coloque-o na pasta "bin" ao lado do app.');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _fetch() async {
    final url = _url.text.trim();
    if (url.isEmpty || _busy) return;
    setState(() {
      _loading = true;
      _info = null;
      _savedPath = null;
    });
    await _run(() async {
      final info = await YtDlp.fetchInfo(url);
      final format = info.heights.isEmpty ? OutputFormat.mp3 : OutputFormat.mp4;
      setState(() {
        _info = info;
        _format = format;
        _quality = FormatPicker.qualitiesFor(format, info.heights).first;
      });
    });
    setState(() => _loading = false);
  }

  Future<void> _download() async {
    setState(() {
      _progress = 0;
      _savedPath = null;
    });
    await _run(() async {
      final path = await YtDlp.download(_info!.url, _format, _quality,
          onProgress: (p) => setState(() => _progress = p));
      setState(() => _savedPath = path);
      if (!mounted) return;
      showFToast(
        context: context,
        icon: const Icon(FLucideIcons.circleCheck),
        title: const Text('Download concluído!'),
        description: const Text('O arquivo está na pasta Downloads.'),
        duration: const Duration(seconds: 8),
        suffixBuilder: (context, entry) => FButton(
          size: .sm,
          mainAxisSize: .min,
          onPress: () {
            YtDlp.open(path);
            entry.dismiss();
          },
          child: const Text('Abrir'),
        ),
      );
    });
    setState(() => _progress = null);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final progress = _progress;
    final muted = context.theme.typography.body.sm.copyWith(color: context.theme.colors.mutedForeground);
    return FScaffold(
      header: FHeader(
        title: const Text('BaixarYT'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.folderOpen),
            semanticsLabel: 'Abrir pasta Downloads',
            onPress: () => YtDlp.open(YtDlp.downloadsDir),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            shrinkWrap: true,
            children: [
              UrlInput(controller: _url, enabled: !_busy, onSubmit: _fetch),
              if (_loading) ...[const SizedBox(height: 16), const FProgress()],
              if (_error != null) ...[
                const SizedBox(height: 16),
                FAlert(variant: .destructive, title: const Text('Algo deu errado'), subtitle: Text(_error!)),
              ],
              if (info != null) ...[
                const SizedBox(height: 24),
                VideoPreview(info: info),
                const SizedBox(height: 16),
                FormatPicker(
                  format: _format,
                  quality: _quality,
                  heights: info.heights,
                  enabled: !_busy,
                  onChanged: (f, q) => setState(() {
                    _format = f;
                    _quality = q;
                  }),
                ),
                const SizedBox(height: 24),
                if (progress != null) ...[
                  if (progress >= 1) const FProgress() else FDeterminateProgress(value: progress.clamp(0, 1)),
                  const SizedBox(height: 8),
                  Text(progress >= 1 ? 'Finalizando...' : 'Baixando ${(progress * 100).toStringAsFixed(0)}%',
                      style: muted, textAlign: TextAlign.center),
                ] else
                  FButton(onPress: _download, prefix: const Icon(FLucideIcons.download), child: const Text('Baixar')),
              ],
              if (_savedPath != null) ...[
                const SizedBox(height: 16),
                FCard(
                  child: Row(
                    children: [
                      const Icon(FLucideIcons.circleCheck),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_savedPath!, style: muted, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 12),
                      FButton(
                        variant: .outline,
                        size: .sm,
                        mainAxisSize: .min,
                        prefix: const Icon(FLucideIcons.play),
                        onPress: () => YtDlp.open(_savedPath!),
                        child: const Text('Abrir'),
                      ),
                      const SizedBox(width: 8),
                      FButton(
                        variant: .outline,
                        size: .sm,
                        mainAxisSize: .min,
                        prefix: const Icon(FLucideIcons.folder),
                        onPress: () => YtDlp.showInFolder(_savedPath!),
                        child: const Text('Mostrar na pasta'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
