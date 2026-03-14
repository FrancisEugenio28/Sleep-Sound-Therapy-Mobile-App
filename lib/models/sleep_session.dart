import 'dart:async';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> exportDataToCSV() async {
    final db = await instance.database;
    // Pulls every sleep session, sorted chronologically
    final List<Map<String, dynamic>> rawData = await db.query('sessions', orderBy: 'startTime ASC');

    if (rawData.isEmpty) return;

    // 1. Create the CSV Header Row
    List<List<dynamic>> csvData = [
      ['Session ID', 'Start Time', 'End Time', 'Duration (mins)', 'Latency (mins)', 'Efficiency (%)', 'Avg Noise', 'Quality Score']
    ];

    // 2. Loop through the SQLite data and add it to the CSV rows
    for (var row in rawData) {
      csvData.add([
        row['id'],
        row['startTime'],
        row['endTime'],
        row['durationMinutes'],
        row['sleepLatency'],
        row['sleepEfficiency'],
        row['avgNoiseLevel'],
        row['qualityScore']
      ]);
    }

    // 3. Convert the Dart List to a raw CSV String
    String csvString = const ListToCsvConverter().convert(csvData);

    // 4. Save the file temporarily to the phone's hidden app storage
    final directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/SleepData_Export.csv';
    final File file = File(filePath);
    await file.writeAsString(csvString);

    // 5. Open the native Android Share/Email menu
    await Share.shareXFiles([XFile(filePath)], text: 'Attached is the raw Sleep Data CSV for thesis analysis.');
  }
}