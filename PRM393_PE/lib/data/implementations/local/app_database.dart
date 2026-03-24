import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lucky_draw.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        // Lịch sử trúng thưởng
        await db.execute('''
          CREATE TABLE winners(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            game_type TEXT NOT NULL,
            winner_name TEXT NOT NULL,
            created_at TEXT NOT NULL
          );
        ''');

        // Danh sách các vòng quay đã lưu
        await db.execute('''
          CREATE TABLE saved_wheels(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            spin_count INTEGER NOT NULL DEFAULT 0,
            spin_time REAL NOT NULL DEFAULT 4.0,
            created_at TEXT NOT NULL,
            last_used TEXT
          );
        ''');

        // Cấu hình slices cho từng vòng quay
        await db.execute('''
          CREATE TABLE wheel_slices(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            wheel_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            emoji TEXT,
            color INTEGER NOT NULL,
            repeat_count INTEGER NOT NULL DEFAULT 1,
            probability REAL NOT NULL DEFAULT 1.0,
            display_order INTEGER NOT NULL,
            FOREIGN KEY (wheel_id) REFERENCES saved_wheels (id) ON DELETE CASCADE
          );
        ''');

        // Phần thưởng lì xì
        await db.execute('''
          CREATE TABLE red_envelope_prizes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prize_name TEXT NOT NULL,
            display_order INTEGER NOT NULL
          );
        ''');

        // Insert default prizes
        final defaultPrizes = [
          '100.000đ', '200.000đ', '500.000đ', '1.000.000đ',
          'iPhone 15', 'AirPods', 'Sổ đỏ', '1 căn Vinhome',
          'Biệt thự', 'Thẻ cào 100k'
        ];
        for (int i = 0; i < defaultPrizes.length; i++) {
          await db.insert('red_envelope_prizes', {
            'prize_name': defaultPrizes[i],
            'display_order': i,
          });
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Add red_envelope_prizes table
          await db.execute('''
            CREATE TABLE red_envelope_prizes(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              prize_name TEXT NOT NULL,
              display_order INTEGER NOT NULL
            );
          ''');

          // Insert default prizes
          final defaultPrizes = [
            '100.000đ', '200.000đ', '500.000đ', '1.000.000đ',
            'iPhone 15', 'AirPods', 'Sổ đỏ', '1 căn Vinhome',
            'Biệt thự', 'Thẻ cào 100k'
          ];
          for (int i = 0; i < defaultPrizes.length; i++) {
            await db.insert('red_envelope_prizes', {
              'prize_name': defaultPrizes[i],
              'display_order': i,
            });
          }
          
          // Add probability column to wheel_slices if not exists
          try {
            await db.execute('ALTER TABLE wheel_slices ADD COLUMN probability REAL NOT NULL DEFAULT 1.0');
          } catch (e) {
            // Column might already exist
          }
        }
      },
    );
  }

  // Winner History Methods
  Future<int> insertWinner(String gameType, String winnerName, [String? createdAt]) async {
    final database = await db;
    return await database.insert('winners', {
      'game_type': gameType,
      'winner_name': winnerName,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getWinners() async {
    final database = await db;
    return await database.query(
      'winners',
      orderBy: 'created_at DESC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getWinnersByGame(String gameType) async {
    final database = await db;
    return await database.query(
      'winners',
      where: 'game_type = ?',
      whereArgs: [gameType],
      orderBy: 'created_at DESC',
    );
  }
  
  Future<int> getWinnersCount() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) as count FROM winners');
    return result.isNotEmpty ? (result.first['count'] as int?) ?? 0 : 0;
  }

  Future<int> clearWinners() async {
    final database = await db;
    return await database.delete('winners');
  }

  // Saved Wheels Methods
  Future<int> insertSavedWheel(String title, double spinTime) async {
    final database = await db;
    return await database.insert('saved_wheels', {
      'title': title,
      'spin_count': 0,
      'spin_time': spinTime,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSavedWheels() async {
    final database = await db;
    return await database.query(
      'saved_wheels',
      orderBy: 'last_used DESC, created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getSavedWheel(int id) async {
    final database = await db;
    final results = await database.query(
      'saved_wheels',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateSavedWheel(int id, String title, double spinTime) async {
    final database = await db;
    return await database.update(
      'saved_wheels',
      {
        'title': title,
        'spin_time': spinTime,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> incrementSpinCount(int wheelId) async {
    final database = await db;
    await database.rawUpdate(
      'UPDATE saved_wheels SET spin_count = spin_count + 1, last_used = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), wheelId],
    );
    return wheelId;
  }

  Future<int> deleteSavedWheel(int id) async {
    final database = await db;
    return await database.delete(
      'saved_wheels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Wheel Slices Methods
  Future<int> insertWheelSlice(
    int wheelId,
    String name,
    String emoji,
    int color,
    int repeatCount,
    int displayOrder, {
    double probability = 1.0,
  }) async {
    final database = await db;
    return await database.insert('wheel_slices', {
      'wheel_id': wheelId,
      'name': name,
      'emoji': emoji,
      'color': color,
      'repeat_count': repeatCount,
      'display_order': displayOrder,
      'probability': probability,
    });
  }

  Future<List<Map<String, dynamic>>> getWheelSlices(int wheelId) async {
    final database = await db;
    return await database.query(
      'wheel_slices',
      where: 'wheel_id = ?',
      whereArgs: [wheelId],
      orderBy: 'display_order ASC',
    );
  }

  Future<int> updateWheelSlice(
    int id,
    String name,
    String emoji,
    int color,
    int repeatCount,
  ) async {
    final database = await db;
    return await database.update(
      'wheel_slices',
      {
        'name': name,
        'emoji': emoji,
        'color': color,
        'repeat_count': repeatCount,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteWheelSlice(int id) async {
    final database = await db;
    return await database.delete(
      'wheel_slices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearWheelSlices(int wheelId) async {
    final database = await db;
    return await database.delete(
      'wheel_slices',
      where: 'wheel_id = ?',
      whereArgs: [wheelId],
    );
  }

  // Red Envelope Prizes Methods
  Future<List<Map<String, dynamic>>> getRedEnvelopePrizes() async {
    final database = await db;
    return await database.query(
      'red_envelope_prizes',
      orderBy: 'display_order ASC',
    );
  }

  Future<int> insertRedEnvelopePrize(String prizeName, int displayOrder) async {
    final database = await db;
    return await database.insert('red_envelope_prizes', {
      'prize_name': prizeName,
      'display_order': displayOrder,
    });
  }

  Future<int> updateRedEnvelopePrize(int id, String prizeName) async {
    final database = await db;
    return await database.update(
      'red_envelope_prizes',
      {'prize_name': prizeName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRedEnvelopePrize(int id) async {
    final database = await db;
    return await database.delete(
      'red_envelope_prizes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearRedEnvelopePrizes() async {
    final database = await db;
    await database.delete('red_envelope_prizes');
  }

  Future<void> reorderRedEnvelopePrizes(List<Map<String, dynamic>> prizes) async {
    final database = await db;
    for (int i = 0; i < prizes.length; i++) {
      await database.update(
        'red_envelope_prizes',
        {'display_order': i},
        where: 'id = ?',
        whereArgs: [prizes[i]['id']],
      );
    }
  }
}




