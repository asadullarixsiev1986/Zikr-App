import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/custom_dua_repository.dart';
import '../data/zikr_data.dart';
import '../l10n/app_strings.dart';
import '../models/dua_model.dart';
import '../widgets/dua_list_view.dart';
import '../widgets/islamic_scaffold.dart';
import 'custom_dua_editor.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  double _fontScale = 1.0;
  bool _isCyrillic = false;
  final _customRepo = CustomDuaRepository();
  List<DuaModel> _customDuas = [];

  String _t(String key) => AppLocale.instance.t(key);

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCustomDuas();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontScale = prefs.getDouble('font_scale') ?? 1.0;
      _isCyrillic = prefs.getBool('is_cyrillic') ?? false;
    });
  }

  Future<void> _loadCustomDuas() async {
    final duas = await _customRepo.loadAll();
    if (mounted) setState(() => _customDuas = duas);
  }

  void _increaseFontSize() async {
    if (_fontScale < 2.0) {
      setState(() => _fontScale += 0.2);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_scale', _fontScale);
    }
  }

  void _decreaseFontSize() async {
    if (_fontScale > 0.8) {
      setState(() => _fontScale -= 0.2);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_scale', _fontScale);
    }
  }

  void _toggleScript() async {
    setState(() => _isCyrillic = !_isCyrillic);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_cyrillic', _isCyrillic);
  }

  Future<void> _addCustomDua() async {
    final result = await showCustomDuaEditor(context);
    if (result == null) return;
    final updated = await _customRepo.add(result);
    if (mounted) setState(() => _customDuas = updated);
  }

  Future<void> _editCustomDua(DuaModel dua) async {
    final result = await showCustomDuaEditor(context, existing: dua);
    if (result == null) return;
    final updated = await _customRepo.update(result);
    if (mounted) setState(() => _customDuas = updated);
  }

  Future<void> _deleteCustomDua(DuaModel dua) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('delete_dialog_title')),
        content: Text(_t('delete_dialog_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(_t('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final updated = await _customRepo.delete(dua.id);
    if (mounted) setState(() => _customDuas = updated);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLocale.instance,
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: IslamicScaffold(
        title: _t('dua_title'),
        actions: [
          IconButton(
              icon: const Icon(Icons.text_decrease),
              onPressed: _decreaseFontSize),
          IconButton(
              icon: const Icon(Icons.text_increase),
              onPressed: _increaseFontSize),
          TextButton(
            onPressed: _toggleScript,
            child: Text(
              _isCyrillic ? 'КИР' : 'LAT',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ],
        bottom: TabBar(
          tabs: [
            Tab(text: _t('tab_morning')),
            Tab(text: _t('tab_evening')),
            Tab(text: _t('tab_custom')),
          ],
        ),
        body: TabBarView(
          children: [
            DuaListView(
              duas: ZikrData.morning,
              fontScale: _fontScale,
              isCyrillic: _isCyrillic,
            ),
            DuaListView(
              duas: ZikrData.evening,
              fontScale: _fontScale,
              isCyrillic: _isCyrillic,
            ),
            DuaListView(
              duas: _customDuas,
              fontScale: _fontScale,
              isCyrillic: _isCyrillic,
              onEdit: _editCustomDua,
              onDelete: _deleteCustomDua,
              emptyState: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories_outlined,
                          size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _t('custom_empty_state'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                if (tabController.index != 2) return const SizedBox.shrink();
                return FloatingActionButton(
                  onPressed: _addCustomDua,
                  child: const Icon(Icons.add),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
