import 'models.dart';
import 'dart:convert';
import 'dart:developer';

const tableLogs = 'table_logs';

class DBLogFields {
  static const id = "id";
  static const level = "level";
  static const className = "class_name";
  static const methodName = "method_name";
  static const createdAt = "created_at";
  static const message = "message";
  static const type = "type";
  static const error = "error";

  static final dbLogFieldsValues = [
    id,
    level,
    className,
    methodName,
    createdAt,
    message,
    type,
    error,
  ];
}

class DBLog {
  DBLog({
    required this.id,
    required this.level,
    required this.className,
    required this.methodName,
    required this.createdAt,
    required this.message,
    required this.type,
    required this.error,
  });

  int? id;
  var level = LogLevel.debug;
  var className = "";
  var methodName = "";
  var createdAt = "";
  var message = "";
  var type = "";
  var error = "";

  DBLog.fromJson(dynamic json) {
    try {
      if (json is Map<String, dynamic> && json.isNotEmpty) {
        id = json[DBLogFields.id] ?? id;
        final _level = json[DBLogFields.level].toString();
        if (_level == LogLevel.critical.name) {
          level = LogLevel.critical;
        } else if (_level == LogLevel.error.name) {
          level == LogLevel.error;
        } else if (_level == LogLevel.warning.name) {
          level = LogLevel.warning;
        } else if (_level == LogLevel.notice.name) {
          level = LogLevel.notice;
        } else if (_level == LogLevel.success.name) {
          level = LogLevel.success;
        } else if (_level == LogLevel.debug.name) {
          level = LogLevel.debug;
        }
        className = json[DBLogFields.className] ?? className;
        methodName = json[DBLogFields.methodName] ?? methodName;
        createdAt = json[DBLogFields.createdAt] ?? createdAt;
        message = json[DBLogFields.message] ?? message;
        type = json[DBLogFields.type] ?? type;
        error = json[DBLogFields.error] ?? error;
      }
    } catch (e) {
      log("[$runtimeType] [fromJson]: $e");
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    try {
      map[DBLogFields.id] = id;
      map[DBLogFields.level] = level.name;
      map[DBLogFields.className] = className;
      map[DBLogFields.methodName] = methodName;
      map[DBLogFields.createdAt] = createdAt;
      map[DBLogFields.message] = message;
      map[DBLogFields.type] = type;
      map[DBLogFields.error] = error;
    } catch (e) {
      log("[$runtimeType] [toMap]: $e");
    }
    return map;
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    try {
      json[DBLogFields.id] = id;
      json[DBLogFields.level] = level.name;
      json[DBLogFields.className] = className;
      json[DBLogFields.methodName] = methodName;
      json[DBLogFields.createdAt] = createdAt;
      json[DBLogFields.message] = message;
      json[DBLogFields.type] = type;
      json[DBLogFields.error] = error;
    } catch (e) {
      log("[$runtimeType] [toJson]:  $e");
    }
    return json;
  }

  DBLog copyWith({
    int? id,
    LogLevel? level,
    String? className,
    String? methodName,
    String? createdAt,
    String? message,
    String? type,
    String? error,
  }) =>
      DBLog(
        id: id ?? this.id,
        level: level ?? this.level,
        className: className ?? this.className,
        methodName: methodName ?? this.methodName,
        createdAt: createdAt ?? this.createdAt,
        message: message ?? this.message,
        type: type ?? this.type,
        error: error ?? this.error,
      );

  @override
  String toString() => json.encode(this);
}
