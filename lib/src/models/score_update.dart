/// Real-time score update from the game.
///
/// Sent via SCORE_UPDATE message during gameplay.
class ScoreUpdate {
  /// Current session ID
  final String sessionId;

  /// Current score
  final int score;

  /// Total lines cleared so far
  final int linesCleared;

  /// Total pieces placed so far
  final int piecesPlaced;

  /// Anti-cheat checksum (optional)
  final String? checksum;

  const ScoreUpdate({
    required this.sessionId,
    required this.score,
    required this.linesCleared,
    required this.piecesPlaced,
    this.checksum,
  });

  /// Creates a ScoreUpdate from a map (parsed from JSON)
  factory ScoreUpdate.fromMap(Map<String, dynamic> map) {
    return ScoreUpdate(
      sessionId: map['sessionId'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      linesCleared: (map['linesCleared'] as num?)?.toInt() ?? 0,
      piecesPlaced: (map['piecesPlaced'] as num?)?.toInt() ?? 0,
      checksum: map['checksum'] as String?,
    );
  }

  /// Converts to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'score': score,
      'linesCleared': linesCleared,
      'piecesPlaced': piecesPlaced,
      if (checksum != null) 'checksum': checksum,
    };
  }

  @override
  String toString() {
    return 'ScoreUpdate(score: $score, lines: $linesCleared, pieces: $piecesPlaced)';
  }
}

/// High score notification from the game.
///
/// Sent via NEW_HIGH_SCORE message when player beats their record.
class HighScoreUpdate {
  /// Current session ID
  final String sessionId;

  /// New high score
  final int score;

  /// Previous high score
  final int previousHigh;

  /// Anti-cheat checksum (optional)
  final String? checksum;

  const HighScoreUpdate({
    required this.sessionId,
    required this.score,
    required this.previousHigh,
    this.checksum,
  });

  /// Creates a HighScoreUpdate from a map (parsed from JSON)
  factory HighScoreUpdate.fromMap(Map<String, dynamic> map) {
    return HighScoreUpdate(
      sessionId: map['sessionId'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      previousHigh: (map['previousHigh'] as num?)?.toInt() ?? 0,
      checksum: map['checksum'] as String?,
    );
  }

  /// Converts to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'score': score,
      'previousHigh': previousHigh,
      if (checksum != null) 'checksum': checksum,
    };
  }

  @override
  String toString() {
    return 'HighScoreUpdate(score: $score, previousHigh: $previousHigh)';
  }
}
