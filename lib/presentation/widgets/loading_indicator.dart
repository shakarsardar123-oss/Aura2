import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Branded loading indicator for the AURA app.
class AuraLoadingIndicator extends StatelessWidget {
  const AuraLoadingIndicator({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}
