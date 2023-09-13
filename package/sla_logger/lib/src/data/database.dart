import 'dart:io';
import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sla_logger/src/models/models.dart';

/// log database handler class
class LogDatabase {
  /// single instance for all database query
  /// use this instance to interact with the database
  static final LogDatabase instance = LogDatabase._init();

  /// private database instance
  static Database? _database;

  /// singleton init
  LogDatabase._init();

  /// get the database
  /// initiate database if not initiated
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName: "logs.db");
    return _database!;
  }

  /// initiate database into system
  Future<Database> _initDB({required String dbName}) async {
    var dbPath = "";
    try {
      if (Platform.isAndroid) {
        /// for android only
        dbPath = await getDatabasesPath();
      } else {
        /// for iOS and macOS
        dbPath = (await getLibraryDirectory()).path;
      }
    } catch (e) {
      /// default on error
      dbPath = await getDatabasesPath();
      log("[error] [$runtimeType] [_initDB] $e");
    }
    final path = join(dbPath, dbName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// create all the tables
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const doubleType = 'DOUBLE NOT NULL';

    await db.execute('''
      CREATE TABLE $tableLogs (
        ${DBLogFields.id} $idType,
        ${DBLogFields.level} $textType,
        ${DBLogFields.className} $textType,
        ${DBLogFields.methodName} $textType,
        ${DBLogFields.createdAt} $textType,
        ${DBLogFields.message} $textType,
        ${DBLogFields.type} $textType,
        ${DBLogFields.error} $textType
      )
      ''');
  }

  /// add log
  Future<int> addLog(DBLog dbLog) async {
    try {
      final db = await instance.database;
      if (dbLog.id != null) {
        dbLog = dbLog.copyWith(id: null);
      }
      return await db.insert(tableLogs, dbLog.toMap());
    } catch (e) {
      log("[error] [$runtimeType] [addLog] [51] $e");
      return Future.value(0);
    }
  }

  /// returns all the saved logs
  Future<List<DBLog>> getAllLog() async {
    try {
      final db = await instance.database;
      final List<DBLog> dbLogs = [];
      final dataSet = await db.query(
        tableLogs,
        limit: 100,
        orderBy: DBLogFields.id,
        columns: DBLogFields.dbLogFieldsValues,
      );
      if (dataSet.isNotEmpty) {
        for (var element in dataSet) {
          dbLogs.add(DBLog.fromJson(element));
        }
      }

      return Future.value(dbLogs.toList());
    } catch (e) {
      log("[error] [$runtimeType] [getAllLog]: $e");
      return Future.value([]);
    }
  }

  /// delete log by id
  Future<int> deleteLogById(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        tableLogs,
        where: '${DBLogFields.id} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      log("[error] [$runtimeType] [deleteLogById] $e");
      return Future.value(0);
    }
  }

  /// delete all logs
  Future<int> deleteAllLogs() async {
    try {
      final db = await instance.database;
      return await db.delete(tableLogs);
    } catch (e) {
      log("[error] [$runtimeType] [deleteAllLogs] $e");
      return Future.value(0);
    }
  }

  /// close the database
  close() async {
    try {
      final db = await instance.database;
      await db.close();
    } catch (e) {
      log("[error] [$runtimeType] [close] $e");
    }
  }
}
