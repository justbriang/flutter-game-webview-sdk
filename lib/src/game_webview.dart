import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'game_controller.dart';
import 'js_bridge.dart';
import 'models/game_stats.dart';
import 'models/messages.dart';
import 'models/score_update.dart';
import 'models/session_config.dart';

/// Callback when game requests session validation.
///
/// Return `true` to confirm the session, `false` to reject it.
/// If you need async validation, use [GameController.confirmSession] instead.
typedef SessionStartCallback = Future<bool> Function(
  String sessionId,
  String authToken,
);

/// Callback when player starts playing.
typedef GameStartCallback = void Function(String sessionId);

/// Callback for real-time score updates.
typedef ScoreUpdateCallback = void Function(ScoreUpdate update);

/// Callback when player beats their high score.
typedef NewHighScoreCallback = void Function(HighScoreUpdate update);

/// Callback when game ends normally.
typedef GameOverCallback = Future<void> Function(
  int finalScore,
  GameStats stats,
  String sessionId,
);

/// Callback when game is terminated (tab close, navigation).
typedef GameTerminatedCallback = Future<void> Function(
  int finalScore,
  GameStats stats,
  String sessionId,
  String reason,
);

/// A widget that embeds a game via WebView with postMessage integration.
///
/// Basic usage:
/// ```dart
/// GameWebView(
///   gameUrl: 'https://tribeblast.postdit.co',
///   session: SessionConfig(
///     sessionId: 'sess_123',
///     authToken: 'tok_456',
///     highScore: 15000,
///     playerName: 'Player1',
///   ),
///   onSessionStart: (sessionId, authToken) async {
///     // Validate with your backend
///     return true; // or false to reject
///   },
///   onGameOver: (score, stats, sessionId) async {
///     // Save score to your backend
///   },
/// )
/// ```
class GameWebView extends StatefulWidget {
  /// Base URL of the game.
  final String gameUrl;

  /// Session configuration with credentials.
  ///
  /// If provided, the URL will include sessionId and authToken query params.
  /// If null, the game will run in standalone mode.
  final SessionConfig? session;

  /// Controller for programmatic interaction.
  final GameController? controller;

  /// Called when the game requests session validation.
  ///
  /// Return `true` to confirm, `false` to reject.
  /// If not provided and [session] is set, auto-confirms with session data.
  final SessionStartCallback? onSessionStart;

  /// Called when the player starts playing.
  final GameStartCallback? onGameStart;

  /// Called when the score changes during gameplay.
  final ScoreUpdateCallback? onScoreUpdate;

  /// Called when the player beats their high score.
  final NewHighScoreCallback? onNewHighScore;

  /// Called when the game ends normally.
  final GameOverCallback? onGameOver;

  /// Called when the game is terminated (e.g., app backgrounded).
  final GameTerminatedCallback? onGameTerminated;

  /// Called when the WebView starts loading.
  final VoidCallback? onLoadStart;

  /// Called when the WebView finishes loading.
  final VoidCallback? onLoadFinished;

  /// Called when the WebView encounters an error.
  final void Function(String error)? onError;

  /// Widget to show while loading.
  final Widget? loadingWidget;

  /// Background color for the WebView.
  final Color backgroundColor;

  /// User agent string (optional).
  final String? userAgent;

  const GameWebView({
    super.key,
    required this.gameUrl,
    this.session,
    this.controller,
    this.onSessionStart,
    this.onGameStart,
    this.onScoreUpdate,
    this.onNewHighScore,
    this.onGameOver,
    this.onGameTerminated,
    this.onLoadStart,
    this.onLoadFinished,
    this.onError,
    this.loadingWidget,
    this.backgroundColor = Colors.black,
    this.userAgent,
  });

