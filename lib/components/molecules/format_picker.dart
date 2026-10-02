import 'package:flutter/material.dart';

import '../../services/yt_dlp.dart';

class FormatPicker extends StatelessWidget {
  final OutputFormat format;
  final int quality;
  final List<int> heights;
  final bool enabled;
  final void Function(OutputFormat format, int quality) onChanged;

  const FormatPicker({
    super.key,
    required this.format,
    required this.quality,
    required this.heights,
    required this.enabled,
    required this.onChanged,
  });

  static List<int> qualitiesFor(OutputFormat format, List<int> heights) =>
      format == OutputFormat.mp4 ? heights : mp3Bitrates;

  @override
  Widget build(BuildContext context) {
    final qualities = qualitiesFor(format, heights);
    return Row(
      children: [
        SegmentedButton<OutputFormat>(
          segments: [
            ButtonSegment(
              value: OutputFormat.mp4,
              label: const Text('MP4 (vídeo)'),
              icon: const Icon(Icons.movie),
              enabled: heights.isNotEmpty,
            ),
            const ButtonSegment(value: OutputFormat.mp3, label: Text('MP3 (áudio)'), icon: Icon(Icons.music_note)),
          ],
          selected: {format},
          onSelectionChanged: enabled ? (s) => onChanged(s.first, qualitiesFor(s.first, heights).first) : null,
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: quality,
          onChanged: enabled ? (q) => onChanged(format, q!) : null,
          items: [
            for (final q in qualities)
              DropdownMenuItem(value: q, child: Text(format == OutputFormat.mp4 ? '${q}p' : '$q kbps')),
          ],
        ),
      ],
    );
  }
}
