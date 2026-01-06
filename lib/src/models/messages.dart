/// Message types sent FROM the game TO the platform
enum GameOutboundMessage {
  /// Game requests session validation
  sessionStart,

  /// Player started playing
  gameStart,

  /// Score changed during gameplay
  scoreUpdate,

  /// Player beat their high score
  newHighScore,

  /// Game ended normally
  gameOver,

  /// Game ended due to tab close/navigation
  gameTerminated,
}

/// Message types sent TO the game FROM the platform
enum GameInboundMessage {
  /// Session validated successfully
  sessionConfirmed,

  /// Session validation failed
  sessionRejected,
}

/// Extension to convert enum to postMessage type strings
extension GameOutboundMessageExtension on GameOutboundMessage {
  String get messageType {
    switch (this) {
      case GameOutboundMessage.sessionStart:
        return 'SESSION_START';
      case GameOutboundMessage.gameStart:
        return 'GAME_START';
      case GameOutboundMessage.scoreUpdate:
        return 'SCORE_UPDATE';
      case GameOutboundMessage.newHighScore:
        return 'NEW_HIGH_SCORE';
      case GameOutboundMessage.gameOver:
        return 'GAME_OVER';
      case GameOutboundMessage.gameTerminated:
        return 'GAME_TERMINATED';
    }
  }

  static GameOutboundMessage? fromString(String type) {
    switch (type) {
      case 'SESSION_START':
        return GameOutboundMessage.sessionStart;
      case 'GAME_START':
        return GameOutboundMessage.gameStart;
      case 'SCORE_UPDATE':
        return GameOutboundMessage.scoreUpdate;
      case 'NEW_HIGH_SCORE':
        return GameOutboundMessage.newHighScore;
      case 'GAME_OVER':
        return GameOutboundMessage.gameOver;
      case 'GAME_TERMINATED':
        return GameOutboundMessage.gameTerminated;
      default:
        return null;
    }
  }
}

extension GameInboundMessageExtension on GameInboundMessage {
  String get messageType {
    switch (this) {
      case GameInboundMessage.sessionConfirmed:
        return 'SESSION_CONFIRMED';
      case GameInboundMessage.sessionRejected:
        return 'SESSION_REJECTED';
    }
  }
}