  @override
  State<GameWebView> createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _bridgeInjected = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor)
      ..addJavaScriptChannel(
        JsBridge.channelName,
        onMessageReceived: _handleGameMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _bridgeInjected = false;
            setState(() => _isLoading = true);
            widget.controller?.setLoading(true);
            widget.onLoadStart?.call();
          },
          onPageFinished: (_) async {
            // Inject the bridge script
            await _injectBridge();
            setState(() => _isLoading = false);
            widget.controller?.setLoading(false);
            widget.onLoadFinished?.call();
          },
          onWebResourceError: (error) {
            widget.onError?.call(error.description);
          },
        ),
      );

    // Set user agent if provided
    if (widget.userAgent != null) {
      _webViewController.setUserAgent(widget.userAgent);
    }

    // Attach controller
    widget.controller?.attach(_webViewController);

    // Load the game
    _loadGame();
  }

  void _loadGame() {
    final url = _buildGameUrl();
    _webViewController.loadRequest(Uri.parse(url));
  }

  String _buildGameUrl() {
    final baseUri = Uri.parse(widget.gameUrl);

    if (widget.session == null) {
      return widget.gameUrl;
    }

    // Add session params to URL
    final queryParams = Map<String, String>.from(baseUri.queryParameters);
    queryParams['sessionId'] = widget.session!.sessionId;
    queryParams['authToken'] = widget.session!.authToken;

    return baseUri.replace(queryParameters: queryParams).toString();
  }

  Future<void> _injectBridge() async {
    if (_bridgeInjected) return;
    _bridgeInjected = true;
    await _webViewController.runJavaScript(JsBridge.bridgeScript);
  }

  void _handleGameMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final payload = data['payload'] as Map<String, dynamic>? ?? {};

      final messageType = GameOutboundMessageExtension.fromString(type ?? '');
      if (messageType == null) {
        debugPrint('GameWebView: Unknown message type: $type');
        return;
      }

      _handleMessage(messageType, payload);
    } catch (e) {
      debugPrint('GameWebView: Failed to parse message: $e');
    }
  }

  Future<void> _handleMessage(
    GameOutboundMessage type,
    Map<String, dynamic> payload,
  ) async {
    switch (type) {
      case GameOutboundMessage.sessionStart:
        await _handleSessionStart(payload);
        break;

      case GameOutboundMessage.gameStart:
        final sessionId = payload['sessionId'] as String? ?? '';
        widget.onGameStart?.call(sessionId);
        break;

      case GameOutboundMessage.scoreUpdate:
        final update = ScoreUpdate.fromMap(payload);
        widget.onScoreUpdate?.call(update);
        break;

      case GameOutboundMessage.newHighScore:
        final update = HighScoreUpdate.fromMap(payload);
        widget.onNewHighScore?.call(update);
        break;

      case GameOutboundMessage.gameOver:
        await _handleGameOver(payload);
        break;

      case GameOutboundMessage.gameTerminated:
        await _handleGameTerminated(payload);
        break;
    }
  }

  Future<void> _handleSessionStart(Map<String, dynamic> payload) async {
    final sessionId = payload['sessionId'] as String? ?? '';
    final authToken = payload['authToken'] as String? ?? '';

    // Store pending session info in controller
    if (widget.session != null) {
      widget.controller?.setPendingSession(widget.session);
    }

    // If callback provided, let developer handle validation
    if (widget.onSessionStart != null) {
      final confirmed = await widget.onSessionStart!(sessionId, authToken);
      if (confirmed) {
        await _confirmSession(sessionId);
      } else {
        await _rejectSession(sessionId, 'Session rejected by app');
      }
      return;
    }

    // Auto-confirm if session config provided
    if (widget.session != null) {
      await _confirmSession(sessionId);
    }
    // Otherwise, let the game timeout and enter standalone mode
  }

  Future<void> _confirmSession(String sessionId) async {
    final script = JsBridge.confirmSessionScript(
      sessionId: sessionId,
      highScore: widget.session?.highScore ?? 0,
      playerName: widget.session?.playerName,
    );
    await _webViewController.runJavaScript(script);
    widget.controller?.setSessionConfirmed(true);
  }

  Future<void> _rejectSession(String sessionId, String reason) async {
    final script = JsBridge.rejectSessionScript(
      sessionId: sessionId,
      reason: reason,
    );
    await _webViewController.runJavaScript(script);
    widget.controller?.setPendingSession(null);
  }

  Future<void> _handleGameOver(Map<String, dynamic> payload) async {
    final sessionId = payload['sessionId'] as String? ?? '';
    final finalScore = (payload['finalScore'] as num?)?.toInt() ?? 0;
    final statsMap = payload['stats'] as Map<String, dynamic>? ?? {};
    final stats = GameStats.fromMap(statsMap);

    await widget.onGameOver?.call(finalScore, stats, sessionId);
  }

  Future<void> _handleGameTerminated(Map<String, dynamic> payload) async {
    final sessionId = payload['sessionId'] as String? ?? '';
    final finalScore = (payload['finalScore'] as num?)?.toInt() ?? 0;
    final statsMap = payload['stats'] as Map<String, dynamic>? ?? {};
    final stats = GameStats.fromMap(statsMap);
    final reason = payload['reason'] as String? ?? 'unknown';

    await widget.onGameTerminated?.call(finalScore, stats, sessionId, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          widget.loadingWidget ??
              Container(
                color: widget.backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ],
    );
  }
}
