import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'js_bridge.dart';
import 'models/session_config.dart';

/// Controller for programmatic interaction with the GameWebView.
///
/// Use this to:
/// - Confirm or reject sessions programmatically
/// - Reload the game
/// - Access the underlying WebViewController
class GameController extends ChangeNotifier {
  WebViewController? _webViewController;
  SessionConfig? _pendingSession;
  bool _isSessionConfirmed = false;
  bool _isLoading = true;

  /// Whether the game is currently loading
  bool get isLoading => _isLoading;

  /// Whether the session has been confirmed
  bool get isSessionConfirmed => _isSessionConfirmed;

  /// The pending session awaiting confirmation (if any)
  SessionConfig? get pendingSession => _pendingSession;

  /// Internal: Called by GameWebView to attach the WebViewController
  @internal
  void attach(WebViewController controller) {
    _webViewController = controller;
  }

  /// Internal: Called when loading state changes
  @internal
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Internal: Called when a session start is received
  @internal
  void setPendingSession(SessionConfig? session) {
    _pendingSession = session;
    notifyListeners();
  }

  /// Internal: Called when session is confirmed
  @internal
  void setSessionConfirmed(bool confirmed) {
    _isSessionConfirmed = confirmed;
    if (confirmed) {
      _pendingSession = null;
    }
    notifyListeners();
  }

  /// Confirms the session with the game.
  ///
  /// Call this after validating the session with your backend.
  /// The game will start and allow the player to play.
  Future<void> confirmSession({
    required String sessionId,
    int highScore = 0,
    String? playerName,
  }) async {
    final controller = _webViewController;
    if (controller == null) {
      throw StateError('GameController not attached to a GameWebView');
    }

    final script = JsBridge.confirmSessionScript(
      sessionId: sessionId,
      highScore: highScore,
      playerName: playerName,
    );

    await controller.runJavaScript(script);
    _isSessionConfirmed = true;
    _pendingSession = null;
    notifyListeners();
  }

  /// Rejects the session.
  ///
  /// The game will fall back to standalone mode with localStorage high scores.
  Future<void> rejectSession({
    required String sessionId,
    String reason = 'Session rejected',
  }) async {
    final controller = _webViewController;
    if (controller == null) {
      throw StateError('GameController not attached to a GameWebView');
    }

    final script = JsBridge.rejectSessionScript(
      sessionId: sessionId,
      reason: reason,
    );

    await controller.runJavaScript(script);
    _pendingSession = null;
    notifyListeners();
  }

  /// Reloads the game.
  ///
  /// This will restart the session flow from the beginning.
  Future<void> reload() async {
    final controller = _webViewController;
    if (controller == null) {
      throw StateError('GameController not attached to a GameWebView');
    }

    _isSessionConfirmed = false;
    _pendingSession = null;
    _isLoading = true;
    notifyListeners();

    await controller.reload();
  }

  /// Sends a custom message to the game.
  ///
  /// Use this for custom extensions to the protocol.
  Future<void> sendMessage(String type, Map<String, dynamic> payload) async {
    final controller = _webViewController;
    if (controller == null) {
      throw StateError('GameController not attached to a GameWebView');
    }

    final script = JsBridge.sendMessageScript(type, payload);
    await controller.runJavaScript(script);
  }

  /// Gets the current URL loaded in the WebView.
  Future<String?> getCurrentUrl() async {
    return _webViewController?.currentUrl();
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
