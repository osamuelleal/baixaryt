import 'package:flutter/material.dart';

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
    final text = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 240,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                info.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(info.author, style: text.bodyMedium),
                  const SizedBox(height: 4),
                  Text(_duration, style: text.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
