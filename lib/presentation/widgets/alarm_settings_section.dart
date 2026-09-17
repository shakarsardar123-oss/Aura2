import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';
import 'package:aura_assistant/domain/entities/alarm/wake_alarm.dart';

import '../providers/alarm_providers.dart';

/// A tile showing alarm info with an expandable settings section.
class AlarmSettingsSection extends ConsumerWidget {
  const AlarmSettingsSection({super.key, required this.alarm});

  final WakeAlarm alarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final notifier = ref.read(alarmListProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(
          alarm.label.isEmpty ? l10n.alarmTab : alarm.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${alarm.time.formatted}${alarm.isRepeating ? ' · ${_repeatDaysShort(alarm.repeatDays, l10n)}' : ''}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Switch(
          value: alarm.enabled,
          onChanged: (v) => notifier.toggleAlarm(alarm.id),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Repeat days chips
                _RepeatDaysChips(alarm: alarm),
                const SizedBox(height: 8),
                // Snooze info
                Text(
                  '${l10n.alarmSnoozeDuration}: ${alarm.snoozeDurationMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                // Delete button
                OutlinedButton.icon(
                  onPressed: () => notifier.deleteAlarm(alarm.id),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.alarmDeleteAlarm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _repeatDaysShort(List<int> days, S l10n) {
    if (days.isEmpty) return '';
    final names = <int, String>{
      1: l10n.alarmDaysMonday,
      2: l10n.alarmDaysTuesday,
      3: l10n.alarmDaysWednesday,
      4: l10n.alarmDaysThursday,
      5: l10n.alarmDaysFriday,
      6: l10n.alarmDaysSaturday,
      7: l10n.alarmDaysSunday,
    };
    return days.map((d) => names[d] ?? '?').join(', ');
  }
}

/// Interactive chips for editing repeat days of a specific alarm.
class _RepeatDaysChips extends ConsumerStatefulWidget {
  const _RepeatDaysChips({required this.alarm});

  final WakeAlarm alarm;

  @override
  ConsumerState<_RepeatDaysChips> createState() => _RepeatDaysChipsState();
}

class _RepeatDaysChipsState extends ConsumerState<_RepeatDaysChips> {
  static const _dayKeys = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    // Initialize editing state from alarm.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editingRepeatDaysProvider.notifier).state =
          List<int>.from(widget.alarm.repeatDays);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final selectedDays = ref.watch(editingRepeatDaysProvider);
    final dayLabels = <int, String>{
      1: l10n.alarmDaysMonday,
      2: l10n.alarmDaysTuesday,
      3: l10n.alarmDaysWednesday,
      4: l10n.alarmDaysThursday,
      5: l10n.alarmDaysFriday,
      6: l10n.alarmDaysSaturday,
      7: l10n.alarmDaysSunday,
    };

    return Wrap(
      spacing: 6,
      children: _dayKeys.map((day) {
        final isSelected = selectedDays.contains(day);
        return FilterChip(
          label: Text(dayLabels[day] ?? '?'),
          selected: isSelected,
          onSelected: (selected) {
            final updated = List<int>.from(selectedDays);
            if (selected) {
              updated.add(day);
            } else {
              updated.remove(day);
            }
            updated.sort();
            ref.read(editingRepeatDaysProvider.notifier).state = updated;
            // Persist change to alarm.
            final updatedAlarm = widget.alarm.copyWith(repeatDays: updated);
            ref.read(alarmListProvider.notifier).updateAlarm(updatedAlarm);
          },
        );
      }).toList(),
    );
  }
}
