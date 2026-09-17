import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../providers/app_providers.dart';

/// Foundation screen shown at app launch during Phase 1.
///
/// Displays the AURA branding, current theme/locale info,
/// and confirms the architecture is wired correctly.
class FoundationScreen extends ConsumerWidget {
  const FoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(overriddenThemeProvider);
    final locale = ref.watch(overriddenLocaleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AURA logo text
            Text(
              'AURA',
              style: AppTextStyles.headline1.copyWith(
                color: AppColors.primary,
              ),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            Text(
              'Assistant',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.onBackground.withOpacity(0.6),
              ),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 48),
            // Status info
            _StatusChip(label: 'Theme', value: themeMode.name),
            const SizedBox(height: 8),
            _StatusChip(label: 'Locale', value: '${locale.code}_${locale.countryCode}'),
            const SizedBox(height: 8),
            _StatusChip(label: 'Direction', value: locale.textDirection.name),
            const SizedBox(height: 48),
            Text(
              'Phase 1 · Foundation Ready',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onBackground.withOpacity(0.4),
              ),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.onBackground.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
