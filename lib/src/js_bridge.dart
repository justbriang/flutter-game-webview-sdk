/// Utilities for JavaScript channel communication between Flutter and game.
///
/// The game calls window.GameBridge.postMessage() directly to send messages to Flutter.
/// Flutter uses evaluateJavascript with window.postMessage() to send messages to the game.
class JsBridge {
  /// The name of the JavaScript channel used for communication
  static const String channelName = 'GameBridge';

  /// Generates JavaScript to send a message to the game
  static String sendMessageScript(String type, Map<String, dynamic> payload) {
    final payloadJson = _encodeJson(payload);
    return '''
window.postMessage({"type":"$type","payload":$payloadJson}, '*');
''';
  }

  /// Generates JavaScript to send SESSION_CONFIRMED
  static String confirmSessionScript({
    required String sessionId,
    required int highScore,
    String? playerName,
  }) {
    final payload = {
      'sessionId': sessionId,
      'highScore': highScore,
      if (playerName != null) 'playerName': playerName,
    };
    return sendMessageScript('SESSION_CONFIRMED', payload);
  }

  /// Generates JavaScript to send SESSION_REJECTED
  static String rejectSessionScript({
    required String sessionId,
    required String reason,
  }) {
    final payload = {
      'sessionId': sessionId,
      'reason': reason,
    };
    return sendMessageScript('SESSION_REJECTED', payload);
  }

  /// Simple JSON encoder that handles our payload types
  static String _encodeJson(Map<String, dynamic> map) {
    final parts = <String>[];
    map.forEach((key, value) {
      final encodedValue = _encodeValue(value);
      parts.add('"$key":$encodedValue');
    });
    return '{${parts.join(',')}}';
  }

  static String _encodeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeString(value)}"';
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    if (value is Map<String, dynamic>) return _encodeJson(value);
    if (value is List) {
      final items = value.map(_encodeValue).join(',');
      return '[$items]';
    }
    return '"${_escapeString(value.toString())}"';
  }

  static String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
