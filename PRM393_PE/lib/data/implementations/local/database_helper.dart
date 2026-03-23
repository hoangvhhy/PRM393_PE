import 'package:prm393_pe/data/implementations/local/app_database.dart';

class DatabaseHelper {
  // Test database connection
  static Future<bool> testConnection() async {
    try {
      final db = await AppDatabase.instance.db;
      final result = await db.rawQuery('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      print('Database connection error: $e');
      return false;
    }
  }

  // Get database info
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await AppDatabase.instance.db;
      
      // Count wheels
      final wheelsCount = await db.rawQuery('SELECT COUNT(*) as count FROM saved_wheels');
      final slicesCount = await db.rawQuery('SELECT COUNT(*) as count FROM wheel_slices');
      final winnersCount = await db.rawQuery('SELECT COUNT(*) as count FROM winners');
      
      return {
        'wheels': wheelsCount.first['count'],
        'slices': slicesCount.first['count'],
        'winners': winnersCount.first['count'],
        'connected': true,
      };
    } catch (e) {
      print('Database info error: $e');
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    final db = await AppDatabase.instance.db;
    await db.delete('saved_wheels');
    await db.delete('wheel_slices');
    await db.delete('winners');
  }

  // Create sample wheel for testing
  static Future<int> createSampleWheel() async {
    final wheelId = await AppDatabase.instance.insertSavedWheel('Sample Wheel', 4.0);
    
    // Add sample slices
    await AppDatabase.instance.insertWheelSlice(wheelId, 'Prize 1', '🎁', 0xFF4CAF50, 1, 0);
    await AppDatabase.instance.insertWheelSlice(wheelId, 'Prize 2', '🎉', 0xFF2196F3, 1, 1);
    await AppDatabase.instance.insertWheelSlice(wheelId, 'Prize 3', '⭐', 0xFFFF9800, 1, 2);
    
    return wheelId;
  }
}
