import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Snap Choice Rush: a focused, two-choice reaction game.
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

enum _Page { home, modes, game, gameOver }

class _Challenge {
  const _Challenge({
    required this.prompt,
    required this.left,
    required this.right,
    required this.correct,
    required this.icon,
  });

  final String prompt;
  final String left;
  final String right;
  final int correct;
  final IconData icon;
}

class _UserScreenState extends State<UserScreen> {
  static const _ink = Color(0xFF202124);
  static const _soft = Color(0xFFF6F7F8);
  static const _line = Color(0xFFE2E5E9);
  static const _mint = Color(0xFF82E2BE);
  final _random = Random();
  Timer? _timer;

  _Page _page = _Page.home;
  String _mode = 'Snap Run';
  int _score = 0;
  int _streak = 0;
  int _bestScore = 0;
  int _lives = 1;
  int _round = 0;
  double _timeLeft = 1;
  int _totalReaction = 0;
  late _Challenge _challenge;

  final List<_Challenge> _challenges = const [
    _Challenge(
        prompt: 'Choose the arrow\npointing: UP',
        left: '↑',
        right: '↓',
        correct: 0,
        icon: Icons.north_rounded),
    _Challenge(
        prompt: 'Find the word:\nSUN',
        left: 'WIND',
        right: 'SUN',
        correct: 1,
        icon: Icons.wb_sunny_outlined),
    _Challenge(
        prompt: 'Tap the larger\nnumber',
        left: '8',
        right: '3',
        correct: 0,
        icon: Icons.numbers_rounded),
    _Challenge(
        prompt: 'Which shape is a\nCIRCLE?',
        left: '▲',
        right: '●',
        correct: 1,
        icon: Icons.circle_outlined),
    _Challenge(
        prompt: 'Choose the color:\nGREEN',
        left: 'GREEN',
        right: 'BLUE',
        correct: 0,
        icon: Icons.palette_outlined),
    _Challenge(
        prompt: 'Which word means\nFAST?',
        left: 'QUICK',
        right: 'SLOW',
        correct: 0,
        icon: Icons.bolt_rounded),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectMode(String value) => setState(() {
        _mode = value;
        _page = _Page.game;
        _startGame();
      });

  void _startGame() {
    _timer?.cancel();
    _score = 0;
    _streak = 0;
    _round = 0;
    _totalReaction = 0;
    _lives = _mode == 'Three Chances' ? 3 : 1;
    _nextRound();
  }

  void _nextRound() {
    _timer?.cancel();
    _challenge = _challenges[_random.nextInt(_challenges.length)];
    _timeLeft = 1;
    final duration = _mode == 'Speed Choice' ? 2200 : 3600;
    final started = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      setState(() => _timeLeft = (1 - elapsed / duration).clamp(0.0, 1.0));
      if (elapsed >= duration) {
        timer.cancel();
        _miss();
      }
    });
  }

  void _answer(int choice) {
    final reaction =
        ((_mode == 'Speed Choice' ? 2200 : 3600) * (1 - _timeLeft)).round();
    _timer?.cancel();
    if (choice == _challenge.correct) {
      setState(() {
        _score += 10 + (_streak * 2);
        _streak++;
        _round++;
        _totalReaction += reaction;
      });
      _nextRound();
    } else {
      _miss();
    }
  }

  void _miss() {
    _timer?.cancel();
    setState(() {
      _lives--;
      _streak = 0;
      if (_lives <= 0) {
        _bestScore = max(_bestScore, _score);
        _page = _Page.gameOver;
      } else {
        _round++;
      }
    });
    if (_page == _Page.game) _nextRound();
  }

  void _showInfo({required String title, required String text}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.w800, color: _ink)),
              const SizedBox(height: 12),
              Text(text,
                  style: const TextStyle(
                      fontSize: 16, height: 1.5, color: Color(0xFF5F6368))),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Choice Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _soft,
        colorScheme: ColorScheme.fromSeed(seedColor: _ink, surface: _soft),
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_page) {
              _Page.home => _home(),
              _Page.modes => _modes(),
              _Page.game => _game(),
              _Page.gameOver => _gameOver(),
            },
          ),
        ),
      ),
    );
  }

  Widget _home() => Padding(
        key: const ValueKey('home'),
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(flex: 3),
          Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                  color: _mint, borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.bolt_rounded, color: _ink, size: 48)),
          const SizedBox(height: 22),
          const Text('SNAP',
              style: TextStyle(
                  fontSize: 42,
                  height: .9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  color: _ink)),
          const SizedBox(height: 8),
          const Text('CHOICE RUSH',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Color(0xFF6B7078))),
          const SizedBox(height: 14),
          const Text('Think fast. Trust your first tap.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7078))),
          const Spacer(flex: 3),
          _primaryButton('PLAY NOW', Icons.play_arrow_rounded,
              () => setState(() => _page = _Page.modes)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _outlineButton(
                    'SETTINGS',
                    Icons.tune_rounded,
                    () => _showInfo(
                        title: 'Settings',
                        text:
                            'Snap Choice Rush is ready to play. More settings are coming soon.'))),
            const SizedBox(width: 10),
            Expanded(
                child: _outlineButton(
                    'HOW TO PLAY',
                    Icons.help_outline_rounded,
                    () => _showInfo(
                        title: 'How to play',
                        text:
                            'Read the prompt and tap the correct choice before the time bar runs out. Build a streak to score more points.'))),
          ]),
        ]),
      );

  Widget _modes() {
    const modes = [
      ('Snap Run', 'One wrong choice ends the run.', Icons.bolt_rounded),
      (
        'Three Chances',
        'You have 3 hearts before game over.',
        Icons.favorite_rounded
      ),
      ('Speed Choice', 'Shorter timer, faster flow.', Icons.timer_rounded),
      (
        'Mixed Cards',
        'A shuffled mix of every challenge.',
        Icons.style_rounded
      ),
    ];
    return Column(key: const ValueKey('modes'), children: [
      _topBar('Select mode', onBack: () => setState(() => _page = _Page.home)),
      Expanded(
          child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: modes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final mode = modes[i];
          return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _selectMode(mode.$1),
              child: Ink(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _line)),
                child: Row(children: [
                  Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                          color: _soft,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(mode.$3, color: _ink)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(mode.$1,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _ink)),
                        const SizedBox(height: 3),
                        Text(mode.$2,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF686D75))),
                      ])),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF9AA0A6)),
                ]),
              ));
        },
      )),
    ]);
  }

  Widget _game() => Column(key: const ValueKey('game'), children: [
        _topBar('Streak: $_streak', trailing: 'Score: $_score', onBack: () {
          _timer?.cancel();
          setState(() => _page = _Page.modes);
        }),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: Column(children: [
              if (_mode == 'Three Chances')
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(Icons.favorite_rounded,
                                color: i < _lives
                                    ? const Color(0xFFFF4B55)
                                    : _line,
                                size: 24)))),
              if (_mode == 'Three Chances') const SizedBox(height: 12),
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                      value: _timeLeft,
                      minHeight: 8,
                      backgroundColor: _line,
                      valueColor: const AlwaysStoppedAnimation(_ink))),
            ])),
        const Spacer(),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 220),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 12,
                        offset: Offset(0, 5))
                  ]),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_challenge.icon,
                        size: 31, color: const Color(0xFF75BFA2)),
                    const SizedBox(height: 16),
                    Text(_challenge.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 27,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.6,
                            color: _ink)),
                  ]),
            )),
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(children: [
              Expanded(child: _choice(_challenge.left, () => _answer(0))),
              const SizedBox(width: 12),
              Expanded(child: _choice(_challenge.right, () => _answer(1))),
            ])),
      ]);

  Widget _gameOver() {
    final average = _round == 0 ? 0 : (_totalReaction / _round).round();
    return Padding(
        key: const ValueKey('gameOver'),
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Spacer(flex: 2),
          Container(
              height: 74,
              width: 74,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFE7E7),
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.sentiment_dissatisfied_rounded,
                  size: 38, color: Color(0xFFDF424B))),
          const SizedBox(height: 18),
          const Text('GAME OVER',
              style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: _ink)),
          const SizedBox(height: 5),
          Text(_mode.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Color(0xFF6B7078))),
          const SizedBox(height: 28),
          Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _line)),
              child: Column(children: [
                _stat('Score', '$_score'),
                _stat('Best Score', '$_bestScore'),
                _stat(
                    'Accuracy',
                    _round == 0
                        ? '0%'
                        : '${((_score / 10) / _round * 100).clamp(0, 100).round()}%'),
                _stat('Avg Reaction', '${average}ms'),
              ])),
          const Spacer(),
          _primaryButton(
              'PLAY AGAIN', Icons.refresh_rounded, () => setState(_startGame)),
          const SizedBox(height: 12),
          _outlineButton('HOME', Icons.home_rounded,
              () => setState(() => _page = _Page.home)),
        ]));
  }

  Widget _stat(String name, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7078))),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: _ink))
      ]));
  Widget _topBar(String title,
          {String? trailing, required VoidCallback onBack}) =>
      SizedBox(
          height: 56,
          child: Row(children: [
            IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 20)),
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
            const Spacer(),
            if (trailing != null)
              Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Text(trailing,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _ink)))
          ]));
  Widget _choice(String label, VoidCallback onTap) => SizedBox(
      height: 74,
      child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          child: Text(label,
              style: TextStyle(
                  fontSize: label.length <= 2 ? 31 : 15,
                  fontWeight: FontWeight.w900))));
  Widget _primaryButton(
          String text, IconData icon, VoidCallback onTap) =>
      SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label:
                  Text(
                      text,
                      style:
                          const TextStyle(
                              fontWeight: FontWeight.w800, letterSpacing: .4)),
              style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)))));
  Widget _outlineButton(
          String text, IconData icon, VoidCallback onTap) =>
      SizedBox(
          height: 48,
          child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label:
                  Text(
                      text,
                      style:
                          const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: Color(0xFFC9CDD2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)))));
}
