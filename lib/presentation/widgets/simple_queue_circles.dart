import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Minimal queue UI: two gradient circles + patients-ahead count.
class SimpleQueueCircles extends StatelessWidget {
  const SimpleQueueCircles({
    super.key,
    required this.myNumber,
    required this.currentNumber,
    required this.peopleAhead,
    required this.pulseController,
    required this.numberScaleAnimation,
    this.onTap,
  });

  final int myNumber;
  final int currentNumber;
  final int peopleAhead;
  final AnimationController pulseController;
  final Animation<double> numberScaleAnimation;
  final VoidCallback? onTap;

  static const _largeSize = 172.0;
  static const _smallSize = 100.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final content = AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulse = pulseController.value;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: _largeSize + 48,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    _QueueCircle(
                      size: _largeSize + pulse * 8,
                      glowStrength: pulse,
                      gradient: const [
                        AppTheme.medicalBlue,
                        AppTheme.medicalBlueDark,
                        AppTheme.medicalGreen,
                      ],
                      shadowColor: AppTheme.medicalBlue,
                      child: ScaleTransition(
                        scale: numberScaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$myNumber',
                              style: const TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                l10n.queueNumber,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.92),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: 24,
                      bottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QueueCircle(
                            size: _smallSize + pulse * 4,
                            glowStrength: pulse,
                            gradient: const [
                              AppTheme.medicalGreenLight,
                              AppTheme.medicalGreen,
                            ],
                            shadowColor: AppTheme.medicalGreen,
                            child: ScaleTransition(
                              scale: numberScaleAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$currentNumber',
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      l10n.currentQueueNumber,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.92),
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppTheme.medicalBlue, AppTheme.medicalGreen],
                ).createShader(bounds),
                child: Text(
                  l10n.peopleAhead,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ScaleTransition(
                scale: numberScaleAnimation,
                child: Text(
                  '$peopleAhead',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.medicalBlueDark,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: onTap == null
          ? content
          : GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: content,
            ),
    );
  }
}

class _QueueCircle extends StatelessWidget {
  const _QueueCircle({
    required this.size,
    required this.glowStrength,
    required this.gradient,
    required this.shadowColor,
    required this.child,
  });

  final double size;
  final double glowStrength;
  final List<Color> gradient;
  final Color shadowColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.45),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.38 + glowStrength * 0.18),
            blurRadius: 22 + glowStrength * 14,
            spreadRadius: 2 + glowStrength * 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: -3,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ),
      ),
    );
  }
}
