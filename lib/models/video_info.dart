class VideoInfo {
  final String url;
  final String title;
  final String author;
  final String thumbnail;
  final Duration duration;

  /// Available video heights (e.g. 1080, 720), highest first. Empty for audio-only.
  final List<int> heights;

  const VideoInfo({
    required this.url,
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.duration,
    required this.heights,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    final heights = <int>{
      for (final f in (json['formats'] as List? ?? []))
        if (f['vcodec'] != null && f['vcodec'] != 'none' && f['height'] is int)
          f['height'] as int,
    }.toList()
      ..sort((a, b) => b.compareTo(a));

    return VideoInfo(
      url: json['webpage_url'] ?? json['original_url'] ?? '',
      title: json['track'] ?? json['title'] ?? '',
      author: json['artist'] ?? json['channel'] ?? json['uploader'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: Duration(seconds: (json['duration'] as num? ?? 0).round()),
      heights: heights,
    );
  }
}
