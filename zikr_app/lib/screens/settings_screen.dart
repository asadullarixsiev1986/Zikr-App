import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;
  const SettingsScreen({super.key, required this.settings});

  String _t(String key) => AppLocale.instance.t(key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([settings, AppLocale.instance]),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_t('settings_title')),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(_t('section_feedback'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              SwitchListTile(
                title: Text(_t('vibration_title')),
                subtitle: Text(_t('vibration_subtitle')),
                value: settings.vibrationEnabled,
                onChanged: settings.toggleVibration,
              ),
              SwitchListTile(
                title: Text(_t('sound_title')),
                subtitle: Text(_t('sound_subtitle')),
                value: settings.soundEnabled,
                onChanged: settings.toggleSound,
              ),
              const Divider(),
              const SizedBox(height: 10),

              // НОВОЕ: выбор языка приложения
              Text(_t('section_language'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: AppLocale.supportedLanguages.map((code) {
                  final isSelected = AppLocale.instance.languageCode == code;
                  return ChoiceChip(
                    label: Text(_t('language_$code')),
                    selected: isSelected,
                    onSelected: (_) => AppLocale.instance.setLanguage(code),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text(_t('section_appearance'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(_t('theme_light')),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(_t('theme_dark')),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(_t('theme_auto')),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) {
                  settings.changeThemeMode(selection.first);
                },
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text(_t('section_goal'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ...AppSettings.presetGoals.map((goal) {
                    return ChoiceChip(
                      label: Text('$goal'),
                      selected: settings.dailyGoal == goal,
                      onSelected: (_) => settings.changeDailyGoal(goal),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.edit, size: 18),
                    label: Text(
                      AppSettings.presetGoals.contains(settings.dailyGoal)
                          ? _t('custom_goal_chip')
                          : AppLocale.instance.tp(
                              'custom_goal_chip_value', {'goal': settings.dailyGoal}),
                    ),
                    onPressed: () => _showCustomGoalDialog(context, settings),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text(_t('section_color'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: settings.availableColors.map((color) {
                  final isSelected = settings.themeColor == color;
                  return GestureDetector(
                    onTap: () => settings.changeThemeColor(color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCustomGoalDialog(
      BuildContext context, AppSettings settings) async {
    final controller = TextEditingController(
      text: AppSettings.presetGoals.contains(settings.dailyGoal)
          ? ''
          : '${settings.dailyGoal}',
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('custom_goal_dialog_title')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: _t('goal_dialog_hint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed != null && parsed > 0) {
                Navigator.pop(context, parsed);
              }
            },
            child: Text(_t('save')),
          ),
        ],
      ),
    );

    if (result != null) {
      await settings.changeDailyGoal(result);
    }
  }
}
