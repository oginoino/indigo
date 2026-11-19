import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

enum EngagementEffect { pop, bounce, spin, wiggle }

class AnimatedEngagementIcon extends StatefulWidget {
  const AnimatedEngagementIcon({
    required this.icon,
    required this.color,
    required this.iconSize,
    required this.buttonSize,
    required this.tooltip,
    required this.effect,
    required this.isActive,
    required this.playOnTap,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double iconSize;
  final double buttonSize;
  final String tooltip;
  final EngagementEffect effect;

  /// Estado "ligado" (curtido/salvo). A animação toca quando vira true.
  final bool isActive;

  /// Para botões sem estado (comentar/repostar): toca a animação a cada toque.
  final bool playOnTap;
  final VoidCallback? onPressed;

  @override
  State<AnimatedEngagementIcon> createState() => _AnimatedEngagementIconState();
}

class _AnimatedEngagementIconState extends State<AnimatedEngagementIcon>
    with SingleTickerProviderStateMixin {
  // value: 1 => estado de repouso (animação concluída)
  late final AnimationController _fx = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );
  bool _pressed = false;

  @override
  void didUpdateWidget(covariant AnimatedEngagementIcon old) {
    super.didUpdateWidget(old);
    if (!old.isActive && widget.isActive) _play();
  }

  @override
  void dispose() {
    _fx.dispose();
    super.dispose();
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context)) return; // acessibilidade
    _fx.forward(from: 0);
  }

  void _handlePressed() {
    HapticFeedback.lightImpact();
    if (widget.playOnTap) _play();
    widget.onPressed?.call();
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final showBurst =
        widget.effect == EngagementEffect.pop && widget.isActive;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: SizedBox.square(
          dimension: widget.buttonSize,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (showBurst)
                AnimatedBuilder(
                  animation: _fx,
                  builder: (_, _) => CustomPaint(
                    size: Size.square(widget.buttonSize * 1.6),
                    painter: _BurstPainter(
                      progress: _fx.value,
                      color: widget.color,
                    ),
                  ),
                ),
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: widget.color),
                duration: const Duration(milliseconds: 250),
                builder: (context, color, _) => AnimatedBuilder(
                  animation: _fx,
                  builder: (context, child) =>
                      _applyEffect(_fx.value, child!),
                  child: IconButton(
                    tooltip: widget.tooltip,
                    onPressed: _handlePressed,
                    color: color,
                    disabledColor: color,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tightFor(
                      width: widget.buttonSize,
                      height: widget.buttonSize,
                    ),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        widget.icon,
                        key: ValueKey(widget.icon),
                        size: widget.iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _applyEffect(double t, Widget child) {
    switch (widget.effect) {
      case EngagementEffect.pop:
        return Transform.scale(
          scale: 0.5 + 0.5 * Curves.elasticOut.transform(t),
          child: child,
        );
      case EngagementEffect.bounce:
        return Transform.translate(
          offset: Offset(0, -8 * math.sin(math.pi * t) * (1 - t)),
          child: Transform.scale(
            scale: 0.75 + 0.25 * Curves.elasticOut.transform(t),
            child: child,
          ),
        );
      case EngagementEffect.spin:
        return Transform.rotate(
          angle: 2 * math.pi * Curves.easeOutCubic.transform(t),
          child: child,
        );
      case EngagementEffect.wiggle:
        return Transform.rotate(
          angle: math.sin(t * math.pi * 4) * 0.28 * (1 - t),
          child: child,
        );
    }
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final center = size.center(Offset.zero);
    final t = Curves.easeOutCubic.transform(progress);
    final radius = size.width * 0.18 + size.width * 0.32 * t;
    final paint = Paint()..color = color.withValues(alpha: (1 - t) * 0.9);

    const count = 7;
    for (var i = 0; i < count; i++) {
      final angle = (2 * math.pi / count) * i;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(p, (1 - t) * 3 + 0.5, paint);
    }

    // anel expansivo
    canvas.drawCircle(
      center,
      radius * 0.8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1 - t) * 2
        ..color = color.withValues(alpha: (1 - t) * 0.5),
    );
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.progress != progress || old.color != color;
}