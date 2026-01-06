/// A Flutter SDK for embedding games that use the postMessage protocol.
///
/// This package provides a WebView-based widget for integrating games
/// like TribeBlast into your Flutter app with session management
/// and event callbacks.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:game_webview_sdk/game_webview_sdk.dart';
///
/// GameWebView(
///   gameUrl: 'https://tribeblast.postdit.co',
///   session: SessionConfig(
///     sessionId: 'sess_123',
///     authToken: 'tok_456',
///     highScore: 15000,
///     playerName: 'Player1',
///   ),
///   onGameOver: (score, stats, sessionId) async {
///     // Save to your backend
///   },
/// )
/// ```
library game_webview_sdk;

// Main widget
export 'src/game_webview.dart';

// Controller
export 'src/game_controller.dart';

// Models
export 'src/models/game_config.dart';
export 'src/models/game_stats.dart';
export 'src/models/messages.dart';
export 'src/models/score_update.dart';
export 'src/models/session_config.dart';
