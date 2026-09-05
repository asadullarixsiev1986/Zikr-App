import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_strings.dart';
import '../models/dua_model.dart';

Future<DuaModel?> showCustomDuaEditor(BuildContext context, {DuaModel? existing}) {
  return showDialog<DuaModel>(
    context: context,
    builder: (context) => _CustomDuaEditorDialog(existing: existing),
  );
}

class _CustomDuaEditorDialog extends StatefulWidget {
  final DuaModel? existing;
  const _CustomDuaEditorDialog({this.existing});

  @override
  State<_CustomDuaEditorDialog> createState() => _CustomDuaEditorDialogState();
}

class _CustomDuaEditorDialogState extends State<_CustomDuaEditorDialog> {
  late final TextEditingController _arabicController;
  late final TextEditingController _translationController;
  late final TextEditingController _translitController;

  String _t(String key) => AppLocale.instance.t(key);

  @override
  void initState() {
    super.initState();
    _arabicController = TextEditingController(text: widget.existing?.arabic ?? '');
    _translationController =
        TextEditingController(text: widget.existing?.translation ?? '');
    _translitController = TextEditingController(
      text: widget.existing?.translitLatin.isNotEmpty == true
          ? widget.existing!.translitLatin
          : (widget.existing?.translitCyrillic ?? ''),
    );
  }

  @override
  void dispose() {
    _arabicController.dispose();
    _translationController.dispose();
    _translitController.dispose();
    super.dispose();
  }

  void _save() {
    final translation = _translationController.text.trim();
    if (translation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('editor_error_empty'))),
      );
      return;
    }

    final dua = DuaModel(
      id: widget.existing?.id ?? const Uuid().v4(),
      arabic: _arabicController.text.trim(),
      translation: translation,
      translitLatin: _translitController.text.trim(),
      translitCyrillic: '',
      audioAsset: widget.existing?.audioAsset,
      audioUrl: widget.existing?.audioUrl,
    );

    Navigator.pop(context, dua);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return AnimatedBuilder(
      animation: AppLocale.instance,
      builder: (context, _) {
        return AlertDialog(
          title: Text(isEditing ? _t('editor_edit_title') : _t('editor_new_title')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _arabicController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(labelText: _t('field_arabic')),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _translitController,
                  decoration: InputDecoration(labelText: _t('field_translit')),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _translationController,
                  decoration: InputDecoration(labelText: _t('field_translation')),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t('cancel')),
            ),
            FilledButton(
              onPressed: _save,
              child: Text(_t('save')),
            ),
          ],
        );
      },
    );
  }
}
