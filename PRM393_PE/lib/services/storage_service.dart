import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _historyKey = 'lucky_draw_history';

  static Future<void> saveWinner(String gameType, String winner) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    history.add({
      'game': gameType,
      'winner': winner,
      'time': DateTime.now().toString().substring(0, 19),
    });

    final jsonList = history.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  static Future<List<Map<String, String>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    
    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value.toString()));
    }).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
