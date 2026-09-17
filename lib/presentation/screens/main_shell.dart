import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../../core/providers/phase3_connection_points.dart' show navigationIndexProvider;
import '../widgets/widgets.dart';
import '../widgets/security_confirmation_host.dart';
import 'dashboard_screen.dart';
import 'vision_screen.dart';
import 'voice_screen.dart';
import 'settings_screen.dart';
import 'alarm_list_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final index = ref.watch(navigationIndexProvider);

    final screens = [
      const DashboardScreen(),
      const VisionScreen(),
      const VoiceScreen(),
      const SettingsScreen(),
      const AlarmListScreen(),
    ];

    final dests = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: l10n.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.visibility_outlined),
        selectedIcon: const Icon(Icons.visibility_rounded),
        label: l10n.visionTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.mic_none_outlined),
        selectedIcon: const Icon(Icons.mic_rounded),
        label: l10n.voice,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: l10n.settingsTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.alarm_outlined),
        selectedIcon: const Icon(Icons.alarm_rounded),
        label: l10n.alarmTab,
      ),
    ];

    return SecurityConfirmationHost(
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: screens,
        ),
        bottomNavigationBar: AuraNavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) =>
              ref.read(navigationIndexProvider.notifier).state = i,
          destinations: dests,
        ),
      ),
    );
  }
}
