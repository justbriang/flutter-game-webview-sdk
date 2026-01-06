/// Statistics from a completed game session.
///
/// Sent with GAME_OVER and GAME_TERMINATED messages.
class GameStats {
  /// Total number of pieces/blocks placed during the game
  final int totalPiecesPlaced;

  /// Total number of lines cleared
  final int totalLinesCleared;

  /// Unix timestamp (milliseconds) when the game started
  final int gameStartTime;

  /// Unix timestamp (milliseconds) when the game ended
  final int gameEndTime;

  /// Total play duration in milliseconds
  final int playDuration;

  const GameStats({
    required this.totalPiecesPlaced,
    required this.totalLinesCleared,
    required this.gameStartTime,
    required this.gameEndTime,
    required this.playDuration,
  });

  /// Creates GameStats from a map (parsed from JSON)
  factory GameStats.fromMap(Map<String, dynamic> map) {
    return GameStats(
      totalPiecesPlaced: (map['totalPiecesPlaced'] as num?)?.toInt() ?? 0,
      totalLinesCleared: (map['totalLinesCleared'] as num?)?.toInt() ?? 0,
      gameStartTime: (map['gameStartTime'] as num?)?.toInt() ?? 0,
      gameEndTime: (map['gameEndTime'] as num?)?.toInt() ?? 0,
      playDuration: (map['playDuration'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'totalPiecesPlaced': totalPiecesPlaced,
      'totalLinesCleared': totalLinesCleared,
      'gameStartTime': gameStartTime,
      'gameEndTime': gameEndTime,
      'playDuration': playDuration,
    };
  }

  /// Returns the play duration as a Duration object
  Duration get playDurationAsDuration => Duration(milliseconds: playDuration);

  /// Returns the game start time as a DateTime
  DateTime get gameStartDateTime =>
      DateTime.fromMillisecondsSinceEpoch(gameStartTime);

  /// Returns the game end time as a DateTime
  DateTime get gameEndDateTime =>
      DateTime.fromMillisecondsSinceEpoch(gameEndTime);

  @override
  String toString() {
    return 'GameStats(pieces: $totalPiecesPlaced, lines: $totalLinesCleared, duration: ${playDuration}ms)';
  }
}
