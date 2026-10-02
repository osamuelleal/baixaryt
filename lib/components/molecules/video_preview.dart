import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../models/video_info.dart';

class VideoPreview extends StatelessWidget {
  final VideoInfo info;

  const VideoPreview({super.key, required this.info});

  String get _duration {
    final d = info.duration;
    final mmss = '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return d.inHours > 0 ? '${d.inHours}:$mmss' : mmss;
  }

  @override
  Widget build(BuildContext context) {
    return FCard(
      builder: (context, style, _) => Padding(
        padding: style.padding,
        child: Row(
          crossAxisAlignment: .start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 200,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    info.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(child: Icon(FLucideIcons.imageOff)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(info.title, style: style.titleTextStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(info.author, style: style.subtitleTextStyle),
                  const SizedBox(height: 4),
                  Text(_duration, style: style.subtitleTextStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
