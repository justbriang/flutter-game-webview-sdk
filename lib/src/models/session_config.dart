/// Configuration for a game session.
///
/// Contains the credentials needed to authenticate with the game
/// and optional user information.
class SessionConfig {
  /// Unique session identifier from your backend
  final String sessionId;

  /// Authentication token for this session
  final String authToken;

  /// Player's previous high score (optional)
  ///
  /// If provided, will be sent to the game on session confirmation.
  final int? highScore;

  /// Player's display name (optional)
  ///
  /// If provided, will be shown in the game UI.
  final String? playerName;

  const SessionConfig({
    required this.sessionId,
    required this.authToken,
    this.highScore,
    this.playerName,
  });

  /// Creates a SessionConfig from a map (e.g., from JSON)
  factory SessionConfig.fromMap(Map<String, dynamic> map) {
    return SessionConfig(
      sessionId: map['sessionId'] as String,
      authToken: map['authToken'] as String,
      highScore: map['highScore'] as int?,
      playerName: map['playerName'] as String?,
    );
  }

  /// Converts to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'authToken': authToken,
      if (highScore != null) 'highScore': highScore,
      if (playerName != null) 'playerName': playerName,
    };
  }

  @override
  String toString() {
    return 'SessionConfig(sessionId: $sessionId, authToken: [hidden], highScore: $highScore, playerName: $playerName)';
  }
}
