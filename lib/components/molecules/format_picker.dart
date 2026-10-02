import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

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

  // Forui has no segmented control: the selected option is a primary button, the other an outline one.
  Widget _option(OutputFormat value, String label, IconData icon) => FButton(
        variant: format == value ? .primary : .outline,
        mainAxisSize: .min,
        prefix: Icon(icon),
        onPress: enabled && (value == OutputFormat.mp3 || heights.isNotEmpty)
            ? () => onChanged(value, qualitiesFor(value, heights).first)
            : null,
        child: Text(label),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _option(OutputFormat.mp4, 'MP4 (vídeo)', FLucideIcons.film),
        const SizedBox(width: 8),
        _option(OutputFormat.mp3, 'MP3 (áudio)', FLucideIcons.music),
        const SizedBox(width: 16),
        SizedBox(
          width: 160,
          child: FSelect<int>(
            enabled: enabled,
            items: {
              for (final q in qualitiesFor(format, heights)) format == OutputFormat.mp4 ? '${q}p' : '$q kbps': q,
            },
            control: .lifted(value: quality, onChange: (q) => q == null ? null : onChanged(format, q)),
          ),
        ),
      ],
    );
  }
}
