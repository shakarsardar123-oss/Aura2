import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Shared app bar for the AURA app.
class AuraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuraAppBar({super.key, this.title = 'AURA'});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary),
      ),
    );
  }
}
