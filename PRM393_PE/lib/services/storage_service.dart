import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:prm393_pe/data/implementations/local/app_database.dart';

class StorageService {
  // Migration: Move data from SharedPreferences to Database
  static Future<void> migrateToDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('lucky_draw_history') ?? [];
      
      if (jsonList.isNotEmpty) {
        // Migrate old data to database
        for (var jsonStr in jsonList) {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          await AppDatabase.instance.insertWinner(
            map['game'] as String,
            map['winner'] as String,
            map['time'] as String,
          );
        }
        
        // Clear old data after migration
        await prefs.remove('lucky_draw_history');
      }
    } catch (e) {
      print('Migration error: $e');
    }
  }

  static Future<void> saveWinner(String gameType, String winner) async {
    await AppDatabase.instance.insertWinner(
      gameType,
      winner,
      DateTime.now().toString().substring(0, 19),
    );
  }

  static Future<List<Map<String, String>>> getHistory() async {
    final winners = await AppDatabase.instance.getWinners();
    return winners.map((winner) => {
      'game': winner['game_type'] as String,
      'winner': winner['winner_name'] as String,
      'time': winner['created_at'] as String,
    }).toList();
  }

  static Future<void> clearHistory() async {
    await AppDatabase.instance.clearWinners();
  }
  
  // New: Get history by game type
  static Future<List<Map<String, String>>> getHistoryByGame(String gameType) async {
    final winners = await AppDatabase.instance.getWinnersByGame(gameType);
    return winners.map((winner) => {
      'game': winner['game_type'] as String,
      'winner': winner['winner_name'] as String,
      'time': winner['created_at'] as String,
    }).toList();
  }
  
  // New: Get history count
  static Future<int> getHistoryCount() async {
    return await AppDatabase.instance.getWinnersCount();
  }
}
