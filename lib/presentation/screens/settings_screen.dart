import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../../core/localization/locale_provider.dart';
import '../../core/utils/responsive.dart';
import '../providers/app_providers.dart';
import '../widgets/widgets.dart';
import '../widgets/api_key_settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final layout = ResponsiveLayout.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutContainer(
          maxWidth: layout.maxContentWidth,
          padding: EdgeInsets.symmetric(
            horizontal: layout.horizontalPadding,
            vertical: 8,
          ),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    l10n.settingsTab,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // ── Assistant Identity Section ──
              SliverToBoxAdapter(
                child: _SectionHeader(title: l10n.assistantIdentity),
              ),
              SliverToBoxAdapter(child: NameEditor()),

              // ── Appearance Section ──
              SliverToBoxAdapter(
                child: _SectionHeader(title: l10n.appearance),
              ),
              SliverToBoxAdapter(child: ThemeSelector()),
              SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Language selection
              SliverToBoxAdapter(
                child: _LanguageSelector(),
              ),

              // Text direction
              SliverToBoxAdapter(
                child: _TextDirectionToggle(),
              ),

              // ── AI Provider / API key Section ──
              SliverToBoxAdapter(
                child: _SectionHeader(title: 'AI provider'),
              ),
              SliverToBoxAdapter(child: const ApiKeySettingsSection()),

              // ── General Section ──
              SliverToBoxAdapter(
                child: _SectionHeader(title: l10n.general),
              ),
              SliverToBoxAdapter(
                child: ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text(l10n.aboutApp),
                  trailing: Icon(Icons.chevron_right, size: 18),
                  onTap: () => _showAboutDialog(context, l10n),
                ),
              ),

              // ── Phase 3 Notice ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.phaseNotice,
                    style: TextStyle(fontSize: 11, color: cs.outline),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, S l10n) {
    AuraDialog.show(
      context: context,
      icon: Icons.auto_awesome_rounded,
      title: l10n.aboutApp,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          Text(l10n.version, style: TextStyle(fontSize: 13)),
          SizedBox(height: 4),
          Text(l10n.builtWith, style: TextStyle(fontSize: 12)),
          SizedBox(height: 16),
          Text(l10n.phaseNotice, textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LanguageSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final currentLocale = ref.watch(overriddenLocaleProvider);

    return ListTile(
      leading: Icon(Icons.language_rounded),
      title: Text(l10n.languageSelection),
      subtitle: Text(
        currentLocale == AuraLocale.ku ? l10n.kurdish : 'English',
      ),
      trailing: Icon(Icons.chevron_right, size: 18),
      onTap: () => _showLocaleDialog(context, ref, currentLocale),
    );
  }

  void _showLocaleDialog(BuildContext context, WidgetRef ref, AuraLocale current) {
    final l10n = S.of(context);
    final notifier = ref.read(overriddenLocaleProvider.notifier);

    AuraDialog.show(
      context: context,
      icon: Icons.language_rounded,
      title: l10n.languageSelection,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n.kurdish),
            leading: Radio<AuraLocale>(
              value: AuraLocale.ku,
              groupValue: current,
              onChanged: (v) {
                if (v != null) notifier.setLocale(v);
                Navigator.of(context).pop();
              },
            ),
          ),
          ListTile(
            title: const Text('English'),
            leading: Radio<AuraLocale>(
              value: AuraLocale.en,
              groupValue: current,
              onChanged: (v) {
                if (v != null) notifier.setLocale(v);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TextDirectionToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final currentLocale = ref.watch(overriddenLocaleProvider);
    final isRtl = currentLocale.textDirection == TextDirection.rtl;

    return SwitchListTile(
      secondary: Icon(Icons.format_textdirection_r_to_l),
      title: Text(l10n.textDirection),
      subtitle: Text(isRtl ? l10n.directionRtl : l10n.directionLtr),
      value: isRtl,
      onChanged: (value) {
        final notifier = ref.read(overriddenLocaleProvider.notifier);
        // RTL -> switch to Kurdish, LTR -> switch to English
        notifier.setLocale(value ? AuraLocale.ku : AuraLocale.en);
      },
    );
  }
}
