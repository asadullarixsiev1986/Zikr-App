import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Простой встроенный i18n без кодогенерации (без flutter gen-l10n),
/// чтобы проект сразу собирался в VS Code без дополнительных шагов.
///
/// Поддерживаемые языки: 'ru' (русский, по умолчанию), 'uz' (узбекский,
/// латиница), 'en' (английский).
class AppLocale extends ChangeNotifier {
  AppLocale._();
  static final AppLocale instance = AppLocale._();

  String languageCode = 'ru';

  static const supportedLanguages = ['ru', 'uz', 'en'];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    languageCode = prefs.getString('language_code') ?? 'ru';
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (!supportedLanguages.contains(code)) return;
    languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    notifyListeners();
  }

  /// Основной метод перевода: AppLocale.instance.t('home_title')
  String t(String key) {
    final byLang = _strings[languageCode];
    return byLang?[key] ?? _strings['ru']?[key] ?? key;
  }

  /// Перевод с подстановкой значений: t('goal_label', {'count': 5, 'goal': 33})
  String tp(String key, Map<String, Object> params) {
    var result = t(key);
    params.forEach((k, v) {
      result = result.replaceAll('{$k}', '$v');
    });
    return result;
  }

  static const Map<String, Map<String, String>> _strings = {
    'ru': {
      // Навигация
      'nav_tasbih': 'Тасбих',
      'nav_dua': 'Дуа',
      'nav_qibla': 'Кибла',
      'nav_settings': 'Настройки',

      // Тасбих
      'home_title': 'Электронный Тасбих',
      'goal_label': 'Цель: {count} / {goal}',
      'streak_label': '🔥 Серия: {days} дней',
      'tap_button': 'TAP',
      'share_button': 'Поделиться прогрессом',
      'tooltip_edit_goal': 'Изменить цель',
      'tooltip_reset': 'Сбросить счётчик',
      'goal_dialog_title': 'Цель счётчика',
      'goal_dialog_custom_label': 'Своё число',
      'goal_dialog_hint': 'Например, 500',
      'goal_dialog_cancel': 'Отмена',
      'goal_dialog_save': 'Сохранить',
      'goal_dialog_enter_positive': 'Введите положительное число',
      'share_text':
          '🌟 Zikr Challenge!\n\nСегодня я сделал {count} зикров (цель: {goal}). Моя серия непрерывных дней: {days} 🔥\n\nПрисоединяйся ко мне в Zikr App и давай улучшать себя вместе! #ZikrChallenge #ZikrApp',

      // Настройки
      'settings_title': 'Настройки',
      'section_feedback': 'ОБРАТНАЯ СВЯЗЬ',
      'vibration_title': 'Вибрация при нажатии',
      'vibration_subtitle': 'Легкая вибрация при счете',
      'sound_title': 'Звук при нажатии',
      'sound_subtitle': 'Системный звук щелчка',
      'section_appearance': 'ОФОРМЛЕНИЕ',
      'theme_light': 'Светлая',
      'theme_dark': 'Тёмная',
      'theme_auto': 'Авто',
      'section_goal': 'ЦЕЛЬ СЧЁТЧИКА',
      'custom_goal_chip': 'Своё число',
      'custom_goal_chip_value': 'Своё: {goal}',
      'section_color': 'ТЕМА ПРИЛОЖЕНИЯ',
      'section_language': 'ЯЗЫК',
      'language_ru': 'Русский',
      'language_uz': "O'zbekcha",
      'language_en': 'English',
      'custom_goal_dialog_title': 'Своя цель счётчика',

      // Дуа
      'dua_title': 'Дуа',
      'tab_morning': 'Утро',
      'tab_evening': 'Вечер',
      'tab_custom': 'Свои дуа',
      'custom_empty_state': 'Здесь пока пусто.\nДобавьте свою первую дуа кнопкой ниже.',
      'dua_edit': 'Изменить',
      'dua_delete': 'Удалить',
      'delete_dialog_title': 'Удалить дуа?',
      'delete_dialog_message': 'Это действие нельзя отменить.',

      // Редактор своей дуа
      'editor_new_title': 'Новая дуа',
      'editor_edit_title': 'Изменить дуа',
      'field_arabic': 'Арабский текст (необязательно)',
      'field_translit': 'Транслитерация (необязательно)',
      'field_translation': 'Перевод / текст дуа *',
      'editor_error_empty': 'Добавьте хотя бы перевод/текст дуа',

      // Общие кнопки
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'delete': 'Удалить',

      // Аудио
      'audio_listen': 'Слушать аудио',
      'audio_playing': 'Воспроизведение...',
      'audio_unavailable': 'Аудио недоступно',
      'audio_missing_snackbar':
          'Аудиофайл не найден. Добавьте mp3 в assets/audio/ (см. README).',

      // Кибла
      'qibla_title': 'Кибла',
      'qibla_loading': 'Определяем местоположение...',
      'qibla_no_service_title': 'Геолокация выключена',
      'qibla_no_service_message': 'Включите службы геолокации в настройках устройства.',
      'qibla_no_permission_title': 'Нет доступа к геолокации',
      'qibla_no_permission_message':
          'Приложению нужно разрешение на определение местоположения, чтобы рассчитать направление на Мекку.',
      'qibla_error_title': 'Не удалось определить местоположение',
      'qibla_error_retry': 'Попробуйте ещё раз.',
      'retry_button': 'Повторить',
      'open_location_settings': 'Открыть настройки геолокации',
      'qibla_bearing_label': 'Азимут на Каабу: {bearing}°',
      'qibla_distance_label': 'Расстояние до Мекки: {distance} км',
      'qibla_instruction_live': 'Поворачивайтесь, пока стрелка не укажет строго вверх.',
      'qibla_instruction_static': 'Сориентируйте телефон по компасу вручную на указанный азимут.',
      'qibla_no_sensor_warning':
          'На этом устройстве не найден датчик компаса — показан азимут от направления на север, без автоповорота.',
      'compass_n': 'С',
      'compass_s': 'Ю',
      'compass_w': 'З',
      'compass_e': 'В',
    },
    'uz': {
      'nav_tasbih': 'Tasbih',
      'nav_dua': 'Duo',
      'nav_qibla': 'Qibla',
      'nav_settings': 'Sozlamalar',

      'home_title': 'Elektron Tasbih',
      'goal_label': 'Maqsad: {count} / {goal}',
      'streak_label': '🔥 Ketma-ket kunlar: {days}',
      'tap_button': 'BOS',
      'share_button': "Natijani ulashish",
      'tooltip_edit_goal': "Maqsadni o'zgartirish",
      'tooltip_reset': "Hisoblagichni nolga tushirish",
      'goal_dialog_title': 'Hisoblagich maqsadi',
      'goal_dialog_custom_label': "O'z raqamingiz",
      'goal_dialog_hint': 'Masalan, 500',
      'goal_dialog_cancel': 'Bekor qilish',
      'goal_dialog_save': 'Saqlash',
      'goal_dialog_enter_positive': 'Musbat son kiriting',
      'share_text':
          "🌟 Zikr Challenge!\n\nBugun men {count} marta zikr qildim (maqsad: {goal}). Uzluksiz kunlar seriyam: {days} 🔥\n\nZikr App'da menga qo'shiling, birga rivojlanamiz! #ZikrChallenge #ZikrApp",

      'settings_title': 'Sozlamalar',
      'section_feedback': 'FEEDBACK',
      'vibration_title': 'Bosganda tebranish',
      'vibration_subtitle': 'Hisoblashda yengil tebranish',
      'sound_title': 'Bosganda tovush',
      'sound_subtitle': 'Tizim bosish tovushi',
      'section_appearance': "KO'RINISH",
      'theme_light': "Yorug'",
      'theme_dark': 'Qorong\'u',
      'theme_auto': 'Avtomatik',
      'section_goal': 'HISOBLAGICH MAQSADI',
      'custom_goal_chip': "O'z raqamingiz",
      'custom_goal_chip_value': "O'zim: {goal}",
      'section_color': 'ILOVA MAVZUSI',
      'section_language': 'TIL',
      'language_ru': 'Русский',
      'language_uz': "O'zbekcha",
      'language_en': 'English',
      'custom_goal_dialog_title': "O'z hisoblagich maqsadi",

      'dua_title': 'Duo',
      'tab_morning': 'Ertalab',
      'tab_evening': 'Kechqurun',
      'tab_custom': "O'z duolarim",
      'custom_empty_state':
          "Bu yerda hozircha bo'sh.\nQuyidagi tugma orqali birinchi duoyingizni qo'shing.",
      'dua_edit': "O'zgartirish",
      'dua_delete': "O'chirish",
      'delete_dialog_title': "Duo o'chirilsinmi?",
      'delete_dialog_message': "Bu amalni qaytarib bo'lmaydi.",

      'editor_new_title': 'Yangi duo',
      'editor_edit_title': "Duoni o'zgartirish",
      'field_arabic': 'Arab matni (ixtiyoriy)',
      'field_translit': 'Transliteratsiya (ixtiyoriy)',
      'field_translation': 'Tarjima / duo matni *',
      'editor_error_empty': 'Kamida tarjima yoki matn kiriting',

      'cancel': 'Bekor qilish',
      'save': 'Saqlash',
      'delete': "O'chirish",

      'audio_listen': 'Audio tinglash',
      'audio_playing': "Ijro etilmoqda...",
      'audio_unavailable': 'Audio mavjud emas',
      'audio_missing_snackbar':
          "Audio fayl topilmadi. assets/audio/ ga mp3 qo'shing (README.md ga qarang).",

      'qibla_title': 'Qibla',
      'qibla_loading': 'Joylashuv aniqlanmoqda...',
      'qibla_no_service_title': "Geolokatsiya o'chirilgan",
      'qibla_no_service_message':
          "Qurilma sozlamalarida geolokatsiya xizmatini yoqing.",
      'qibla_no_permission_title': "Geolokatsiyaga ruxsat yo'q",
      'qibla_no_permission_message':
          "Makkaga yo'nalishni hisoblash uchun ilovaga joylashuvni aniqlash ruxsati kerak.",
      'qibla_error_title': "Joylashuvni aniqlab bo'lmadi",
      'qibla_error_retry': "Qaytadan urinib ko'ring.",
      'retry_button': "Qaytadan urinish",
      'open_location_settings': 'Geolokatsiya sozlamalarini ochish',
      'qibla_bearing_label': "Ka'baga azimut: {bearing}°",
      'qibla_distance_label': 'Makkagacha masofa: {distance} km',
      'qibla_instruction_live': "Strelka aniq tepaga ko'rsatguncha aylaning.",
      'qibla_instruction_static':
          "Telefonni kompas yordamida ko'rsatilgan azimutga qo'lda yo'naltiring.",
      'qibla_no_sensor_warning':
          "Bu qurilmada kompas datchigi topilmadi — avtomatik burilishsiz, shimoldan azimut ko'rsatilmoqda.",
      'compass_n': 'Sh',
      'compass_s': 'J',
      'compass_w': 'G',
      'compass_e': 'Sh-Q',
    },
    'en': {
      'nav_tasbih': 'Tasbih',
      'nav_dua': 'Dua',
      'nav_qibla': 'Qibla',
      'nav_settings': 'Settings',

      'home_title': 'Digital Tasbih',
      'goal_label': 'Goal: {count} / {goal}',
      'streak_label': '🔥 Streak: {days} days',
      'tap_button': 'TAP',
      'share_button': 'Share progress',
      'tooltip_edit_goal': 'Change goal',
      'tooltip_reset': 'Reset counter',
      'goal_dialog_title': 'Counter goal',
      'goal_dialog_custom_label': 'Custom number',
      'goal_dialog_hint': 'e.g. 500',
      'goal_dialog_cancel': 'Cancel',
      'goal_dialog_save': 'Save',
      'goal_dialog_enter_positive': 'Enter a positive number',
      'share_text':
          "🌟 Zikr Challenge!\n\nToday I did {count} dhikr (goal: {goal}). My current streak: {days} days 🔥\n\nJoin me on Zikr App and let's grow together! #ZikrChallenge #ZikrApp",

      'settings_title': 'Settings',
      'section_feedback': 'FEEDBACK',
      'vibration_title': 'Vibrate on tap',
      'vibration_subtitle': 'Light vibration on each count',
      'sound_title': 'Sound on tap',
      'sound_subtitle': 'System click sound',
      'section_appearance': 'APPEARANCE',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_auto': 'Auto',
      'section_goal': 'COUNTER GOAL',
      'custom_goal_chip': 'Custom number',
      'custom_goal_chip_value': 'Custom: {goal}',
      'section_color': 'APP THEME',
      'section_language': 'LANGUAGE',
      'language_ru': 'Русский',
      'language_uz': "O'zbekcha",
      'language_en': 'English',
      'custom_goal_dialog_title': 'Custom counter goal',

      'dua_title': 'Dua',
      'tab_morning': 'Morning',
      'tab_evening': 'Evening',
      'tab_custom': 'My duas',
      'custom_empty_state': "It's empty here yet.\nAdd your first dua with the button below.",
      'dua_edit': 'Edit',
      'dua_delete': 'Delete',
      'delete_dialog_title': 'Delete this dua?',
      'delete_dialog_message': 'This action cannot be undone.',

      'editor_new_title': 'New dua',
      'editor_edit_title': 'Edit dua',
      'field_arabic': 'Arabic text (optional)',
      'field_translit': 'Transliteration (optional)',
      'field_translation': 'Translation / dua text *',
      'editor_error_empty': 'Please add at least a translation or text',

      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',

      'audio_listen': 'Listen to audio',
      'audio_playing': 'Playing...',
      'audio_unavailable': 'Audio unavailable',
      'audio_missing_snackbar':
          'Audio file not found. Add an mp3 to assets/audio/ (see README).',

      'qibla_title': 'Qibla',
      'qibla_loading': 'Detecting your location...',
      'qibla_no_service_title': 'Location services are off',
      'qibla_no_service_message': 'Enable location services in your device settings.',
      'qibla_no_permission_title': 'No location access',
      'qibla_no_permission_message':
          'The app needs location access to calculate the direction to Mecca.',
      'qibla_error_title': 'Could not determine your location',
      'qibla_error_retry': 'Please try again.',
      'retry_button': 'Retry',
      'open_location_settings': 'Open location settings',
      'qibla_bearing_label': 'Bearing to the Kaaba: {bearing}°',
      'qibla_distance_label': 'Distance to Mecca: {distance} km',
      'qibla_instruction_live': 'Turn until the arrow points straight up.',
      'qibla_instruction_static':
          'Manually orient your phone using a compass to the shown bearing.',
      'qibla_no_sensor_warning':
          "No compass sensor found on this device — showing a static bearing from north instead of a live arrow.",
      'compass_n': 'N',
      'compass_s': 'S',
      'compass_w': 'W',
      'compass_e': 'E',
    },
  };
}
