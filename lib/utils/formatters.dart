/// Small, pure formatting helpers used across the UI so unit-conversion
/// and display logic lives in one place instead of being repeated in
/// every widget that shows flight data.
class Formatters {
  Formatters._();

  static String altitude(double? meters) {
    if (meters == null) return '—';
    final feet = (meters * 3.28084).round();
    return '${_thousands(feet)} ft';
  }

  static String speed(double? metersPerSecond) {
    if (metersPerSecond == null) return '—';
    final knots = (metersPerSecond * 1.94384).round();
    return '$knots kts';
  }

  static String verticalRate(double? metersPerSecond) {
    if (metersPerSecond == null || metersPerSecond.abs() < 0.5) return 'Level flight';
    final feetPerMinute = (metersPerSecond * 196.85).round();
    return feetPerMinute > 0
        ? 'Climbing ${_thousands(feetPerMinute)} ft/min'
        : 'Descending ${_thousands(feetPerMinute.abs())} ft/min';
  }

  static String heading(double? degrees) {
    if (degrees == null) return '—';
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees % 360) / 45).round() % 8;
    return '${degrees.round()}° ${directions[index]}';
  }

  static String lastSeen(int epochSeconds) {
    if (epochSeconds == 0) return 'Unknown';
    final timestamp = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    final difference = DateTime.now().difference(timestamp);
    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    return '${difference.inHours}h ago';
  }

  static String _thousands(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
