import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/l10n/s.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _current = 0;

  List<_OnboardSlide> get _slides => [
    _OnboardSlide(
      emoji: '👨‍⚕️',
      gradient: [const Color(0xFF1B5E7B), const Color(0xFF1E88A8)],
      title: S.onb1Title,
      desc:  S.onb1Desc,
    ),
    _OnboardSlide(
      emoji: '📋',
      gradient: [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
      title: S.onb2Title,
      desc:  S.onb2Desc,
    ),
    _OnboardSlide(
      emoji: '💬',
      gradient: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
      title: S.onb3Title,
      desc:  S.onb3Desc,
    ),
    _OnboardSlide(
      emoji: '🌟',
      gradient: [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
      title: S.onb4Title,
      desc:  S.onb4Desc,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_v2_seen', true);
    if (!mounted) return;
    context.go('/auth');
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];
    final isLast = _current == _slides.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: slide.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => showLanguagePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text('🌐  AR / EN / עב',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _finish,
                  child: Text(S.skip,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

            // ── Slides ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _SlideContent(slide: _slides[i]),
              ),
            ),

            // ── Dots + Buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _current ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _current ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: slide.gradient.first,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    child: Text(isLast ? S.getStarted : S.next),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _OnboardSlide {
  final String emoji;
  final List<Color> gradient;
  final String title;
  final String desc;
  const _OnboardSlide({
    required this.emoji,
    required this.gradient,
    required this.title,
    required this.desc,
  });
}

class _SlideContent extends StatelessWidget {
  final _OnboardSlide slide;
  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 36),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 160, height: 160,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Center(
            child: Text(slide.emoji,
              style: const TextStyle(fontSize: 80)),
          ),
        ),
        const SizedBox(height: 48),
        Text(slide.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            fontFamily: 'Cairo',
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Text(slide.desc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontFamily: 'Cairo',
            height: 1.7,
          ),
        ),
      ],
    ),
  );
}
