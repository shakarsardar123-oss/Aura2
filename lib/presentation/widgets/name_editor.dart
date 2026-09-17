import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_assistant/l10n/app_localizations.dart';

import '../../core/providers/phase3_connection_points.dart';
import 'aura_button.dart';
import 'aura_dialog.dart';

class NameEditor extends ConsumerStatefulWidget {
  const NameEditor({super.key});

  @override
  ConsumerState<NameEditor> createState() => _NameEditorState();
}

class _NameEditorState extends ConsumerState<NameEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(agentNameProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final currentName = ref.watch(agentNameProvider);

    return ListTile(
      leading: Icon(Icons.smart_toy_outlined),
      title: Text(l10n.agentNameLabel),
      subtitle: Text(currentName),
      trailing: Icon(Icons.edit_outlined, size: 18),
      onTap: () => _showEditDialog(context, currentName),
    );
  }

  void _showEditDialog(BuildContext context, String currentName) {
    final l10n = S.of(context);
    _controller.text = currentName;
    _controller.selection = TextSelection.collapsed(offset: currentName.length);

    AuraDialog.show(
      context: context,
      title: l10n.changeName,
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: AuraTextField(
          controller: _controller,
          label: l10n.agentNameLabel,
          autofocus: true,
        ),
      ),
      actions: [
        AuraButton(
          label: l10n.saveChanges,
          variant: AuraButtonVariant.text,
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              ref.read(agentNameProvider.notifier).state = name;
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
