/// Speaking indicator widget shown after the reaction banner disappears.
///
/// A decorative animated waveform bar that signals AURA is
/// about to speak (or currently speaking). This replaces the
/// reaction banner's visual slot while voice output is pending.
///
/// RTL-compatible: the waveform animates left-to-right
/// regardless of text direction.
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SpeakingIndicator extends StatefulWidget {
  const SpeakingIndicator({
    super.key,
    this.barCount = 5,
    this.barHeight = 16.0,
    this.barWidth = 3.0,
    this.barSpacing = 3.0,
    this.color,
    this.label,
  });

  /// Number of waveform bars.
  final int barCount;

  /// Maximum height of a bar when at peak.
  final double barHeight;

  /// Width of each bar.
  final double barWidth;

  /// Spacing between bars.
  final double barSpacing;

  /// Color of the bars (defaults to primary cyan).
  final Color? color;

  /// Optional accessibility label / text shown beside waveform.
  final String? label;

  @override
  State<SpeakingIndicator> createState() => _SpeakingIndicatorState();
}

class _SpeakingIndicatorState extends State<SpeakingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _barScale(int index) {
    // Each bar peaks at a staggered phase offset.
    final phase = (index / widget.barCount) * 2 * 3.14159;
    final value = _controller.value;
    // Sine wave with phase offset, mapped to 0.3–1.0 range.
    return 0.3 + 0.7 * (0.5 + 0.5 * (value * 2 * 3.14159 + phase).abs());
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.cyan;
    final textDirection = Directionality.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: textDirection,
      children: [
        // Waveform bars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.barCount, (i) {
            final scale = _barScale(i);
            return Padding(
              padding: EdgeInsets.only(
                right: i < widget.barCount - 1 ? widget.barSpacing : 0,
              ),
              child: Container(
                width: widget.barWidth,
                height: widget.barHeight * scale,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.4 + 0.6 * scale),
                  borderRadius: BorderRadius.circular(widget.barWidth / 2),
                ),
              ),
            );
          }),
        ),
        // Optional label
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textDirection: textDirection,
          ),
        ],
      ],
    );
  }
}
