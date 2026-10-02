import 'package:baixaryt/models/video_info.dart';
import 'package:baixaryt/services/yt_dlp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VideoInfo collects distinct video heights, highest first', () {
    final info = VideoInfo.fromJson({
      'webpage_url': 'https://www.youtube.com/watch?v=x',
      'title': 'Video',
      'channel': 'Channel',
      'duration': 61.4,
      'formats': [
        {'vcodec': 'none', 'height': null},
        {'vcodec': 'avc1', 'height': 720},
        {'vcodec': 'vp9', 'height': 1080},
        {'vcodec': 'avc1', 'height': 720},
      ],
    });
    expect(info.heights, [1080, 720]);
    expect(info.duration, const Duration(seconds: 61));
    expect(info.author, 'Channel');
  });

  test('parsePercent reads progress-template lines only', () {
    expect(YtDlp.parsePercent(' 45.3%'), closeTo(0.453, 1e-9));
    expect(YtDlp.parsePercent(r'C:\Users\me\Downloads\song 100%.mp3'), isNull);
  });
}
