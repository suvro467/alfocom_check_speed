import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// Database table and column names.
final String tableSpeedHistory = 'speedhistory';
final String columnId = '_id';
final String columnDateTime = 'datetime';
final String columnPingInMilliseconds = 'pinginmilliseconds';
final String columnDownloadSpeed = 'downloadspeed';
final String columnUploadSpeed = 'uploadspeed';

// Data model class
class SpeedHistory {
  int id;
  String dateTime;
  double pingInMilliseconds;
  double downloadSpeed;
  double uploadSpeed;

  SpeedHistory();

  // Convenience constructor to create a SpeedHistory object
  SpeedHistory.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    dateTime = map[columnDateTime];
    pingInMilliseconds = map[columnPingInMilliseconds];
    downloadSpeed = map[columnDownloadSpeed];
    uploadSpeed = map[columnUploadSpeed];
  }

  // Convenience method to create a Map from the SpeedHistory object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDateTime: dateTime,
      columnPingInMilliseconds: pingInMilliseconds,
      columnDownloadSpeed: downloadSpeed,
      columnUploadSpeed: uploadSpeed,
    };
    if (id != null) {
      map[columnId] = id;
    }

    return map;
  }
}

// Singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the application directory.
  static final _databaseName = 'CheckSpeedDatabase.db';
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableSpeedHistory (
                $columnId INTEGER PRIMARY KEY,
                $columnDateTime TEXT NOT NULL,
                $columnPingInMilliseconds REAL NOT NULL,
                $columnDownloadSpeed REAL NOT NULL,
                $columnUploadSpeed REAL NOT NULL
              )
              ''');
  }

  // Database helper methods:
  Future<int> insert(SpeedHistory speedHistory) async {
    Database db = await database;
    int id = await db.insert(tableSpeedHistory, speedHistory.toMap());
    return id;
  }

  Future<SpeedHistory> querySpeedHistory(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableSpeedHistory,
        columns: [
          columnId,
          columnDateTime,
          columnPingInMilliseconds,
          columnDownloadSpeed,
          columnUploadSpeed
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return SpeedHistory.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SpeedHistory>> querySpeedHistories() async {
    Database db = await database;
    List<SpeedHistory> listOfSpeedChecks = List<SpeedHistory>();
    List<Map> maps = await db.query(tableSpeedHistory,
        columns: [
          columnId,
          columnDateTime,
          columnPingInMilliseconds,
          columnDownloadSpeed,
          columnUploadSpeed
        ],
        orderBy: '_id Desc');
    if (maps.length > 0) {
      for (var item in maps) {
        print(item);
        SpeedHistory objSpeedHistory = SpeedHistory.fromMap(item);
        //print('Testing');
        listOfSpeedChecks.add(objSpeedHistory);
      }
    }

    return listOfSpeedChecks;
  }

  Future deleteFromSpeedHistoryTable() async {
    Database db = await database;
    await db.delete(tableSpeedHistory);
  }

  Future deleteSelectedFromSpeedHistoryTable(int id) async {
    Database db = await database;
    await db.delete(
      tableSpeedHistory,
      where: '_id = ?',
      whereArgs: [id],
    );
  }
}
