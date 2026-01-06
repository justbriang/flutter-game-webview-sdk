import 'package:flutter/material.dart';
import 'package:game_webview_sdk/game_webview_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game WebView SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game SDK Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _playStandalone(context),
              child: const Text('Play Standalone'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _playWithSession(context),
              child: const Text('Play with Session'),
            ),
          ],
        ),
      ),
    );
  }

  void _playStandalone(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StandaloneGamePage(),
      ),
    );
  }

  void _playWithSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SessionGamePage(),
      ),
    );
  }
}

/// Example: Standalone mode (no session, localStorage high scores)
class StandaloneGamePage extends StatelessWidget {
  const StandaloneGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TribeBlast (Standalone)'),
      ),
      body: GameWebView(
        gameUrl: 'https://tribeblast.postdit.co',
        onScoreUpdate: (update) {
          debugPrint('Score: ${update.score}');
        },
      ),
    );
  }
}

/// Example: Full integration with session management
class SessionGamePage extends StatefulWidget {
  const SessionGamePage({super.key});

  @override
  State<SessionGamePage> createState() => _SessionGamePageState();
}

class _SessionGamePageState extends State<SessionGamePage> {
  final GameController _controller = GameController();
  int _currentScore = 0;
  int _highScore = 15000; // Would come from your backend

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TribeBlast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Score display
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreDisplay(label: 'Score', value: _currentScore),
                _ScoreDisplay(label: 'High Score', value: _highScore),
              ],
            ),
          ),
          // Game
          Expanded(
            child: GameWebView(
              gameUrl: 'https://tribeblast.postdit.co',
              controller: _controller,
              session: SessionConfig(
                // In a real app, get these from your backend
                sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
                authToken: 'tok_demo_${DateTime.now().millisecondsSinceEpoch}',
                highScore: _highScore,
                playerName: 'DemoPlayer',
              ),
              onSessionStart: (sessionId, authToken) async {
                // In a real app, validate with your backend here
                debugPrint('Session start: $sessionId');
                // Simulate backend validation
                await Future.delayed(const Duration(milliseconds: 100));
                return true; // Confirm session
              },
              onGameStart: (sessionId) {
                debugPrint('Game started: $sessionId');
              },
              onScoreUpdate: (update) {
                setState(() {
                  _currentScore = update.score;
                });
              },
              onNewHighScore: (update) {
                setState(() {
                  _highScore = update.score;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New High Score: ${update.score}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onGameOver: (finalScore, stats, sessionId) async {
                debugPrint('Game over! Score: $finalScore');
                debugPrint('Stats: ${stats.toString()}');
                debugPrint('Duration: ${stats.playDurationAsDuration.inSeconds}s');

                // In a real app, save to your backend
                // await myApi.saveScore(sessionId, finalScore, stats);

                if (mounted) {
                  _showGameOverDialog(finalScore, stats);
                }
              },
              onGameTerminated: (finalScore, stats, sessionId, reason) async {
                debugPrint('Game terminated: $reason, Score: $finalScore');
                // Save partial progress to backend
              },
              loadingWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading TribeBlast...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(int finalScore, GameStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Final Score: $finalScore'),
            Text('Lines Cleared: ${stats.totalLinesCleared}'),
            Text('Pieces Placed: ${stats.totalPiecesPlaced}'),
            Text('Duration: ${stats.playDurationAsDuration.inSeconds}s'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.reload();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
