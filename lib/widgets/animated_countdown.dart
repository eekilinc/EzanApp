import 'package:flutter/material.dart';

/// An animated countdown display with sliding number transitions.
class AnimatedCountdown extends StatelessWidget {
  final String timeString; // Format: "HH:MM:SS"

  const AnimatedCountdown({super.key, required this.timeString});

  @override
  Widget build(BuildContext context) {
    // Parse the time string into individual digits (hata toleranslı)
    final parts = timeString.split(':');
    if (parts.length != 3) {
      return Text(timeString,
          style: const TextStyle(color: Colors.white, fontSize: 18));
    }
    final safe = parts.map((p) => p.padLeft(2, '0')).toList();
    if (safe.any((p) => p.length != 2)) {
      return Text(timeString,
          style: const TextStyle(color: Colors.white, fontSize: 18));
    }

    // Ekran okuyucu her saniye anons etmesin: tek etiket + iç animasyon hariç.
    // Büyük yazı tipinde taşmayı FittedBox engeller.
    return Semantics(
      label: timeString,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hours
              _AnimatedDigit(value: safe[0][0]),
              _AnimatedDigit(value: safe[0][1]),
              const _Separator(),
              // Minutes
              _AnimatedDigit(value: safe[1][0]),
              _AnimatedDigit(value: safe[1][1]),
              const _Separator(),
              // Seconds
              _AnimatedDigit(value: safe[2][0]),
              _AnimatedDigit(value: safe[2][1]),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDigit extends StatelessWidget {
  final String value;

  const _AnimatedDigit({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: AnimatedSwitcher(
        // Hareket azaltma açıkken animasyonu kapat.
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 350),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Slide from top for incoming, slide down for outgoing
          final inAnimation = Tween<Offset>(
            begin: const Offset(0.0, -0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return SlideTransition(
            position: inAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Text(
          value,
          key: ValueKey<String>(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
