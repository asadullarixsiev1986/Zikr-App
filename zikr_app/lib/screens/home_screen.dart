import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import '../models/app_settings.dart';
import '../widgets/glass_container.dart';
import '../widgets/islamic_scaffold.dart';
import '../widgets/tasbih_bead_ring.dart';

class ZikrHomePage extends StatefulWidget {
  final AppSettings settings;
  const ZikrHomePage({super.key, required this.settings});

  @override
  State<ZikrHomePage> createState() => _ZikrHomePageState();
}

class _ZikrHomePageState extends State<ZikrHomePage> {
  int _counter = 0;
  int _streakDays = 0;

  String _t(String key) => AppLocale.instance.t(key);
  String _tp(String key, Map<String, Object> params) =>
      AppLocale.instance.tp(key, params);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('last_date') ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);

    int savedCounter = prefs.getInt('tasbih_counter') ?? 0;
    int savedStreak = prefs.getInt('streak_days') ?? 0;

    setState(() {
      if (savedDate == today) {
        _counter = savedCounter;
        _streakDays = savedStreak;
      } else {
        _counter = 0;

        if (savedDate.isNotEmpty) {
          final lastDateObj = DateTime.parse(savedDate);
          final todayObj = DateTime.parse(today);
          final difference = todayObj.difference(lastDateObj).inDays;

          _streakDays = (difference == 1) ? savedStreak : 0;
        } else {
          _streakDays = 0;
        }
      }
    });
  }

  void _increment() async {
    if (widget.settings.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    if (widget.settings.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('last_date') ?? '';

    setState(() {
      _counter++;
      if (savedDate != today) {
        if (savedDate.isEmpty) {
          _streakDays = 1;
        } else {
          final lastDateObj = DateTime.parse(savedDate);
          final todayObj = DateTime.parse(today);
          final difference = todayObj.difference(lastDateObj).inDays;
          _streakDays = (difference == 1) ? _streakDays + 1 : 1;
        }
      }
    });

    if (_counter == widget.settings.dailyGoal && widget.settings.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    await prefs.setInt('tasbih_counter', _counter);
    await prefs.setInt('streak_days', _streakDays);
    await prefs.setString('last_date', today);

    // НОВОЕ: автообнуление счётчика при достижении цели —
    // только для стандартных целей 33 и 99. Если у пользователя
    // задано своё число — счётчик продолжает считать дальше без сброса.
    final goal = widget.settings.dailyGoal;
    if (_counter == goal && AppSettings.presetGoals.contains(goal)) {
      // Небольшая пауза, чтобы пользователь успел увидеть финальное число
      // (33 или 99), прежде чем счётчик обнулится.
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _counter = 0);
      await prefs.setInt('tasbih_counter', 0);
    }
  }

  void _resetCounter() async {
    setState(() => _counter = 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_counter', _counter);
  }

  void _shareProgress() {
    final text = _tp('share_text', {
      'count': _counter,
      'goal': widget.settings.dailyGoal,
      'days': _streakDays,
    });
    Share.share(text);
  }

  Future<void> _openGoalPicker() async {
    final customController = TextEditingController();
    int? chosen = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_t('goal_dialog_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                children: AppSettings.presetGoals.map((goal) {
                  return ChoiceChip(
                    label: Text('$goal'),
                    selected: widget.settings.dailyGoal == goal,
                    onSelected: (_) => Navigator.pop(context, goal),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: customController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _t('goal_dialog_custom_label'),
                  hintText: _t('goal_dialog_hint'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t('goal_dialog_cancel')),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(customController.text.trim());
                if (parsed != null && parsed > 0) {
                  Navigator.pop(context, parsed);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_t('goal_dialog_enter_positive'))),
                  );
                }
              },
              child: Text(_t('goal_dialog_save')),
            ),
          ],
        );
      },
    );

    if (chosen != null) {
      await widget.settings.changeDailyGoal(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLocale.instance,
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final goal = widget.settings.dailyGoal;
    double progress = (_counter / goal).clamp(0.0, 1.0);
    final themeColor = Theme.of(context).colorScheme.primary;

    return IslamicScaffold(
      title: _t('home_title'),
      actions: [
        IconButton(
          tooltip: _t('tooltip_edit_goal'),
          icon: const Icon(Icons.flag_outlined),
          onPressed: _openGoalPicker,
        ),
        IconButton(
          tooltip: _t('tooltip_reset'),
          icon: const Icon(Icons.refresh),
          onPressed: _resetCounter,
        ),
      ],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _openGoalPicker,
                      child: Row(
                        children: [
                          Text(_tp('goal_label', {'count': _counter, 'goal': goal})),
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 14, color: Colors.grey[500]),
                        ],
                      ),
                    ),
                    Text(
                      _tp('streak_label', {'days': _streakDays}),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Кольцо чёток (33 бусины) в стиле liquid glass вокруг
              // уменьшенной кнопки TAP — заполняется по мере прогресса.
              Stack(
                alignment: Alignment.center,
                children: [
                  TasbihBeadRing(
                    progress: progress,
                    size: 300,
                    color: themeColor,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_counter',
                        style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: themeColor),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _increment,
                        child: Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, -0.4),
                              colors: [
                                Colors.white.withValues(alpha: 0.55),
                                themeColor.withValues(alpha: 0.9),
                                themeColor,
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.55),
                                blurRadius: 26,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _t('tap_button'),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),
              GlassContainer(
                borderRadius: 40,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                blurSigma: 10,
                child: TextButton.icon(
                  onPressed: _shareProgress,
                  icon: Icon(Icons.share, color: themeColor),
                  label: Text(
                    _t('share_button'),
                    style: TextStyle(color: themeColor, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
