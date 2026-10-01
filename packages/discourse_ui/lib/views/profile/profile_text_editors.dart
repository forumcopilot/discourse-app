import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/app_navigation.dart';
import '../../utils/discourse_markup.dart';
import '../widgets/discard_changes_scope.dart';

/// A one-line profile text (display name, location, website) in a dialog
/// that saves it. Stays open, with what was typed, when the save fails.
/// True when it saved.
Future<bool> showProfileTextDialog({
  required BuildContext context,
  required String title,
  required String initialValue,
  required Future<bool> Function(String text) onSave,
  String? helper,
  TextInputType? keyboardType,
  int? maxLength,
  bool required = false,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _ProfileTextDialog(
      title: title,
      initialValue: initialValue,
      onSave: onSave,
      helper: helper,
      keyboardType: keyboardType,
      maxLength: maxLength,
      required: required,
    ),
  );
  return saved == true;
}

class _ProfileTextDialog extends StatefulWidget {
  const _ProfileTextDialog({
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.helper,
    this.keyboardType,
    this.maxLength,
    this.required = false,
  });

  final String title;
  final String initialValue;
  final Future<bool> Function(String text) onSave;
  final String? helper;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool required;

  @override
  State<_ProfileTextDialog> createState() => _ProfileTextDialogState();
}

class _ProfileTextDialogState extends State<_ProfileTextDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave {
    final text = _controller.text.trim();
    if (widget.required && text.isEmpty) return false;
    return text != widget.initialValue.trim();
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);
    final ok = await widget.onSave(_controller.text.trim());
    if (!mounted) return;
    if (ok) {
      context.popOwnRoute(true);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_saving,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          labelText: widget.title,
          helperText: widget.helper,
          helperMaxLines: 3,
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => context.popOwnRoute(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _canSave && !_saving ? _save : null,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.save),
        ),
      ],
    );
  }
}

/// About me on a page of its own: the bio is Markdown and can run long, so
/// it gets a full-height field and the composer's formatting buttons.
class AboutMePage extends StatefulWidget {
  const AboutMePage({
    super.key,
    required this.initialValue,
    required this.onSave,
  });

  final String initialValue;
  final Future<bool> Function(String text) onSave;

  /// UserProfile validates `bio_raw` at 3000 characters.
  static const int maxLength = 3000;

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  final FocusNode _focus = FocusNode();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _changed => _controller.text.trim() != widget.initialValue.trim();

