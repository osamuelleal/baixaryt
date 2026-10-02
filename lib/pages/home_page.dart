import 'dart:io';

import 'package:flutter/material.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 560,
        duration: const Duration(seconds: 8),
        content: const Text('Download concluído! O arquivo está na pasta Downloads.'),
        action: SnackBarAction(label: 'Abrir', onPressed: () => YtDlp.open(path)),
      ));
    });
    setState(() => _progress = null);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text('BaixarYT', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              UrlInput(controller: _url, enabled: !_busy, onSubmit: _fetch),
              if (_loading) ...[const SizedBox(height: 16), const LinearProgressIndicator()],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
                if (_progress != null)
                  Column(children: [
                    LinearProgressIndicator(value: _progress! >= 1 ? null : _progress),
                    const SizedBox(height: 8),
                    Text(_progress! >= 1 ? 'Finalizando...' : 'Baixando ${(_progress! * 100).toStringAsFixed(0)}%'),
                  ])
                else
                  FilledButton.icon(
                    onPressed: _download,
                    icon: const Icon(Icons.download),
                    label: const Text('Baixar'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  ),
              ],
              if (_savedPath != null) ...[
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Download concluído'),
                  subtitle: Text(_savedPath!),
                  trailing: Wrap(spacing: 8, children: [
                    TextButton(onPressed: () => YtDlp.open(_savedPath!), child: const Text('Abrir')),
                    TextButton(
                      onPressed: () => YtDlp.showInFolder(_savedPath!),
                      child: const Text('Mostrar na pasta'),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
