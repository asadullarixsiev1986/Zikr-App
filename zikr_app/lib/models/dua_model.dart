/// Универсальная модель дуа/зикра — используется и для встроенной
/// библиотеки, и для пользовательских записей в разделе "Свои дуа".
class DuaModel {
  final String id;
  final String arabic;
  final String translation;
  final String translitCyrillic;
  final String translitLatin;

  /// Путь к локальному аудио-файлу в assets, например
  /// 'assets/audio/morning_1.mp3'. Используется, если файл лежит
  /// внутри приложения (встроен в APK).
  final String? audioAsset;

  /// Прямая ссылка на аудио в интернете (стриминг без встраивания
  /// файла в приложение), например 'https://example.com/audio/d_1.mp3'.
  /// Если задано и audioAsset, и audioUrl — приоритет у audioAsset.
  final String? audioUrl;

  const DuaModel({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.translitCyrillic,
    required this.translitLatin,
    this.audioAsset,
    this.audioUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'translation': translation,
        'translitCyrillic': translitCyrillic,
        'translitLatin': translitLatin,
        'audioAsset': audioAsset,
        'audioUrl': audioUrl,
      };

  factory DuaModel.fromJson(Map<String, dynamic> json) => DuaModel(
        id: json['id'] as String,
        arabic: json['arabic'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        translitCyrillic: json['translitCyrillic'] as String? ?? '',
        translitLatin: json['translitLatin'] as String? ?? '',
        audioAsset: json['audioAsset'] as String?,
        audioUrl: json['audioUrl'] as String?,
      );
}