  void _format(String tag) {
    _focus.requestFocus();
    _controller.value = DiscourseMarkup.apply(_controller.value, tag);
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final ok = await widget.onSave(_controller.text.trim());
    if (!mounted) return;
    if (ok) {
      context.popOwnRoute();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return DiscardChangesScope(
      listenable: _controller,
      hasChanges: () => _changed,
      isEdit: true,
      busy: _saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.aboutMe),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => FilledButton(
                  onPressed: _saving || !_changed ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.save),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DesignTokens.spacingL),
          children: [
            TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              enabled: !_saving,
              minLines: 8,
              maxLines: null,
              maxLength: AboutMePage.maxLength,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.aboutMe,
                alignLabelWithHint: true,
                helperText: l10n.aboutMeHelper,
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingS),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.bold,
                  onPressed: _saving ? null : () => _format('B'),
                  icon: const Icon(Icons.format_bold),
                ),
                IconButton(
                  tooltip: l10n.italic,
                  onPressed: _saving ? null : () => _format('I'),
                  icon: const Icon(Icons.format_italic),
                ),
                IconButton(
                  tooltip: l10n.link,
                  onPressed: _saving ? null : () => _format('URL'),
                  icon: const Icon(Icons.link),
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: Text(
                    l10n.aboutMeMarkdownHint,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The forum's own profile questions, together on a page: a required one
/// has to be answered before any of them save, as UsersController#update
/// refuses the whole change otherwise.
class ForumQuestionsPage extends StatefulWidget {
  const ForumQuestionsPage({
    super.key,
    required this.fields,
    required this.values,
    required this.onSave,
  });

  final List<DiscourseUserFieldDef> fields;
  final Map<int, Object?> values;

  /// Only the answers that changed.
  final Future<bool> Function(Map<int, Object?> values) onSave;

  @override
  State<ForumQuestionsPage> createState() => _ForumQuestionsPageState();
}

class _ForumQuestionsPageState extends State<ForumQuestionsPage> {
  final Map<int, Object?> _values = {};
  final Map<int, TextEditingController> _text = {};
  final ValueNotifier<int> _edits = ValueNotifier(0);
  bool _saving = false;
  bool _tried = false;

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      final v = widget.values[f.id];
      switch (f.type) {
        case DiscourseUserFieldType.text:
          _text[f.id] = TextEditingController(text: v?.toString() ?? '')
            ..addListener(() => _edits.value++);
          _values[f.id] = v?.toString() ?? '';
        case DiscourseUserFieldType.confirm:
          _values[f.id] = v == true || v == 'true';
        case DiscourseUserFieldType.dropdown:
          final s = v?.toString();
          _values[f.id] = s == null || s.isEmpty ? null : s;
        case DiscourseUserFieldType.multiselect:
          _values[f.id] = v is List
              ? v.map((e) => e.toString()).toList()
              : (v == null || v.toString().isEmpty
                  ? <String>[]
                  : <String>[v.toString()]);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    _edits.dispose();
    super.dispose();
  }

  Object? _current(DiscourseUserFieldDef f) =>
      f.type == DiscourseUserFieldType.text ? _text[f.id]!.text.trim() : _values[f.id];

  Object? _original(DiscourseUserFieldDef f) {
    final v = widget.values[f.id];
    return switch (f.type) {
      DiscourseUserFieldType.text => v?.toString().trim() ?? '',
      DiscourseUserFieldType.confirm => v == true || v == 'true',
      DiscourseUserFieldType.dropdown =>
        (v == null || v.toString().isEmpty) ? null : v.toString(),
      DiscourseUserFieldType.multiselect => v is List
          ? v.map((e) => e.toString()).toList()
          : (v == null || v.toString().isEmpty ? <String>[] : [v.toString()]),
    };
  }

  bool _same(Object? a, Object? b) {
    if (a is List && b is List) {
      return a.length == b.length && a.toSet().containsAll(b);
    }
    return a == b;
  }

  Map<int, Object?> get _changes => {
        for (final f in widget.fields)
          if (f.editable && !_same(_current(f), _original(f)))
            f.id: switch (_current(f)) {
              final String s when s.isEmpty => null,
              final v => v,
            },
      };

  bool _empty(DiscourseUserFieldDef f) => switch (_current(f)) {
        null => true,
        final String s => s.isEmpty,
        final List l => l.isEmpty,
        final bool b => !b,
        _ => false,
      };

  List<DiscourseUserFieldDef> get _unanswered => widget.fields
      .where((f) => f.editable && f.required && _empty(f))
      .toList();

  Future<void> _save() async {
    setState(() => _tried = true);
    if (_unanswered.isNotEmpty || _saving) return;
    FocusScope.of(context).unfocus();
    final changes = _changes;
    if (changes.isEmpty) {
      context.popOwnRoute();
      return;
    }
    setState(() => _saving = true);
    final ok = await widget.onSave(changes);
    if (!mounted) return;
    if (ok) {
      context.popOwnRoute();
    } else {
      setState(() => _saving = false);
    }
  }

  void _set(DiscourseUserFieldDef f, Object? value) {
    setState(() => _values[f.id] = value);
    _edits.value++;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return DiscardChangesScope(
      listenable: _edits,
      hasChanges: () => _changes.isNotEmpty,
      isEdit: true,
      busy: _saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.moreAboutYou),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.save),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
              DesignTokens.spacingS, DesignTokens.spacingL, DesignTokens.spacingXL),
          children: [
            Text(l10n.forumQuestionsIntro,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: DesignTokens.spacingL),
            for (final f in widget.fields) ...[
              _field(context, f),
              const SizedBox(height: DesignTokens.spacingL),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context, DiscourseUserFieldDef f) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final label = f.required ? '${f.name} *' : f.name;
    final error = _tried && f.editable && f.required && _empty(f)
        ? l10n.forumQuestionRequired
        : null;
    // Forums often fill the required description with the question
    // itself; shown twice it reads as a glitch.
    final description = f.description?.trim().toLowerCase() ==
            f.name.trim().toLowerCase()
        ? null
        : f.description;
    final helper = !f.editable ? l10n.forumQuestionSetByStaff : description;
    final enabled = f.editable && !_saving;

    switch (f.type) {
      case DiscourseUserFieldType.text:
        return TextField(
          controller: _text[f.id],
          enabled: enabled,
          readOnly: !f.editable,
          maxLength: 2048,
          decoration: InputDecoration(
            labelText: label,
            helperText: helper,
            helperMaxLines: 3,
            errorText: error,
            counterText: '',
            suffixIcon: f.editable ? null : const Icon(Icons.lock_outline),
          ),
        );
      case DiscourseUserFieldType.confirm:
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _values[f.id] == true,
          onChanged: enabled ? (v) => _set(f, v ?? false) : null,
          title: Text(label),
          subtitle: error != null
              ? Text(error, style: TextStyle(color: colorScheme.error))
              : (helper == null ? null : Text(helper)),
        );
      case DiscourseUserFieldType.dropdown:
        final current = _values[f.id] as String?;
        return DropdownButtonFormField<String>(
          initialValue: f.options.contains(current) ? current : null,
          isExpanded: true,
          onChanged: enabled ? (v) => _set(f, v) : null,
          decoration: InputDecoration(
            labelText: label,
            helperText: helper,
            helperMaxLines: 3,
            errorText: error,
          ),
          items: [
            if (!f.required)
              DropdownMenuItem<String>(value: null, child: Text(l10n.none)),
            for (final o in f.options)
              DropdownMenuItem<String>(value: o, child: Text(o)),
          ],
        );
      case DiscourseUserFieldType.multiselect:
        final selected = List<String>.from(_values[f.id] as List? ?? const []);
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            helperText: helper,
            helperMaxLines: 3,
            errorText: error,
            enabled: enabled,
          ),
          child: Wrap(
            spacing: DesignTokens.spacingS,
            runSpacing: DesignTokens.spacingS,
            children: [
              for (final o in f.options)
                FilterChip(
                  label: Text(o),
                  selected: selected.contains(o),
                  onSelected: enabled
                      ? (on) => _set(
                          f,
                          on
                              ? [...selected, o]
                              : selected.where((s) => s != o).toList())
                      : null,
                ),
            ],
          ),
        );
    }
  }
}
