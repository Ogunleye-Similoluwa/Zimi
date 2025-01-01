enum LyricsSource {
  video,
  audio
}

class TimedLyrics {
  final String text;
  final Map<LyricsSource, Duration> timestamps;

  TimedLyrics({
    required this.text,
    required this.timestamps,
  });

  Duration? getTimestampFor(LyricsSource source) => timestamps[source];
}

class LyricsLine {
  final String text;
  final Duration? timestamp;

  LyricsLine({
    required this.text,
    this.timestamp,
  });

  factory LyricsLine.fromLRC(String line) {
    final RegExp timeRegex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\]');
    final match = timeRegex.firstMatch(line);
    
    if (match != null) {
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final milliseconds = int.parse(match.group(3)!) * 10;
      
      final timestamp = Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
      
      final text = line.substring(match.end).trim();
      return LyricsLine(text: text, timestamp: timestamp);
    }
    
    return LyricsLine(text: line, timestamp: null);
  }
}