import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dua_model.dart';

/// Хранит дуа, добавленные самим пользователем ("Свои дуа"),
/// отдельно от встроенной библиотеки. Сериализуется в JSON-строку
/// внутри SharedPreferences под ключом [_key].
class CustomDuaRepository {
  static const _key = 'custom_duas_json';

  Future<List<DuaModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => DuaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Если данные повреждены — не роняем приложение, просто начинаем с пустого списка.
      return [];
    }
  }

  Future<void> _saveAll(List<DuaModel> duas) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(duas.map((d) => d.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<List<DuaModel>> add(DuaModel dua) async {
    final all = await loadAll();
    all.add(dua);
    await _saveAll(all);
    return all;
  }

  Future<List<DuaModel>> update(DuaModel dua) async {
    final all = await loadAll();
    final index = all.indexWhere((d) => d.id == dua.id);
    if (index != -1) {
      all[index] = dua;
      await _saveAll(all);
    }
    return all;
  }

  Future<List<DuaModel>> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((d) => d.id == id);
    await _saveAll(all);
    return all;
  }
}
