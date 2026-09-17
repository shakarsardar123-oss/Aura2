import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../providers/alarm_providers.dart';
import '../widgets/widgets.dart' show AlarmSettingsSection;

/// Screen showing the list of configured alarms.
class AlarmListScreen extends ConsumerWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final alarmList = ref.watch(alarmListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alarmTab),
      ),
      body: alarmList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off,
                      size: 64, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    l10n.alarmNoAlarms,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: alarmList.length,
              itemBuilder: (context, index) {
                final alarm = alarmList[index];
                return AlarmSettingsSection(alarm: alarm);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to alarm creation / settings.
          // For now, expand an inline section.
        },
        child: const Icon(Icons.add),
        tooltip: l10n.alarmTab,
      ),
    );
  }
}
