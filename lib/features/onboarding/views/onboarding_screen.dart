import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/onboarding_controller.dart';

// ── Page data ─────────────────────────────────────────────────────────────────

class _PageData {
  final String emoji;
  final Color bg;
  final Color accentColor;
  final String title;
  final String subtitle;
  const _PageData({
    required this.emoji,
    required this.bg,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });
}

const _pages = [
  _PageData(
    emoji: '🏗️',
    bg: Color(0xFF0F172A),
    accentColor: Color(0xFF3B82F6),
    title: 'Track Every Stage',
    subtitle:
        'From foundation to final inspection — always know what\'s happening on your site.',
  ),
  _PageData(
    emoji: '💰',
    bg: Color(0xFF0C1A2E),
    accentColor: Color(0xFF22C55E),
    title: 'Control Your Budget',
    subtitle:
        'Track every rupee spent, stage by stage. No more surprises.',
  ),
  _PageData(
    emoji: '👥',
    bg: Color(0xFF0F0A1E),
    accentColor: Color(0xFF8B5CF6),
    title: 'Connect Your Team',
    subtitle:
        'Owner, supervisor, contractor — everyone on the same page.',
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// Onboarding screen
// ═══════════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _current    = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.animateToPage(
        _current + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _skip() => _complete();

  void _complete() {
    Get.find<OnboardingController>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Animated background ─────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: double.infinity,
            color: _pages[_current].bg,
          ),

          // ── PageView ────────────────────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _OnboardingPage(
              data: _pages[i],
              isActive: i == _current,
              index: i,
            ),
          ),

          // ── Skip link (pages 0 & 1) ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: AnimatedOpacity(
              opacity: _current < _pages.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white54,
                ),
                child: Text('Skip',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ),

          // ── Bottom controls ─────────────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? _pages[_current].accentColor
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                // CTA button
                GestureDetector(
                  onTap: _next,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _pages[_current].accentColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_current].accentColor
                              .withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _current == _pages.length - 1
                          ? 'Get Started →'
                          : 'Next →',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single onboarding page ────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final bool isActive;
  final int index;
  const _OnboardingPage({
    required this.data,
    required this.isActive,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),

          // Illustration / emoji
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.accentColor.withValues(alpha: 0.12),
              border: Border.all(
                  color: data.accentColor.withValues(alpha: 0.25), width: 2),
            ),
            child: Center(
              child: Text(data.emoji,
                  style: const TextStyle(fontSize: 80)),
            ),
          )
              .animate(key: ValueKey('emoji_$index'))
              .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          )
              .animate(key: ValueKey('title_$index'))
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.6,
            ),
          )
              .animate(key: ValueKey('sub_$index'))
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 350.ms, duration: 400.ms),

          const Spacer(),
        ],
      ),
    );
  }
}
