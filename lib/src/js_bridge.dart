/// JavaScript code injected into the WebView to bridge postMessage communication.
class JsBridge {
  /// The name of the JavaScript channel used for communication
  static const String channelName = 'GameBridge';

  /// JavaScript code to inject after the page loads.
  ///
  /// This code:
  /// 1. Intercepts postMessage events from the game
  /// 2. Forwards them to Flutter via the GameBridge channel
  /// 3. Provides a function to send messages back to the game
  static const String bridgeScript = '''
(function() {
  // Prevent double initialization
  if (window._gameBridgeInitialized) return;
  window._gameBridgeInitialized = true;

  // Listen for messages from the game (sent to parent)
  window.addEventListener('message', function(event) {
    // Only handle messages with our expected structure
    if (event.data && typeof event.data === 'object' && event.data.type) {
      try {
        // Forward to Flutter
        $channelName.postMessage(JSON.stringify(event.data));
      } catch (e) {
        console.error('GameBridge: Failed to forward message', e);
      }
    }
  });

  // Function for Flutter to send messages to the game
  // The game listens on window for these messages
  window.sendToGame = function(messageJson) {
    try {
      var message = JSON.parse(messageJson);
      window.postMessage(message, '*');
    } catch (e) {
      console.error('GameBridge: Failed to send message to game', e);
    }
  };

  console.log('GameBridge: Initialized');
})();
''';

  /// Generates JavaScript to send a message to the game
  static String sendMessageScript(String type, Map<String, dynamic> payload) {
    final payloadJson = _encodeJson(payload);
    return '''
window.sendToGame('{"type":"$type","payload":$payloadJson}');
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
