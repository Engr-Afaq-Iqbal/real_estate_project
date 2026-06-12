import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

// POLISH 3: Dark navy splash — matches flutter_native_splash background color
const _kSplashBg = Color(0xFF1C3A7A);

class SplashScreen extends GetView<OnboardingController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.checkAndNavigate();

    return Scaffold(
      backgroundColor: _kSplashBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _kSplashBg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo icon — construction hard-hat style
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2), width: 1.5),
              ),
              child: const Icon(
                Icons.construction_rounded,
                size: 52,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                    delay: 200.ms,
                    duration: 700.ms,
                    curve: Curves.elasticOut),

            const SizedBox(height: 28),

            // BuildOS wordmark
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Build',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  TextSpan(
                    text: 'OS',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF93C5FD),
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 10),

            // POLISH 3: "Build Smarter" tagline
            Text(
              'Build Smarter',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF93C5FD),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: 72),

            // Slim loading bar
            SizedBox(
              width: 120,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF93C5FD)),
                minHeight: 2,
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
