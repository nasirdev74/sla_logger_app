import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:sla_logger/.env.dart';
import 'package:flutter/foundation.dart';
import 'package:sla_logger/src/data/data.dart';
import 'package:sla_logger/src/models/models.dart';

const tryCatch = "TRY CATCH";

/// app log handler class
class AppLog {
  /// private database instance
  static final _database = LogDatabase.instance;

  /// log source class
  Type? classType;

  AppLog(Type this.classType);

  /// save critical log
  Future c(String tag, String message, dynamic exception) async => await _save(
        level: LogLevel.critical,
        tag: tag,
        message: message,
        exception: exception,
      );

  /// save error log
  Future e(String tag, String message, dynamic exception) async => await _save(
        level: LogLevel.error,
        tag: tag,
        message: message,
        exception: exception,
      );

  /// save warning log
  Future w(String tag, String message, {dynamic err}) async => await _save(
        level: LogLevel.warning,
        tag: tag,
        message: message,
        exception: err,
      );

  /// save notice log
  Future n(String tag, String message, {dynamic err}) async => await _save(
        level: LogLevel.notice,
        tag: tag,
        message: message,
        exception: err,
      );

  /// save success log
  Future s(String tag, String message, {dynamic err}) async => await _save(
        level: LogLevel.success,
        tag: tag,
        message: message,
        exception: err,
      );

  /// print debug log
  void d(String tag, String message, {dynamic err}) {
    log(
      "[${LogLevel.debug.name}] ${classType == null ? '' : '[$classType]'} [$tag]: $message ${err != null ? "\n$err" : ""}",
    );
  }

  /// save to database
  _save({
    LogLevel level = LogLevel.debug,
    String tag = "",
    String message = "",
    dynamic exception,
  }) async {
    try {
      final dbLog = DBLog(
        id: null,
        level: level,
        className: "$classType",
        methodName: tag,
        createdAt: DateFormat(LOG_DATE_FORMAT).format(DateTime.now()),
        message: message,
        type: "${exception?.runtimeType}",
        error: "$exception",
      );
      await _database.addLog(dbLog);
      if (kDebugMode) {
        log("[${level.name}] ${classType == null ? '' : '[$classType]'} [$tag] : $message ${exception != null ? "\n$exception" : ""}");
      }
    } catch (e) {
      d(tag, message, err: exception);
    }
  }

  /// show all logs from database
  printAllLogs() async {
    final logs = await _database.getAllLog();
    log(logs.toString());
  }

  /// close database
  close() async => await _database.close();
}
