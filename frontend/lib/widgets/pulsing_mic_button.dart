/// Large circular microphone button with a ripple-pulse animation.
///
/// When [isListening] is false, the button is gold with three expanding ripple
/// rings. When listening, it turns red and the ripples stop, giving clear
/// visual feedback that voice capture is active.
library;
import 'package:flutter/material.dart';
import 'package:sakhi_ai/theme/sakhi_colors.dart';

/// A stateful mic button that pulses with expanding ripple rings when idle
/// and switches to a solid red appearance while listening.
class PulsingMicButton extends StatefulWidget {
  const PulsingMicButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  /// Whether the assistant is currently listening for voice input.
  final bool isListening;

  /// Callback invoked when the user taps the mic button.
  final VoidCallback onPressed;

  /// Creates the state for [PulsingMicButton].
  @override
  State<PulsingMicButton> createState() => _PulsingMicButtonState();
}

/// Manages two animation controllers — one for the button glow pulse and one
/// for the expanding ripple rings — and composes the final stacked widget.
class _PulsingMicButtonState extends State<PulsingMicButton>
    with TickerProviderStateMixin {
  static const double _buttonSize = 120;

  late final AnimationController _pulseController;
  late final AnimationController _rippleController;

  /// Initialises both the glow-pulse and ripple animation controllers.
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  /// Disposes both animation controllers to free resources.
  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  /// Builds the stacked mic button with ripple rings (idle) and a glowing
  /// circular button that changes colour based on listening state.
  @override
  Widget build(BuildContext context) {
    final buttonColor =
        widget.isListening ? SakhiColors.listeningRed : SakhiColors.gold;
    final glowColor = widget.isListening
        ? SakhiColors.listeningRed.withValues(alpha: 0.55)
        : SakhiColors.goldGlow.withValues(alpha: 0.65);

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!widget.isListening) ...[
            _buildRipple(0.0, SakhiColors.gold, 0.42),
            _buildRipple(0.33, SakhiColors.goldGlow, 0.32),
            _buildRipple(0.66, SakhiColors.gold.withValues(alpha: 0.8), 0.24),
          ],
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final glow = widget.isListening
                  ? 22.0
                  : 18.0 + (_pulseController.value * 22);
              final spread = widget.isListening ? 6.0 : 3.0 + (_pulseController.value * 5);
              return Container(
                width: _buttonSize,
                height: _buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: glow,
                      spreadRadius: spread,
                    ),
                    BoxShadow(
                      color: SakhiColors.gold.withValues(alpha: 0.25),
                      blurRadius: glow * 1.4,
                      spreadRadius: spread * 0.5,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Material(
              color: buttonColor,
              shape: const CircleBorder(),
              elevation: 10,
              shadowColor: glowColor,
              child: InkWell(
                onTap: widget.onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: _buttonSize,
                  height: _buttonSize,
                  child: Icon(
                    Icons.mic_rounded,
                    size: 56,
                    color: SakhiColors.deepGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single expanding ripple ring with the given [phaseOffset],
  /// [color], and [maxOpacity].
  Widget _buildRipple(double phaseOffset, Color color, double maxOpacity) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        final t = (_rippleController.value + phaseOffset) % 1.0;
        return _RippleRing(
          scale: 1.0 + t * 0.72,
          opacity: (1 - t) * maxOpacity,
          color: color,
          strokeWidth: 3.0 + (1 - t) * 1.5,
        );
      },
    );
  }
}

/// A single circular ripple ring that scales and fades over time.
///
/// Used by [_PulsingMicButtonState] to create the expanding ripple effect
/// around the mic button when it is idle.
class _RippleRing extends StatelessWidget {
  const _RippleRing({
    required this.scale,
    required this.opacity,
    required this.color,
    this.strokeWidth = 3,
  });

  /// Current scale factor applied via [Transform.scale].
  final double scale;

  /// Current opacity of the ring border.
  final double opacity;

  /// Colour of the ring border.
  final Color color;

  /// Width of the ring border in logical pixels.
  final double strokeWidth;

  /// Base diameter of the ring before scaling.
  static const double _ringBase = 120;

  /// Renders a circular border with the current scale, opacity, and colour.
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: _ringBase,
        height: _ringBase,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: strokeWidth,
          ),
        ),
      ),
    );
  }
}
