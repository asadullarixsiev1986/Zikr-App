import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/dua_model.dart';
import 'audio_player_widget.dart';
import 'glass_container.dart';

typedef DuaActionCallback = void Function(DuaModel dua);

/// Список карточек дуа. Используется и для встроенной библиотеки (утро/вечер),
/// и для пользовательского раздела "Свои дуа" (с добавленными кнопками
/// редактирования/удаления, если переданы соответствующие колбэки).
class DuaListView extends StatelessWidget {
  final List<DuaModel> duas;
  final double fontScale;
  final bool isCyrillic;
  final DuaActionCallback? onEdit;
  final DuaActionCallback? onDelete;
  final Widget? emptyState;

  const DuaListView({
    super.key,
    required this.duas,
    required this.fontScale,
    required this.isCyrillic,
    this.onEdit,
    this.onDelete,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (duas.isEmpty && emptyState != null) {
      return emptyState!;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        final dua = duas[index];

        // Если один из вариантов транслитерации не заполнен (например,
        // в пользовательской дуа указан только один вариант) — используем
        // тот, что есть, вместо пустой строки.
        final cyr = dua.translitCyrillic.trim();
        final lat = dua.translitLatin.trim();
        final transliteration = isCyrillic
            ? (cyr.isNotEmpty ? cyr : lat)
            : (lat.isNotEmpty ? lat : cyr);

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (dua.arabic.trim().isNotEmpty) ...[
                Text(
                  dua.arabic,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 28 * fontScale, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
              ],
              if (transliteration.isNotEmpty)
                Text(
                  transliteration,
                  style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary),
                ),
              const SizedBox(height: 8),
              Text(dua.translation, style: TextStyle(fontSize: 18 * fontScale)),
              if (dua.audioAsset != null || dua.audioUrl != null) ...[
                const Divider(height: 30),
                AudioPlayerWidget(audioAsset: dua.audioAsset, audioUrl: dua.audioUrl),
              ],
              if (onEdit != null || onDelete != null) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: () => onEdit!(dua),
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(AppLocale.instance.t('dua_edit')),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: () => onDelete!(dua),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text(AppLocale.instance.t('dua_delete')),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
