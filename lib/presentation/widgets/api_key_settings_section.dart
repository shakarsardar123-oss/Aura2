import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiKeySettingsSection extends ConsumerStatefulWidget {
  const ApiKeySettingsSection({super.key});

  @override
  ConsumerState<ApiKeySettingsSection> createState() => _ApiKeySettingsSectionState();
}

class _ApiKeySettingsSectionState extends ConsumerState<ApiKeySettingsSection> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
