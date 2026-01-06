# Game WebView SDK

A Flutter SDK for embedding games that use the postMessage protocol (like TribeBlast) in your mobile app.

## Features

- WebView-based game embedding
- Automatic postMessage communication handling
- Session management with callbacks
- Real-time score updates
- Game over and termination handling
- Optional programmatic control via `GameController`

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  game_webview_sdk:
    git:
      url: https://github.com/justbriang/flutter-game-webview-sdk.git
      ref: v1.0.0  # or 'main' for latest
```

Then run:
```bash
flutter pub get
```

## Quick Start

### Simplest Integration (Standalone Mode)

```dart
import 'package:game_webview_sdk/game_webview_sdk.dart';

// Game runs in standalone mode with localStorage high scores
GameWebView(
  gameUrl: 'https://tribeblast.postdit.co',
)
```

### Full Integration (With Your Backend)

```dart
import 'package:game_webview_sdk/game_webview_sdk.dart';

GameWebView(
  gameUrl: 'https://tribeblast.postdit.co',
  session: SessionConfig(
    sessionId: 'sess_abc123',      // From your backend
    authToken: 'tok_xyz789',       // From your backend
    highScore: 15000,              // User's previous high score
    playerName: 'JohnDoe',         // Optional display name
  ),
  onSessionStart: (sessionId, authToken) async {
    // Optional: Validate with your backend
    final isValid = await myApi.validateSession(sessionId, authToken);
    return isValid;  // Return true to confirm, false to reject
  },
  onScoreUpdate: (update) {
    // Real-time score updates
    print('Score: ${update.score}');
  },
  onNewHighScore: (update) {
    // Player beat their high score!
    print('New high score: ${update.score}');
  },
  onGameOver: (finalScore, stats, sessionId) async {
    // Save the final score to your backend
    await myApi.saveScore(
      sessionId: sessionId,
      score: finalScore,
      stats: stats.toMap(),
    );
  },
  onGameTerminated: (finalScore, stats, sessionId, reason) async {
    // Handle early termination (app backgrounded, etc.)
    await myApi.savePartialScore(sessionId, finalScore);
  },
)
```

## API Reference

### GameWebView

The main widget for embedding games.

| Parameter | Type | Description |
|-----------|------|-------------|
| `gameUrl` | `String` | Base URL of the game (required) |
| `session` | `SessionConfig?` | Session credentials and user info |
| `controller` | `GameController?` | Controller for programmatic interaction |
| `onSessionStart` | `Future<bool> Function(sessionId, authToken)?` | Called when game requests validation |
| `onGameStart` | `void Function(sessionId)?` | Called when player starts playing |
| `onScoreUpdate` | `void Function(ScoreUpdate)?` | Real-time score updates |
| `onNewHighScore` | `void Function(HighScoreUpdate)?` | Player beat their high score |
| `onGameOver` | `Future<void> Function(score, stats, sessionId)?` | Game ended normally |
| `onGameTerminated` | `Future<void> Function(score, stats, sessionId, reason)?` | Game terminated early |
| `loadingWidget` | `Widget?` | Custom loading indicator |
| `backgroundColor` | `Color` | Background color (default: black) |

### SessionConfig

Configuration for a game session.

```dart
SessionConfig(
  sessionId: 'sess_123',     // Required: Unique session ID
  authToken: 'tok_456',      // Required: Auth token
  highScore: 15000,          // Optional: Previous high score
  playerName: 'Player1',     // Optional: Display name
)
```

### GameController

For programmatic control over the game.

```dart
final controller = GameController();

// Use with widget
GameWebView(
  gameUrl: 'https://tribeblast.postdit.co',
  controller: controller,
)

// Programmatic actions
await controller.confirmSession(
  sessionId: 'sess_123',
  highScore: 15000,
  playerName: 'Player1',
);

await controller.rejectSession(
  sessionId: 'sess_123',
  reason: 'Invalid token',
);

await controller.reload();

// Check state
controller.isLoading;
controller.isSessionConfirmed;
```

### GameStats

Statistics from a completed game.

```dart
GameStats(
  totalPiecesPlaced: 47,
  totalLinesCleared: 12,
  gameStartTime: 1699999900000,    // Unix timestamp (ms)
  gameEndTime: 1699999999999,
  playDuration: 99999,             // milliseconds
)

// Convenience methods
stats.playDurationAsDuration;  // Duration object
stats.gameStartDateTime;       // DateTime object
stats.gameEndDateTime;         // DateTime object
```

### ScoreUpdate

Real-time score update during gameplay.

```dart
ScoreUpdate(
  sessionId: 'sess_123',
  score: 5000,
  linesCleared: 5,
  piecesPlaced: 20,
  checksum: 'abc123',  // Anti-cheat checksum
)
```

### HighScoreUpdate

Notification when player beats their high score.

```dart
HighScoreUpdate(
  sessionId: 'sess_123',
  score: 20000,
  previousHigh: 15000,
  checksum: 'def456',
)
```

## Session Flow

1. Your app creates a session on your backend, gets `sessionId` and `authToken`
2. Pass these to `GameWebView` via `SessionConfig`
3. Game loads and sends `SESSION_START` message
4. SDK calls your `onSessionStart` callback (if provided)
5. Return `true` to confirm or `false` to reject
6. Game proceeds, SDK calls your callbacks for events
7. On game over, SDK calls `onGameOver` with final score and stats
8. Save the score to your backend

## Standalone Mode

If no `SessionConfig` is provided, or if session validation fails/times out (5 seconds), the game runs in standalone mode:

- High scores saved to browser localStorage
- No session tracking
- Game is fully playable

## Platform Setup

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### Android

Ensure `minSdkVersion` is at least 19 in `android/app/build.gradle`:

```gradle
defaultConfig {
    minSdkVersion 19
}
```

## License

MIT
# flutter-game-webview-sdk
