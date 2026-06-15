import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/progress_model.dart';

class ProgressRepository {
  static const _key = 'devoca_word_progress';
  static const _dailyKey = 'devoca_daily_words';

  Future<Map<String, WordProgress>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map(
      (k, v) => MapEntry(k, WordProgress.fromJson(v as Map<String, dynamic>)),
    );
  }

  Future<void> saveAll(Map<String, WordProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      progress.map((k, v) => MapEntry(k, v.toJson())),
    );
    await prefs.setString(_key, encoded);
  }

  Future<List<String>?> loadDailyWords(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dailyKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if (!map.containsKey(dateKey)) return null;
    return (map[dateKey] as List).cast<String>();
  }

  Future<void> saveDailyWords(String dateKey, List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyKey, jsonEncode({dateKey: words}));
  }
}
