import 'package:flutter/material.dart';

/// AURA glow effect — animated pulsing glow around a child widget.
///
/// Used for the voice button and other accent elements.
class GlowEffect extends StatefulWidget {
  const GlowEffect({
    super.key,
    required this.child,
    this.color,
    this.glowRadius = 20,
    this.spread = 2,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
    this.shape = BoxShape.circle,
  });

  final Widget child;
  final Color? color;
  final double glowRadius;
  final double spread;
  final Duration duration;
  final bool enabled;
  final BoxShape shape;

  @override
  State<GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends State<GlowEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowEffect old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final theme = Theme.of(context);
    final glowColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(16)
                : null,
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(_animation.value),
                blurRadius: widget.glowRadius,
                spreadRadius: widget.spread,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}


