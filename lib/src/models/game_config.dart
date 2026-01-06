/// Configuration for the GameWebView widget.
class GameConfig {
  /// Base URL of the game (e.g., 'https://tribeblast.postdit.co')
  final String gameUrl;

  /// Whether to show loading indicator while game loads
  final bool showLoadingIndicator;

  /// Background color while loading (default: transparent)
  final int? backgroundColor;

  /// User agent string (optional, uses default if not set)
  final String? userAgent;

  /// Whether to enable JavaScript (default: true, required for games)
  final bool enableJavaScript;

  /// Whether to allow inline media playback on iOS
  final bool allowsInlineMediaPlayback;

  /// Media autoplay policy
  final bool mediaPlaybackRequiresUserGesture;

  const GameConfig({
    required this.gameUrl,
    this.showLoadingIndicator = true,
    this.backgroundColor,
    this.userAgent,
    this.enableJavaScript = true,
    this.allowsInlineMediaPlayback = true,
    this.mediaPlaybackRequiresUserGesture = false,
  });

  /// Creates a copy with modified values
  GameConfig copyWith({
    String? gameUrl,
    bool? showLoadingIndicator,
    int? backgroundColor,
    String? userAgent,
    bool? enableJavaScript,
    bool? allowsInlineMediaPlayback,
    bool? mediaPlaybackRequiresUserGesture,
  }) {
    return GameConfig(
      gameUrl: gameUrl ?? this.gameUrl,
      showLoadingIndicator: showLoadingIndicator ?? this.showLoadingIndicator,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      userAgent: userAgent ?? this.userAgent,
      enableJavaScript: enableJavaScript ?? this.enableJavaScript,
      allowsInlineMediaPlayback:
          allowsInlineMediaPlayback ?? this.allowsInlineMediaPlayback,
      mediaPlaybackRequiresUserGesture: mediaPlaybackRequiresUserGesture ??
          this.mediaPlaybackRequiresUserGesture,
    );
  }
}
