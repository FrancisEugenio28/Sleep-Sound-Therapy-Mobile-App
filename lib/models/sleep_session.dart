import 'dart:async';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 1. THE DATA MODEL
class SleepSession {
  final int? id;
  final DateTime startTime;      // When you connected (Time In Bed Start)
  final DateTime endTime;        // When you disconnected (Time In Bed End)
  final int durationMinutes;     // Total Sleep Time (Time in Bed - Latency - Awake)
  final int sleepLatency;        // Time taken to fall asleep (minutes)
  final int sleepEfficiency;     // (Total Sleep Time / Total Time in Bed) %
  final int avgNoiseLevel;       // Average environment noise
  final int qualityScore;        // Overall score (0-100)

  SleepSession({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.sleepLatency,
    required this.sleepEfficiency,
    required this.avgNoiseLevel,
    required this.qualityScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'sleepLatency': sleepLatency,
      'sleepEfficiency': sleepEfficiency,
      'avgNoiseLevel': avgNoiseLevel,
      'qualityScore': qualityScore,
    };
  }

  factory SleepSession.fromMap(Map<String, dynamic> map) {
    return SleepSession(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      durationMinutes: map['durationMinutes'],
      sleepLatency: map['sleepLatency'],
      sleepEfficiency: map['sleepEfficiency'],
      avgNoiseLevel: map['avgNoiseLevel'],
      qualityScore: map['qualityScore'],
    );
  }
}

// 2. THE DATABASE MANAGER
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sleep_history_v2.db'); // Renamed to force fresh DB creation
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE sessions ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      startTime TEXT NOT NULL,
      endTime TEXT NOT NULL,
      durationMinutes INTEGER NOT NULL,
      sleepLatency INTEGER NOT NULL,
      sleepEfficiency INTEGER NOT NULL,
      avgNoiseLevel INTEGER NOT NULL,
      qualityScore INTEGER NOT NULL
      )
    ''');
  }

  Future<int> createSession(SleepSession session) async {
    final db = await instance.database;
    return await db.insert('sessions', session.toMap());
  }

  Future<List<SleepSession>> getAllSessions() async {
    final db = await instance.database;
    final orderBy = 'startTime DESC';
    final result = await db.query('sessions', orderBy: orderBy);
    return result.map((json) => SleepSession.fromMap(json)).toList();
  }

  Future<Map<String, dynamic>> getAverages() async {
    final db = await instance.database;
    // We now calculate averages for Efficiency and Latency too
    final result = await db.rawQuery('''
      SELECT 
        AVG(durationMinutes) as avgDur, 
        AVG(sleepEfficiency) as avgEff,
        AVG(sleepLatency) as avgLat,
        AVG(qualityScore) as avgQual 
      FROM sessions
    ''');
    
    if (result.isNotEmpty && result.first['avgDur'] != null) {
       return {
         'avgDuration': (result.first['avgDur'] as double).round(),
         'avgEfficiency': (result.first['avgEff'] as double).round(),
         'avgLatency': (result.first['avgLat'] as double).round(),
         'avgQuality': (result.first['avgQual'] as double).round(),
         'sessionCount': result.length,
       };
    } else {
      return {'avgDuration': 0, 'avgEfficiency': 0, 'avgLatency': 0, 'avgQuality': 0, 'sessionCount': 0};
    }
  }

  // UPDATED DUMMY DATA GENERATOR
  Future<void> generateDummyData() async {
    final db = await instance.database;
    await db.delete('sessions'); 
    
    var rng = Random();
    DateTime now = DateTime.now();
    
    for (int i = 1; i <= 7; i++) {
      DateTime start = now.subtract(Duration(days: i, hours: 22 + rng.nextInt(2))); 
      DateTime end = start.add(Duration(hours: 6 + rng.nextInt(3))); // 6-9 hours in bed
      
      int timeInBedMinutes = end.difference(start).inMinutes;
      int latency = 15 + rng.nextInt(30); // 15-45 min latency
      int awakeTime = 10 + rng.nextInt(20); // Random awake time during night
      
      // Calculate derived metrics
      int actualSleepDuration = timeInBedMinutes - latency - awakeTime;
      int efficiency = ((actualSleepDuration / timeInBedMinutes) * 100).toInt();
      
      int noise = 2000 + rng.nextInt(5000); 
      int quality = (efficiency * 0.8 + (100 - (noise/100))*0.2).toInt().clamp(0, 100);

      SleepSession dummy = SleepSession(
        startTime: start,
        endTime: end,
        durationMinutes: actualSleepDuration,
        sleepLatency: latency,
        sleepEfficiency: efficiency,
        avgNoiseLevel: noise,
        qualityScore: quality
      );
      await createSession(dummy);
      print("Created Dummy session for day -$i");
    }
  }
}